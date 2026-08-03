# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
### Enterprise Observability · KQL Threat Detection · Dashboards · Automated Alerting

| Field | Value |
| :--- | :--- |
| **Completed** | August 2026 |
| **Platform** | Azure Monitor · Log Analytics Workspace · Azure Portal · KQL |
| **Cost** | ~$0.50–$1.00 USD (Log Analytics ingestion within free limits) |
| **Time Taken** | 2–3 hours |
| **Cert Alignment** | AZ-104 Azure Administrator · AZ-500 Azure Security Engineer |
| **Prerequisites** | Lab 1 (Active Directory) · Lab 2 (Azure Networking) · Lab 3 (Azure Identity) |
| **Author** | **Emmanuel Onen** (Cloud & Systems Engineer) |

---

## The Business Problem This Lab Solves

Labs 1, 2, and 3 built the infrastructure — identity, networking, and access controls. **Lab 4 makes it observable.**

Without centralised logging and proactive monitoring, silent failures go undetected until they become business disruptions:
* A Network Security Group (NSG) silently dropping legitimate application traffic.
* Repeated failed authentication attempts preceding a credential-stuffing attack.
* A production Virtual Machine CPU breaching 85% without notifying the operational team.

**Global Logistics & Enterprise Services** mandated an enterprise observability architecture providing:
1. **Single Source of Truth:** Centralised log convergence for compute, network, and identity.
2. **KQL Security Intelligence:** Production queries for threat detection.
3. **Executive Dashboarding:** Single-pane-of-glass operational visibility.
4. **Automated Alerting:** Event-driven notification pipelines replacing manual oversight.

---

## Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                    ENTERPRISE OBSERVABILITY STACK                       │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  EXECUTIVE DASHBOARD                                             │   │
│  │  Enterprise Cloud Operations & Observability                     │   │
│  │  [CPU Timechart] [Failed Sign-ins] [Storage Ingress/Egress]      │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                           ▲                                             │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  METRIC & LOG ALERTS                                             │   │
│  │  alert-high-cpu-utilization → ag-cloud-ops-team (email)          │   │
│  │  Threshold: CPU > 85% over 5-minute window                       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                           ▲ KQL Queries                                 │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  LOG ANALYTICS WORKSPACE (Central)                               │   │
│  │  law-enterprise-monitoring-eastus                                │   │
│  │  Single source of truth — all log streams converge here          │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│         ▲                    ▲                    ▲                     │
│  ┌──────────────┐  ┌──────────────────┐  ┌──────────────────────────┐   │
│  │ Azure Monitor│  │ Network Watcher  │  │ Entra ID Diagnostics     │   │
│  │ Agent (AMA)  │  │ NSG Flow Logs    │  │ AuditLogs · SignInLogs   │   │
│  │ DCR: dcr-vm- │  │ nsg-spoke-app-   │  │ RiskyUsers               │   │
│  │ telemetry    │  │ eastus           │  │ entra-to-law             │   │
│  └──────────────┘  └──────────────────┘  └──────────────────────────┘   │
│         ▲                    ▲                    ▲                     │
│  [App VM / DC]     [Spoke Network Layer]   [Identity Layer (Lab 3)]     │
│  Syslog/EventLog   Denied Traffic/IPs      PIM · Sign-ins · Audits      │
└─────────────────────────────────────────────────────────────────────────┘

## Technical Evidence & Proof of Execution

### Task 1: Provision Central Log Analytics Workspace (LAW)
Established central telemetry workspace `law-enterprise-monitoring-eastus` in `rg-hub-eastus`.
![Workspace Creation](screenshots/1a-log-analytics-workspace-creation.jpeg)

---

### Task 2: Data Collection Rule (DCR) & AMA Extension
Configured `dcr-vm-telemetry` using Azure Monitor Agent to collect System, Security, Application logs, and Performance counters.
![DCR Configuration](screenshots/2a-data-collection-rule-configuration.jpeg)

---

### Task 3: Cross-Layer Log Integration (Network & Identity)
Streamed NSG Flow logs (`nsg-spoke-app-eastus`) and Microsoft Entra ID logs (`entra-to-law`) into the workspace.
![NSG Integration](screenshots/3a-nsg-flow-logs-workspace-integration.jpeg)

---

### Task 4: Production KQL Telemetry Queries

#### Query 1: Failed Entra ID Sign-in Attempts
```kql
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType != 0
| summarize FailedCount = count() by UserPrincipalName, IPAddress, ResultDescription, AppDisplayName
| sort by FailedCount desc

#### Query 2: Denied Network Traffic Telemetry
NTTFlowLogs
| where TimeGenerated > ago(12h)
| where FlowDecision == "D"
| summarize DeniedPackets = sum(Packets) by SrcIP, DestIP, DestPort, L7Protocol
| sort by DeniedPackets desc

Task 5: Enterprise Operations Dashboard

Built the Enterprise Cloud Operations & Observability portal dashboard pinning real-time analytical KQL tiles.

Task 6: Metric Alert Rules & Action Groups

Configured alert-high-cpu-utilization (Severity 1) targeting CPU > 85% paired with ag-cloud-ops-team email notification pipeline.

Lab Progression Summary

Lab 1: Active Directory Infrastructure & Identity Core

Lab 2: Azure Hub-and-Spoke Enterprise Networking

Lab 3: Entra ID Governance, PIM & Conditional Access

Lab 4: Centralised Telemetry, KQL, Dashboards & Alerting

Author: Emmanuel Onen | Senior Systems Engineer | Cayman Islands

GitHub Profile: github.com/emmanuelonen
