# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script 01: Provision Central Log Analytics Workspace
# Emmanuel Onen | August 2026
# ============================================================

Connect-AzAccount

$ResourceGroup  = "rg-hub-eastus"
$Location       = "EastUS"
$WorkspaceName  = "law-enterprise-monitoring-eastus"

# Create the Log Analytics Workspace
New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $ResourceGroup `
    -Name              $WorkspaceName `
    -Location          $Location `
    -Sku               "PerGB2018" `
    -RetentionInDays   30

Write-Host "Log Analytics Workspace created: $WorkspaceName" -ForegroundColor Green

# Verify workspace status
$Workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $ResourceGroup `
    -Name              $WorkspaceName

$Workspace | Select-Object Name, ResourceGroupName, Location, Sku, RetentionInDays,
    @{N='ProvisioningState';E={$_.ProvisioningState}},
    @{N='CustomerId';E={$_.CustomerId}}
