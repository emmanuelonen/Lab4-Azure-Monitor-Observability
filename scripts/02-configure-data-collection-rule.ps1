# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script 02: Configure Azure Monitor Agent (AMA) & DCR
# Emmanuel Onen | August 2026
# ============================================================

Connect-AzAccount

$ResourceGroup  = "rg-hub-eastus"
$Location       = "EastUS"
$WorkspaceName  = "law-enterprise-monitoring-eastus"

$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name$WorkspaceName
$WorkspaceResourceId =$Workspace.ResourceId

# Generate Data Collection Rule (DCR) JSON configuration
$DCRBody = @"
{
    "location": "$Location",
    "properties": {
        "description": "Data collection rule for VM telemetry — Lab 4",
        "dataSources": {
            "windowsEventLogs": [
                {
                    "streams": ["Microsoft-Event"],
                    "xPathQueries": [
                        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
                        "Security!*[System[(band(Keywords,13510798882111488))]]",
                        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
                    ],
                    "name": "eventLogsDataSource"
                }
            ],
            "performanceCounters": [
                {
                    "streams": ["Microsoft-Perf"],
                    "samplingFrequencyInSeconds": 60,
                    "counterSpecifiers": [
                        "\\\\Processor(_Total)\\\\% Processor Time",
                        "\\\\Memory\\\\Available MBytes",
                        "\\\\LogicalDisk(C:)\\\\% Free Space"
                    ],
                    "name": "perfCountersDataSource"
                }
            ]
        },
        "destinations": {
            "logAnalytics": [
                {
                    "workspaceResourceId": "$WorkspaceResourceId",
                    "name": "lawDestination"
                }
            ]
        },
        "dataFlows": [
            { "streams": ["Microsoft-Event"], "destinations": ["lawDestination"] },
            { "streams": ["Microsoft-Perf"], "destinations": ["lawDestination"] }
        ]
    }
}
"@

$DCRBody | Out-File -FilePath "dcr-vm-telemetry.json" -Encoding UTF8
Write-Host "DCR JSON exported successfully to dcr-vm-telemetry.json" -ForegroundColor Green
