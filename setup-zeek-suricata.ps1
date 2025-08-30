This script assumes you have **OpenSSH client** in PowerShell and password-based SSH access.

# Zeek & Suricata Setup Script
# ==============================
# This script installs and configures Zeek and Suricata on Ubuntu 22.04 via SSH
# It also adds custom Sliver C2 detection rules to Suricata.

# VM Connection Settings
$vmIP     = "192.168.136.XXX"
$user     = "xyz"
$sliverRuleURL = "https://example.com/sliver.snort"   # Replace with actual URL
$rulePath = "/var/lib/suricata/rules/suricata.rules"
$ruleBackup = "/var/lib/suricata/rules/suricata.rules.old"

# Function: Run SSH Command
function Run-SSH($command) {
    ssh "$user@$vmIP" $command
}

Write-Host "=== Connecting to VM $vmIP as $user ==="

# 1: System Update
Run-SSH "sudo apt update && sudo apt upgrade -y"

# 2: Install Zeek
Run-SSH "sudo add-apt-repository -y ppa:zeek/zeek-lts && sudo apt update"
Run-SSH "sudo apt install zeek -y"

# 3: Configure Zeek (enable JA3 & JA4)
Run-SSH "sudo bash -c 'echo \"@load ja3\" >> /opt/zeek/share/zeek/site/local.zeek'"
Run-SSH "sudo bash -c 'echo \"@load ja4\" >> /opt/zeek/share/zeek/site/local.zeek'"

# 4: Install Suricata
Run-SSH "sudo apt install suricata -y"
Run-SSH "sudo systemctl enable suricata.service"
Run-SSH "sudo systemctl stop suricata.service"

# 5: Configure Suricata (enable community-id)
Run-SSH "sudo sed -i 's/community-id: false/community-id: true/' /etc/suricata/suricata.yaml"

# 6: Update Rules
Run-SSH "sudo suricata-update"
Run-SSH "sudo suricata-update enable-source tgreen-hunting"
Run-SSH "sudo suricata-update enable-source et/open"
Run-SSH "sudo suricata-update"

# 7: Add Custom Sliver C2 Rules
Write-Host "=== Adding Sliver C2 Detection Rules ==="

# Backup existing rules
Run-SSH "sudo cp $rulePath $ruleBackup"

# Download sliver.snort
Run-SSH "wget -O /tmp/sliver.snort $sliverRuleURL"

# Append to Suricata rules
Run-SSH "sudo bash -c 'cat /tmp/sliver.snort >> $rulePath'"

# Verify rules contain "sliver C2"
Run-SSH "grep -i 'sliver C2' $rulePath"

# 8: Start Suricata
Run-SSH "sudo systemctl start suricata.service"
Run-SSH "sudo systemctl status suricata.service"

# 9: Verify Configuration
Run-SSH "sudo suricata -T -c /etc/suricata/suricata.yaml -v"

Write-Host "=== Setup Complete: Zeek + Suricata Installed, Configured, and Sliver Rules Added ==="
