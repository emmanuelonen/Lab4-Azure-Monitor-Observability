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
│  ┌──────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ Azure Monitor│  │ Network Watcher  │  │ Entra ID Diagnostics     │  │
│  │ Agent (AMA)  │  │ NSG Flow Logs    │  │ AuditLogs · SignInLogs   │  │
│  │ DCR: dcr-vm- │  │ nsg-spoke-app-   │  │ RiskyUsers               │  │
│  │ telemetry    │  │ eastus           │  │ entra-to-law             │  │
│  └──────────────┘  └──────────────────┘  └──────────────────────────┘  │
│         ▲                    ▲                    ▲                     │
│  [App VM / DC]     [Spoke Network Layer]   [Identity Layer (Lab 3)]     │
│  Syslog/EventLog   Denied Traffic/IPs      PIM · Sign-ins · Audits      │
└─────────────────────────────────────────────────────────────────────────┘
