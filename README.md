# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
### Enterprise Observability · KQL Threat Detection · Dashboards · Automated Alerting

| Field | Value |
|---|---|
| **Completed** | August 2026 |
| **Platform** | Azure Monitor · Log Analytics Workspace · Azure Portal · KQL |
| **Cost** | ~$0.50–$1.00 USD (Log Analytics ingestion within free limits if cleaned up promptly) |
| **Time taken** | 2–3 hours across multiple sessions |
| **Cert alignment** | AZ-104 Azure Administrator · AZ-500 Azure Security Engineer |
| **Prerequisites** | Lab 1 (Active Directory) · Lab 2 (Azure Networking) · Lab 3 (Azure Identity) |
| **Career relevance** | Cloud Engineer · Cloud Operations Engineer · Security Analyst · Infrastructure Specialist |

---

## The Business Problem This Lab Solves

Labs 1, 2 and 3 built the infrastructure — identity, networking, and access controls. **Lab 4 makes it observable.**

Without centralised logging and proactive monitoring, silent failures go undetected until they become business disruptions. A network security group silently dropping legitimate traffic. Repeated failed authentication attempts preceding a credential-stuffing attack. A virtual machine CPU breaching 85% without the operations team being notified. In regulated industries — financial services, healthcare, government — undetected events are not just operational failures. They are compliance failures.

**Global Logistics & Enterprise Services** mandated an enterprise observability architecture delivering end-to-end visibility across every layer of the infrastructure deployed in Labs 1–3. This is the exact monitoring and alerting stack a Cloud Engineer or Cloud Operations Engineer implements on day one of any enterprise Azure engagement.

| Role | How this lab applies |
|---|---|
| **Cloud Engineer** | Designing and deploying centralised logging, DCRs and alerting pipelines |
| **Cloud Operations Engineer** | Writing KQL queries for operational intelligence, building dashboards, managing alert rules |
| **Security Analyst** | Querying sign-in logs for failed authentication, NSG flow logs for denied traffic, PIM elevation events |
| **Infrastructure Specialist** | Monitoring VM performance, diagnosing resource bottlenecks, validating telemetry pipelines |

---

## Observability Architecture

