# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script 03: Stream Network Watcher NSG Flow Logs to LAW
# Emmanuel Onen | August 2026
# ============================================================

Connect-AzAccount

$ResourceGroup  = "rg-hub-eastus"
$WorkspaceName  = "law-enterprise-monitoring-eastus"
$NsgName        = "nsg-spoke-app-eastus"
$StorageAccount = "stnsgflowlogseastus"

$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName$ResourceGroup -Name $WorkspaceName$Nsg = Get-AzNetworkSecurityGroup -ResourceGroupName "rg-spoke-prod-eastus" -Name $NsgName$Storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name$StorageAccount

# Configure NSG Flow Logs with Log Analytics Integration
Set-AzNetworkWatcherConfigFlowLog `
    -NetworkWatcher (Get-AzNetworkWatcher | Select-Object -First 1) `
    -TargetResourceId $Nsg.Id `
    -StorageAccountId $Storage.Id `
    -EnableDebug $true `
    -EnableInbound $true `
    -EnableOutbound $true `
    -EnableRetention $true `
    -RetentionInDays 7 `
    -WorkspaceResourceId $Workspace.ResourceId

Write-Host "NSG Flow Logs enabled and targeted to $WorkspaceName" -ForegroundColor Green
