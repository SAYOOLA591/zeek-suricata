## Introduction

In this lab, I will demonstrate how to install and configure Zeek and Suricata on Ubuntu 22.04 server. These tools provide in-depth network traffic analysis and intrusion detection capabilities, which are essential for our defensive monitoring stack.

As part of the setup, I will configure a static IP address for the server to ensure it is on the same network topology as the rest of the lab environment. Our pfSense firewall will also play a central role in managing and routing traffic. By combining pfSense with Zeek and Suricata, we significantly enhance our visibility, allowing us to capture, analyze, and detect suspicious activities more effectively.

By the end of this lab, we will have a fully configured Zeek and Suricata environment that integrates with pfSense and complements our previous Active Directory and Splunk setup. This layered approach demonstrates how multiple security tools can work together to establish a comprehensive detection and monitoring ecosystem.

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

