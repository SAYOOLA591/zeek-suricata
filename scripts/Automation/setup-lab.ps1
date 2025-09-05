# ==============================
# Zeek + Suricata + Splunk Setup Orchestrator
# Runs on Windows, connects to Ubuntu VM via SSH
# ==============================

$vmIP   = "192.168.1.30"    # VM running Zeek + Suricata + Splunk UF
$user   = "dfir"

# Splunk Indexer Settings
$splunkIndexer = "192.168.1.50"   # Replace with your Splunk Indexer IP
$splunkPort    = 8089             # Splunk management port
$splunkUser    = "admin"
$splunkPass    = "changeme"
$splunkIndex   = "homelab-detect"

function Run-SSH($command) {
    ssh "$user@$vmIP" $command
}

Write-Host "=== Starting End-to-End Lab Setup on $vmIP ==="

# 1. NIC Promiscuous Mode
Run-SSH "ip a"
Run-SSH "sudo ip link set ens33 promisc on"
Run-SSH "ip a"

# 2. Zeek Config
Run-SSH "sudo sed -i 's/interface=eth0/interface=ens33/' /opt/zeek/etc/node.cfg"
Run-SSH "sudo /opt/zeek/bin/zeekctl deploy"

# 3. Suricata Config
Run-SSH "sudo sed -i 's/interface: eth0/interface: ens33/' /etc/suricata/suricata.yaml"
Run-SSH "sudo systemctl restart suricata"
Run-SSH "sudo systemctl status suricata --no-pager"

# 4. Splunk inputs.conf
$inputs = @"
[default]
host = 192.168.1.30

[monitor:///opt/zeek/logs/current]
_TCP_ROUTING = *
disabled = false
index = $splunkIndex
sourcetype = bro:json
whitelist = \.log$

[monitor:///var/log/suricata/eve.json]
_TCP_ROUTING = *
disabled = false
index = $splunkIndex
sourcetype = suricata
"@

$remoteInputs = "/opt/splunkforwarder/etc/system/local/inputs.conf"
$inputs | ssh "$user@$vmIP" "cat > $remoteInputs"

# 5. Splunk outputs.conf
$outputs = @"
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = $splunkIndexer:9997

[tcpout-server://$splunkIndexer:9997]
"@

$remoteOutputs = "/opt/splunkforwarder/etc/system/local/outputs.conf"
$outputs | ssh "$user@$vmIP" "cat > $remoteOutputs"

# 6. Enable Zeek JSON Logs
$zeekLocal = "/opt/zeek/share/zeek/site/local.zeek"
Run-SSH "sudo bash -c 'echo ""@load policy/tuning/json-logs"" >> $zeekLocal'"
Run-SSH "sudo bash -c 'echo ""redef ignore_checksums = T;"" >> $zeekLocal'"
Run-SSH "sudo /opt/zeek/bin/zeekctl deploy"

# 7. Restart Splunk Forwarder
Run-SSH "cd /opt/splunkforwarder/bin && sudo ./splunk stop"
Run-SSH "cd /opt/splunkforwarder/bin && sudo ./splunk start"

# 8. Create Index on Splunk Indexer via REST API
Write-Host "=== Creating Splunk Index '$splunkIndex' on Indexer $splunkIndexer ==="
$body = @{ name = $splunkIndex } | ConvertTo-Json
Invoke-RestMethod -Uri "https://$splunkIndexer:$splunkPort/services/data/indexes" `
    -Method POST `
    -Headers @{ "Content-Type" = "application/json" } `
    -Body $body `
    -Credential (New-Object System.Management.Automation.PSCredential($splunkUser,(ConvertTo-SecureString $splunkPass -AsPlainText -Force))) `
    -SkipCertificateCheck

Write-Host "=== Lab Setup Completed: Zeek + Suricata Forwarding to Splunk ==="
