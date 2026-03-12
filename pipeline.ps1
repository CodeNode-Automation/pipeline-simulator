#pipeline.ps1
$ErrorActionPreference = 'Stop'

$configPath = Join-Path $PSScriptRoot "config\pipeline.config.json"

$pipelineConfig = Get-Content $configPath | ConvertFrom-Json

try {

    foreach ($module in $pipelineConfig.PsModules) {
        $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "modules\$module.psm1"
        
        if (Test-Path $modulePath) {
            Import-Module -Name $modulePath -Force
            Write-Host "[LOADED] $module" -ForegroundColor DarkGray
        } else {
            throw "Required module missing: $modulePath" 
        }
    }

} catch {

    Write-Host "[FATAL ERROR] Failed to load pipeline modules." -ForegroundColor Red
    Write-Error $_

    return $false

}

if (-not (Test-Path $configPath)) {
    throw "Missing pipeline.config.json"
}

Write-PipelineLog "Pipeline started"
Write-PipelineLog "" -Level '' -WriteHost
Write-PipelineLog "=======================================" -WriteHost -Color Cyan
Write-PipelineLog "         SIMULATED CI/CD PIPELINE" -WriteHost -Color Cyan
Write-PipelineLog "=======================================" -WriteHost -Color Cyan
Write-PipelineLog "" -Level '' -WriteHost

try {

    Write-PipelineLog ">>> Step 1: Checking Environment..." -WriteHost -Color Yellow
    if (-not (Test-PipelineEnvironment -Directories $pipelineConfig.Folders)) { 
        throw "Environment check failed." 
    }

    Write-PipelineLog ">>> Step 2: Pulling Source..." -WriteHost -Color Yellow
    if (-not (Update-ProjectSource)) { 
        throw "Source pull failed." 
    }

    Write-PipelineLog ">>> Step 3: Validating Assets..." -WriteHost -Color Yellow
    if (-not (Invoke-Validation -Directories $pipelineConfig.Folders)) { 
        throw "Asset validation failed." 
    }

    Write-PipelineLog ">>> Step 4: Compiling Build..." -WriteHost -Color Yellow
    $BuildResult = Invoke-Build `
                        -Modules $pipelineConfig.BuildModules `
                        -ProjectName $pipelineConfig.ProjectName

    if (-not $BuildResult) {
        throw "Build failed."
    }

    Write-PipelineLog ">>> Step 5: Running Automated Tests..." -WriteHost -Color Yellow

    $testResults = Invoke-Tests -Tests $pipelineConfig.Tests

    if ($testResults.Failed -gt 0) {
        throw "Automated tests failed."
    }

    Write-PipelineLog ">>> Step 6: Packaging..." -WriteHost -Color Yellow

    $artifactPath = Invoke-Packaging -ProjectName $pipelineConfig.ProjectName

    if (-not $artifactPath) {
        throw "Packaging failed."
    }

    Write-PipelineLog ">>> Step 7: Generating Build Report..." -WriteHost -Color Yellow

    New-BuildReport `
        -PipelineResult "SUCCESS" `
        -TestsPassed $testResults.Passed `
        -TestsFailed $testResults.Failed `
        -ArtifactPath $artifactPath

    Write-PipelineLog "" -Level '' -WriteHost
    Write-PipelineLog "=======================================" -WriteHost -Color Green
    Write-PipelineLog "     PIPELINE COMPLETED SUCCESSFULLY" -WriteHost -Color Green
    Write-PipelineLog "=======================================" -WriteHost -Color Green
    Write-PipelineLog "" -Level '' -WriteHost
    Write-PipelineLog "Pipeline completed successfully"

} catch {

    Write-PipelineLog "" -Level '' -WriteHost
    Write-PipelineLog "=======================================" -WriteHost -Color Red
    Write-PipelineLog "           PIPELINE ABORTED" -WriteHost -Color Red
    Write-PipelineLog "=======================================" -WriteHost -Color Red
    Write-PipelineLog "$($_.Exception.Message)" -WriteHost -Color Red

    Write-PipelineLog "Pipeline aborted: $($_.Exception.Message)"

    return $false
}