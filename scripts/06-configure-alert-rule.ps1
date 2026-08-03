# ============================================================
# Lab 4 — Azure Monitor, Log Analytics & KQL Telemetry Architecture
# Script 06: Metric Alert Rule & Action Group Creation
# Emmanuel Onen | August 2026
# ============================================================

Connect-AzAccount

$ResourceGroup = "rg-networking-prod-eastus"
$VmName        = "vm-app-test"

# 1. Create Action Group
$ActionEmail = New-AzActionGroupReceiver -Name "EmailOps" -EmailAddress "eonenit@gmail.com"
Set-AzActionGroup `
    -ResourceGroupName $ResourceGroup `
    -Name "ag-cloud-ops-team" `
    -ShortName "CloudOps" `
    -Receiver $ActionEmail

$ActionGroup = Get-AzActionGroup -ResourceGroupName$ResourceGroup -Name "ag-cloud-ops-team"

# 2. Create Metric Alert Rule (CPU > 85%)
$Vm = Get-AzVM -ResourceGroupName$ResourceGroup -Name $VmName$Condition = New-AzMetricAlertRuleV2Criteria `
    -MetricName "Percentage CPU" `
    -TimeAggregation Average `
    -Operator GreaterThan `
    -Threshold 85

Add-AzMetricAlertRuleV2 `
    -ResourceGroupName $ResourceGroup `
    -Name "alert-high-cpu-utilization" `
    -Severity 1 `
    -Scopes $Vm.Id `
    -WindowSize (New-TimeSpan -Minutes 5) `
    -EvaluationFrequency (New-TimeSpan -Minutes 1) `
    -Condition $Condition `
    -ActionGroupId $ActionGroup.Id

Write-Host "Alert rule 'alert-high-cpu-utilization' and Action Group created." -ForegroundColor Green