```
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
│  └──────────────────────────────────────────────────────────────────┘   │
│         ▲                    ▲                    ▲                     │
│  ┌──────────────┐  ┌──────────────────┐  ┌──────────────────────┐       │
│  │ Azure Monitor│  │ Network Watcher  │  │ Entra ID Diagnostics │       │
│  │ Agent (AMA)  │  │ NSG Flow Logs    │  │ AuditLogs·SignInLogs │       │
│  │ dcr-vm-      │  │ nsg-spoke-app-   │  │ entra-to-law         │       │
│  │ telemetry    │  │ eastus           │  │                      │       │
│  └──────────────┘  └──────────────────┘  └──────────────────────┘       │
│         ▲                    ▲                    ▲                     │
│  [App VM / DC]    [Spoke Network Layer]   [Identity Layer — Lab 3]      │
│  EventLog/Perf    Denied Traffic/IPs      PIM · Sign-ins · Audits       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## What Was Built

- ✅ Log Analytics Workspace (`law-enterprise-monitoring-eastus`) provisioned in `rg-hub-eastus` — central telemetry repository
- ✅ Data Collection Rule (`dcr-vm-telemetry`) configured — AMA-based collection of Windows Event Logs and Performance Counters from Lab 1/2 VMs
- ✅ System, Application and Security event log streams confirmed routing to LAW
- ✅ NSG Flow Logs from `nsg-spoke-app-eastus` (Lab 2) integrated to LAW via Network Watcher
- ✅ Entra ID Diagnostic Settings (`entra-to-law`) configured — AuditLogs, SignInLogs and RiskyUsers streaming
- ✅ KQL Query 1 executed — Failed Entra ID Sign-in Attempts (security baseline)
- ✅ KQL Query 2 executed — Denied Network Traffic via NSG Flow Telemetry
- ✅ KQL Query 3 executed — VM CPU utilisation threshold monitoring with timechart render
- ✅ Enterprise Operations Dashboard built — `Enterprise Cloud Operations & Observability` with 3 pinned tiles
- ✅ Metric Alert Rule (`alert-high-cpu-utilization`) created — CPU > 85% over 5-minute window, Severity 1
- ✅ Action Group (`ag-cloud-ops-team`) configured — email notification pipeline active
- ✅ Heartbeat verification query executed — confirms AMA agent data pipeline is active
- ✅ Log ingestion latency query executed — validates all table streams within 30-minute window

---

## Architecture Decisions — Why Each Choice Was Made

| Decision | Rationale | Enterprise Relevance |
|---|---|---|
| **Log Analytics Workspace over Storage Account** | LAW provides real-time KQL querying, visualisation and alert-trigger capability. Storage Accounts provide raw blob storage with no native query engine. | Every enterprise observability architecture requires queryable, indexed log storage — not raw blob archives. |
| **Azure Monitor Agent (AMA) over Legacy MMA/OMS** | MMA is deprecated. AMA uses Data Collection Rules for granular, targeted telemetry collection with multi-homing support and a defined Microsoft roadmap. | Deploying deprecated agents in a new architecture creates immediate technical debt. Building with AMA is the production-correct approach. |
| **Native NSG Flow Log streaming over third-party SIEM export** | Direct streaming to LAW avoids extra network egress costs, preserves native KQL alignment and requires no additional middleware or licensing. | In cost-sensitive cloud environments, eliminating unnecessary egress and middleware overhead is engineering discipline — not just cost-saving. |
| **KQL over manual CSV log export** | KQL provides sub-second aggregation across millions of records, feeds automated alert rules and dashboard tiles, and produces repeatable, version-controllable queries. | Production security operations require automated, queryable telemetry — not analyst-extracted spreadsheets that cannot trigger automation. |
| **Azure Portal Dashboards over Power BI** | Built-in dashboards are zero cost, maintain native context-switching to underlying resources and require no additional licensing or gateway. | Choose the right tool for the use case. Power BI adds value for executive reporting but introduces unnecessary complexity for an engineering monitoring context. |
| **CPU > 85% alert threshold** | 85% sustained over 5 minutes precedes resource exhaustion while allowing time for remediation before user impact. Lower thresholds generate alert fatigue; higher thresholds leave insufficient response time. | Alert threshold engineering is as important as alert creation — a noisy alert trains operators to ignore notifications. |

---

## Key Concepts Explained

### What is a Log Analytics Workspace?

A Log Analytics Workspace (LAW) is the storage and query layer for Azure Monitor. Azure Monitor collects telemetry from every Azure resource — metrics, logs, performance data — and the LAW receives, indexes and makes that telemetry queryable via KQL. Without a workspace, you can view real-time metrics but cannot run historical queries, build dashboards from log data, or trigger alerts based on log patterns. Think of Azure Monitor as the collection engine and the LAW as the analytical database it feeds.

### What is a Data Collection Rule (DCR)?

A Data Collection Rule defines precisely what telemetry to collect, from which resources, and where to send it. The Azure Monitor Agent (AMA) reads the DCR to determine which event logs, performance counters and syslog sources to harvest from each virtual machine. This is the replacement for the legacy Log Analytics Agent (MMA/OMS), which collected everything indiscriminately and is now deprecated. DCRs enable targeted, cost-efficient telemetry — you collect only what the business requires.

### What is KQL?

Kusto Query Language (KQL) is the query language for Log Analytics workspaces, Microsoft Sentinel, and Azure Data Explorer. It uses a pipe-based syntax where each operator transforms the dataset — `where` filters rows, `summarize` aggregates, `sort` orders results, `render` produces visualisations. KQL is optimised for time-series log data and can aggregate millions of records in seconds. Every query in this lab is a production-ready security or operational intelligence script used in real enterprise environments.

### What is an Action Group?

An Action Group is a reusable collection of notification and automation responses that Azure Monitor executes when an alert fires. A single Action Group can include email notifications, SMS messages, webhook calls, ITSM connector triggers, Logic App executions and Azure Function invocations. By separating the notification recipients from the alert rule itself, multiple alert rules can reference the same Action Group — meaning one update to the Action Group changes the notification configuration for all alerts simultaneously.

### Why Does the Dashboard Show "No Data"?

Three conditions produce empty tiles in a lab environment — all are expected and do not indicate misconfiguration. First, newly configured AMA agents and DCRs take 10–15 minutes to begin flowing telemetry. Second, if VMs are stopped or no failed sign-in attempts have occurred in the query window, queries return zero rows — this is correct behaviour. Third, the dashboard time picker and the KQL `ago()` function operate independently; a mismatch between them produces empty tiles even when data exists outside the selected window.

---

## KQL Queries — Production Reference

### Query 1 — Failed Entra ID Sign-in Attempts

```kql
// Detect credential stuffing and brute force — security baseline
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType != 0
| summarize FailedCount = count() by UserPrincipalName, IPAddress, ResultDescription, AppDisplayName
| sort by FailedCount desc
```

### Query 2 — Denied Network Traffic via NSG Flow Telemetry

```kql
// Detect reconnaissance and lateral movement — network baseline
NTTFlowLogs
| where TimeGenerated > ago(12h)
| where FlowDecision == "D"
| summarize DeniedPackets = sum(Packets) by SrcIP, DestIP, DestPort, L7Protocol
| sort by DeniedPackets desc
```

### Query 3 — VM CPU Utilisation Threshold Monitoring

```kql
// Monitor compute performance — operational baseline
Perf
| where TimeGenerated > ago(4h)
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 15m)
| render timechart
```

---

## Screenshot Evidence Index

| Screenshot | File | What It Proves |
|---|---|---|
| 1a | `1a-log-analytics-workspace-creation.jpeg` | `law-enterprise-monitoring-eastus` provisioned and Active in `rg-hub-eastus` |
| 2a | `2a-data-collection-rule-configuration.jpeg` | `dcr-vm-telemetry` configured — AMA, Windows Event Logs and Perf Counters streaming |
| 3a | `3a-nsg-flow-logs-workspace-integration.jpeg` | NSG Flow Logs from `nsg-spoke-app-eastus` streaming to LAW via Network Watcher |
| 4a | `4a-kql-query-failed-signins-execution.jpeg` | Query 1 executed — Failed Entra ID Sign-in Attempts results |
| 4b | `4b-kql-query-nsg-denied-traffic-results.jpeg` | Query 2 executed — NSG Denied Traffic telemetry results |
| 5a | `5a-enterprise-observability-dashboard-view.jpeg` | Executive Dashboard — 3-tile layout pinned from KQL queries |
| 6a | `6a-azure-monitor-alert-rule-and-action-group.jpeg` | `alert-high-cpu-utilization` (Severity 1) and `ag-cloud-ops-team` configured |

---

## Files in This Repository

| File | Contents |
|---|---|
| `scripts/01-create-log-analytics-workspace.ps1` | Provision LAW with correct SKU and 30-day retention |
| `scripts/02-configure-data-collection-rule.ps1` | AMA + DCR configuration for VM telemetry |
| `scripts/03-configure-nsg-flow-logs.ps1` | NSG Flow Logs streaming to LAW via Network Watcher |
| `scripts/04-configure-entra-diagnostics.ps1` | Entra ID Diagnostic Settings routing to LAW |
| `scripts/05-kql-production-queries.kql` | All 3 production KQL queries with inline documentation |
| `scripts/06-configure-alert-rule.ps1` | Metric alert rule and action group creation |
| `verification/verify-lab4.ps1` | Full verification checklist — pipeline integrity |
| `verification/verify-lab4.kql` | KQL verification queries — heartbeat and ingestion latency |
| `screenshots/` | 7 sequential evidence screenshots — live execution |

---

## Verification Checklist

| Check | Location / Command | Expected Result |
|---|---|---|
| LAW exists | Azure Portal → Log Analytics workspaces | `law-enterprise-monitoring-eastus` — Active |
| DCR configured | Azure Portal → Data Collection Rules | `dcr-vm-telemetry` — Succeeded, VM assigned |
| NSG Flow Logs streaming | Network Watcher → Flow Logs | `nsg-spoke-app-eastus` — Enabled, LAW destination confirmed |
| Entra diagnostic settings active | Entra ID → Diagnostic settings | `entra-to-law` — AuditLogs, SignInLogs, RiskyUsers enabled |
| Heartbeat data present | LAW → Logs → Heartbeat query | Returns at least 1 computer with recent heartbeat |
| Failed sign-in query executes | LAW → Logs → Query 1 | Query runs successfully (empty result = no failures — valid) |
| NSG denied traffic query executes | LAW → Logs → Query 2 | Query runs successfully — table exists in workspace |
| Dashboard exists | Azure Portal → Dashboards | `Enterprise Cloud Operations & Observability` — 3 tiles pinned |
| Alert rule active | Azure Monitor → Alerts → Alert rules | `alert-high-cpu-utilization` — Enabled, Severity 1 |
| Action group configured | Azure Monitor → Action groups | `ag-cloud-ops-team` — Email notification configured |

---

## On-Premises to Azure Monitoring Mapping

| On-Premises Concept | Azure Equivalent | Why It Matters |
|---|---|---|
| SIEM / Syslog Server | Log Analytics Workspace | Cloud-native, queryable log repository — no infrastructure to manage |
| Windows Event Viewer (local) | Azure Monitor Agent + DCR | Centralised, remotely queryable, policy-driven collection |
| Network packet capture / flow analysis | NSG Flow Logs via Network Watcher | Software-defined traffic telemetry — no hardware taps or span ports |
| Manual log review by analyst | KQL Query Engine | Sub-second aggregation across millions of records — not human-scale review |
| Scheduled monitoring checks | Metric Alert Rules | Event-driven, threshold-based — fires the moment conditions are met |
| On-call pager / email list | Azure Action Groups | Centralised, reusable notification pipeline — one update covers all alerts |
| SIEM dashboard (Splunk / QRadar) | Azure Portal Dashboards | Native, zero-cost, context-aware — no additional licensing |

---

## Lab Progression — Labs 1 Through 4

| Lab 1 — Active Directory | Lab 2 — Azure Networking | Lab 3 — Azure Identity | Lab 4 — Azure Monitor |
|---|---|---|---|
| Domain Controller | VNet / Hub-Spoke | Entra ID Tenant | Log Analytics Workspace |
| Event Viewer (local logs) | NSG Flow Logs (local) | Entra Sign-in Logs | All streams → single LAW |
| GPO audit settings | Network Watcher (manual) | Conditional Access logs | KQL query engine |
| Manual log review | Manual traffic analysis | Manual audit log check | Automated alert rules |
| Help desk reactive response | Network troubleshooting | Identity incident response | Proactive MTTD reduction |

Every lab builds on the same operational principle: **build it, secure it, control access to it, then watch it continuously.**

---

## Interview Questions This Lab Prepares You For

**"What is the difference between Azure Monitor and a Log Analytics Workspace?"**
Azure Monitor is the platform-level telemetry collection engine — it gathers metrics and logs from every Azure resource. A Log Analytics Workspace is the storage and query layer — it receives those logs, indexes them and makes them queryable via KQL. Azure Monitor without a LAW gives you real-time metrics and basic alerts but no historical log analysis or cross-resource query capability.

**"What is a Data Collection Rule and why use it over the legacy Log Analytics Agent?"**
A DCR defines what telemetry to collect, from which resources, and where to send it. The Azure Monitor Agent uses DCRs for targeted, cost-efficient collection. The legacy MMA/OMS agent collected everything indiscriminately and is now deprecated. DCRs allow collection of only what the business requires, from only the resources specified, with the ability to route to multiple destinations.

**"Write a KQL query to detect failed sign-in attempts."**
`SigninLogs | where TimeGenerated > ago(24h) | where ResultType != 0 | summarize FailedCount = count() by UserPrincipalName, IPAddress, ResultDescription | sort by FailedCount desc` — this aggregates failures per user and source IP, which surfaces the pattern used to detect credential stuffing and brute force attacks.

**"How would you alert the operations team when CPU exceeds a threshold?"**
Create an Azure Monitor Alert Rule targeting the VM resource with a Percentage CPU metric condition — threshold greater than 85%, evaluated over a 5-minute aggregation window. Attach an Action Group with email notification. The Action Group is reusable — multiple alert rules can reference the same group, so one update to the contact list covers all infrastructure alerts simultaneously.

---

*Part of a structured cloud engineering portfolio — Lab 1: Active Directory | Lab 2: Azure Networking | Lab 3: Azure Identity | Lab 4: KQL & Azure Monitor | Lab 5: Terraform on Azure*

**Emmanuel Onen · Senior Systems Engineer · Cayman Islands**
*Certification path: AZ-900 → AZ-104 → AI-102 → AZ-400*
*GitHub: [github.com/emmanuelonen](https://github.com/emmanuelonen)*
