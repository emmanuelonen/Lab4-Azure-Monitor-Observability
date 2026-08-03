# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script 04: Stream Entra ID Diagnostic Logs to LAW
# Emmanuel Onen | August 2026
# ============================================================

Connect-AzAccount

$WorkspaceGroup = "rg-hub-eastus"
$WorkspaceName  = "law-enterprise-monitoring-eastus"

$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceGroup -Name $WorkspaceName

# Enable Microsoft Entra ID diagnostic streaming via Az.Monitor
New-AzDiagnosticSetting `
    -Name "entra-to-law" `
    -ResourceId "/providers/Microsoft.aadiam" `
    -WorkspaceId $Workspace.ResourceId `
    -Category "AuditLogs","SignInLogs","RiskyUsers" `
    -Enabled $true

Write-Host "Entra ID Diagnostics setting 'entra-to-law' active." -ForegroundColor Green
