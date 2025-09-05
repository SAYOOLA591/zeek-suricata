## Introduction

In this lab, I will demonstrate how to install and configure Zeek and Suricata on Ubuntu 22.04 server. These tools provide in-depth network traffic analysis and intrusion detection capabilities, which are essential for our defensive monitoring stack.

As part of the setup, I will configure a static IP address for the server to ensure it is on the same network topology as the rest of the lab environment. Our pfSense firewall will also play a central role in managing and routing traffic. By combining pfSense with Zeek and Suricata, we significantly enhance our visibility, allowing us to capture, analyze, and detect suspicious activities more effectively.



### Purpose  
Network Traffic Monitoring, IDS/IPS, Log Generation For SIEM)
#

# Tools
Zeek, Suricata, Ubuntu 22.04

# Setup
 - Base VM setup (Ubuntu 22.04)
 - Network configuration (static IP, bridging/NAT)

# Features
 - Installs Zeek (with JA3 & JA4 fingerprinting enabled)
 - Installs Suricata (with community ID correlation enabled)
 - Updates Suricata rules with ET/Open and Threat Hunting sources
 - Adds custom Sliver C2 rules for C2 detection
 - PowerShell script automates the whole process
#


# Zeek & Suricata Installation and Configuration Guide

### Install Zeek:

Add Zeek repository

The Zeek installation has been completed, and its binaries are located as shown below. To customize Zeek, its uses this configuration file provided, we are going to install and enable the folowing:

Installs Zeek (with JA3 & JA4 fingerprinting enabled)

