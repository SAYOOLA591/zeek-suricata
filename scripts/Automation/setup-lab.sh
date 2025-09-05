# ==============================
# Zeek + Suricata + Splunk Setup Orchestrator
# Runs on Windows, connects to Ubuntu VM via SSH
# ==============================

$vmIP   = "192.168.1.30"
$user   = "dfir"

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
index = homelab-detect
sourcetype = bro:json
whitelist = \.log$

[monitor:///var/log/suricata/eve.json]
_TCP_ROUTING = *
disabled = false
index = homelab-detect
sourcetype = suricata
"@

$remoteInputs = "/opt/splunkforwarder/etc/system/local/inputs.conf"
$inputs | ssh "$user@$vmIP" "cat > $remoteInputs"

# 5. Enable Zeek JSON Logs
$zeekLocal = "/opt/zeek/share/zeek/site/local.zeek"
Run-SSH "sudo bash -c 'echo ""@load policy/tuning/json-logs"" >> $zeekLocal'"
Run-SSH "sudo bash -c 'echo ""redef ignore_checksums = T;"" >> $zeekLocal'"
Run-SSH "sudo /opt/zeek/bin/zeekctl deploy"

# 6. Restart Splunk Forwarder
Run-SSH "cd /opt/splunkforwarder/bin && sudo ./splunk stop"
Run-SSH "cd /opt/splunkforwarder/bin && sudo ./splunk start"

Write-Host "=== Lab Setup Completed ==="
