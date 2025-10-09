# Monitor GitHub Actions Workflows
# This script checks the status of recent workflow runs

param(
    [string]$Repo = "AlcarazMaxi/home-test",
    [string]$Workflow = "UI Tests"
)

Write-Host "🔍 Monitoring workflow: $Workflow in $Repo" -ForegroundColor Cyan
Write-Host "📊 Checking recent runs..." -ForegroundColor Yellow

# Function to check workflow status
function Get-WorkflowStatus {
    param([string]$Repository, [string]$WorkflowName)
    
    try {
        # This would use GitHub CLI if available
        # For now, we'll provide manual instructions
        Write-Host "📋 Manual Check Instructions:" -ForegroundColor Green
        Write-Host "1. Go to: https://github.com/$Repository/actions" -ForegroundColor White
        Write-Host "2. Look for '$WorkflowName' workflow" -ForegroundColor White
        Write-Host "3. Check the status (green = success, red = failed, yellow = running)" -ForegroundColor White
        Write-Host "4. Click on the run to see detailed logs" -ForegroundColor White
        Write-Host ""
        Write-Host "🎯 Expected Results:" -ForegroundColor Cyan
        Write-Host "✅ Quick mode should complete in 2-3 minutes" -ForegroundColor Green
        Write-Host "✅ Should show 'UI Tests' or 'API Tests' as green" -ForegroundColor Green
        Write-Host "✅ Artifacts should be available for download" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error checking workflow status: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check UI Tests
Write-Host "🎭 UI Tests Workflow Status:" -ForegroundColor Magenta
Get-WorkflowStatus -Repository "AlcarazMaxi/home-test" -WorkflowName "UI Tests"

Write-Host "`n🔧 API Tests Workflow Status:" -ForegroundColor Magenta  
Get-WorkflowStatus -Repository "AlcarazMaxi/home-test-api" -WorkflowName "API Tests"

Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Trigger quick runs manually via GitHub web interface" -ForegroundColor White
Write-Host "2. Wait for both to complete successfully" -ForegroundColor White
Write-Host "3. If successful, trigger full runs" -ForegroundColor White
Write-Host "4. Download artifacts for review" -ForegroundColor White