![zek-install1](https://github.com/user-attachments/assets/ba2d3c81-96f7-4960-87fd-b9bd0348b968)

### Install zkg
![zkg-install](https://github.com/user-attachments/assets/358d4f5e-cc78-4465-ae81-19f4859e76de)

### Install JA3 & JA4
![ja3-ja4](https://github.com/user-attachments/assets/0e6d58fa-9a31-4ed4-aa58-25291ca4b6ee)

### Configure Zeek

Add the following lines at the bottom
![zeek-config1](https://github.com/user-attachments/assets/f166487b-23b0-441c-92f6-01ce032dcc01)

#

### Install Suricata
![suricata-img](https://github.com/user-attachments/assets/0101e713-d5fb-4297-854d-ae1dcc8ac450)

### Configure Suricata

Edit the YAML config:

Community IDs are intended to provide a predictable flow ID for records that can be used to match them to the output of other tools, such as Zeek.

![suricata-yaml](https://github.com/user-attachments/assets/7884ade3-5fdc-4f63-855d-e0b03786d23d)

### Update Rules

Enable additional rules:
![update-rule1](https://github.com/user-attachments/assets/7e96f042-49e4-48dd-8abd-56c121a00be8)
![update-rule2](https://github.com/user-attachments/assets/b7b59789-6574-44e8-a9b5-a0b7edc7dabd)

### Start Suricata
![suricata-start](https://github.com/user-attachments/assets/2c82c1cf-26fe-47c0-84fd-c075239b3620)

### Validate config
![validate-config](https://github.com/user-attachments/assets/12cf5229-d0c1-480f-81bc-e6060817e02b)

#

# Add Custom Sliver C2 Rules

### Fetch custom rule: 
![custom-rule1](https://github.com/user-attachments/assets/0e6bc590-fc3a-4119-ad0b-ba44ecd190bc)

### Append it to rules and Verify rule addition:
![apend-rule](https://github.com/user-attachments/assets/42b8bfc4-4716-4844-a806-6995052f661e)

### Now both Zeek and Suricata are installed, configured, and ready for investigation

---

# Setting Static IP Address and Default Route:

 - Configured a static IP address for the Zeek-Suricata server and defined a default route with the gateway 192.168.1.1. `sudo nano /etc/netplan/00-installer-config.yaml`

![zeek-static-ip1](https://github.com/user-attachments/assets/786bbfb7-a020-4553-b18c-12302b9e0c87)

Apply the changes: `sudo netplan apply`
![zeek-static-ip2](https://github.com/user-attachments/assets/4d472dd4-d1ac-4183-af8b-737fab7891f3)

---

# Zeek-Suricata + Splunk UF Setup

I’m grabbing the Splunk Universal Forwarder .deb file. I'll show a roundabout way through a TinyURL to install the file on the server and rename it as a habit with Splunk.

![splunk-deb](https://github.com/user-attachments/assets/9ec151a5-12de-4efa-9e24-b20882a45848)

### Setting UP Splunk Universal Forwarder:

Change into the forwarder binary, switch to the splunkforwarder user, start it, and accept the license. I set the username to admin and a secure password. Exit the splunkforwarder user, and then change to the binary to enable boot-start.

![splunkfwd-image](https://github.com/user-attachments/assets/c8fd5368-33ae-4145-b14f-173f36983c2a)

### Point this UF to the Splunk indexer

![splunkfwd-active](https://github.com/user-attachments/assets/c4b5381d-225e-4069-a960-fbcbd2b005c4)

We now see an active forwarding going to the Splunk server. Finally, this is how we configure Splunk on the Zeek server to point our data over to our Splunk server.

---

# Promiscuous Mode on NIC

We need to change the network adapter to promiscuous mode. Let me explain what promiscuous mode is and why it's important. When a Network Interface Card (NIC) is set to promiscuous mode, it allows all data frames to pass through, even those intended for other machines or network devices. This capability is essential for tools like Zeek and Suricata, which are used to monitor network traffic.

Currently, if I type "ip a" and check the ens33, which is my network adapter, I can see that it has broadcast and multicast capabilities. However, we need to enable promiscuous mode.

![promisc-on](https://github.com/user-attachments/assets/2ae7dc94-6df8-42c9-ad7c-16809126e7f3)

### Zeek Node Configuration For NIC

Edit `node.cfg` to ensure the correct interface is properly configured, as it is set to eth0 and the host to local host by default. In our case, we need to modify the node to intercept traffic from ens33. After that, we can save and deploy Zeek to capture traffic on ens33.

![zeek-node](https://github.com/user-attachments/assets/47e95fb2-cb0c-4d1e-ae8f-56779f9f9b24)
![zeek-deploy](https://github.com/user-attachments/assets/a332ef56-11f1-4068-b05f-2a31d1aadf7b)

### Suricata Interface Configuration For NIC

Edit `suricata.yaml`. We are going to search for Eth0 and replace all found within the config file to ens33.

![suricata-config1](https://github.com/user-attachments/assets/910555d1-fbd2-4196-96cd-03747e590dc3)
![suricata-yaml2](https://github.com/user-attachments/assets/dc705102-330d-4b92-a2cb-ee6e3632a77a)

---


# Splunk Inputs Configuration

Inside `/opt/splunk/etc/system/local/`, we don’t see an `inputs.conf` by default, only files like `outputs.conf`, `server.conf` that mean we are going to configure the `inputs.conf` to specify how our logs is going to be forward to the Splunk.

![splunkfwd-inputs1](https://github.com/user-attachments/assets/f26373e3-5f08-41b4-8b2b-b42cca035694)


### Explanation:
  - `host` sets the forwarder’s identity in Splunk
  - The first monitor watches Zeek logs under `/opt/zeek/logs/current`
  - The second monitor watches Suricata’s `eve.json`
  - Both are routed via TCP to the Splunk indexer `(_TCP_ROUTING=*)`
  - Events go into a custom index called `homelab-detect`

### Zeek: Enable JSON Logging

By default, Zeek logs are not parsed in JSON format. We must enable its policy that way our splunk server can then intrepret the logs in JSON format.

![zeekjson-policy](https://github.com/user-attachments/assets/1f3b8eca-ac86-4586-8eea-10443861bac3)


### Restart Splunk Forwarder

Restart the Splunk Universal Forwarder so it picks up new configs

# Zeek-Suricata Log Query Overview

I am super excited everything looks good! As we can see, our logs are ready to be queried in our SIEM platform.

![zeek_suricata-logs](https://github.com/user-attachments/assets/75f94b08-67ef-4b4e-8623-cb5474ea51e2)


































