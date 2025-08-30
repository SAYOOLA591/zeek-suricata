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


































