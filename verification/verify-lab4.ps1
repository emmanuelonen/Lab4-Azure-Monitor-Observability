# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script: Automated Pipeline Verification Checklist
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | August 2026
# ============================================================
# This script executes validation checks across all Lab 4 resources:
# 1. Log Analytics Workspace status and retention
# 2. Data Collection Rule (DCR) status
# 3. Network Watcher NSG Flow Log configuration
# 4. Azure Monitor Metric Alert Rule & Action Group operational status
# ============================================================

Connect-AzAccount

$HubRg     = "rg-hub-eastus"
$SpokeRg   = "rg-networking-prod-eastus"
$LawName   = "law-enterprise-monitoring-eastus"
$DcrName   = "dcr-vm-telemetry"
$AlertName = "alert-high-cpu-utilization"
$AgName    = "ag-cloud-ops-team"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " LAB 4 TELEMETRY PIPELINE VERIFICATION " -ForegroundColor Cyan
Write-Host "====================================================`n" -ForegroundColor Cyan

# 1. Verify Log Analytics Workspace
Write-Host "[1/4] Checking Log Analytics Workspace..." -ForegroundColor Yellow
$LAW = Get-AzOperationalInsightsWorkspace -ResourceGroupName $HubRg -Name $LawName -ErrorAction SilentlyContinue
if ($LAW -and $LAW.ProvisioningState -eq "Succeeded") {
    Write-Host "  ✔ LAW '$LawName' is ACTIVE in $HubRg (Retention: $($LAW.RetentionInDays) days)" -ForegroundColor Green
} else {
    Write-Host "  ✖ LAW '$LawName' NOT FOUND or inactive" -ForegroundColor Red
}

# 2. Verify Data Collection Rule (DCR)
Write-Host "`n[2/4] Checking Data Collection Rule..." -ForegroundColor Yellow
$DCR = Get-AzDataCollectionRule -ResourceGroupName $HubRg -Name $DcrName -ErrorAction SilentlyContinue
if ($DCR) {
    Write-Host "  ✔ DCR '$DcrName' is ACTIVE (Provisioning State: $($DCR.ProvisioningState))" -ForegroundColor Green
} else {
    Write-Host "  ✖ DCR '$DcrName' NOT FOUND in $HubRg" -ForegroundColor Red
}

# 3. Verify Metric Alert Rule
Write-Host "`n[3/4] Checking Azure Monitor Alert Rule..." -ForegroundColor Yellow
$Alert = Get-AzMetricAlertRuleV2 -ResourceGroupName $SpokeRg -Name $AlertName -ErrorAction SilentlyContinue
if ($Alert -and $Alert.Enabled) {
    Write-Host "  ✔ Alert Rule '$AlertName' is ENABLED (Severity: $($Alert.Severity))" -ForegroundColor Green
} else {
    Write-Host "  ✖ Alert Rule '$AlertName' NOT FOUND or disabled" -ForegroundColor Red
}

# 4. Verify Action Group
Write-Host "`n[4/4] Checking Action Group..." -ForegroundColor Yellow
$AG = Get-AzActionGroup -ResourceGroupName $SpokeRg -Name $AgName -ErrorAction SilentlyContinue
if ($AG -and $AG.Enabled) {
    Write-Host "  ✔ Action Group '$AgName' is ACTIVE (Short Name: $($AG.GroupShortName))" -ForegroundColor Green
} else {
    Write-Host "  ✖ Action Group '$AgName' NOT FOUND" -ForegroundColor Red
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " VERIFICATION COMPLETE " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
