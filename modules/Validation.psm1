#Validation.psm1
function Test-ProjectStructure {
    param(
        [array]$Directories
    )

    foreach ($dir in $Directories) {
        # Create the raw path
        $rawPath = Join-Path (Split-Path $PSScriptRoot -Parent) $dir

        if (Test-Path $rawPath) {
            $cleanPath = (Resolve-Path $rawPath).Path
            Write-PipelineLog "[PASS] Directory '$dir' exists at: $cleanPath" -WriteHost -Color Green
        }
        else {
            Write-PipelineLog "[FAIL] Directory '$dir' missing!" -WriteHost -Color Red
            Write-PipelineLog "       Expected at: $rawPath" -Level 'DEBUG' -WriteHost
            
            return $false
        }
    }

    return $true

}

function Test-ProjectConfig {

    $configFile = Join-Path (Split-Path $PSScriptRoot -Parent) "\config\pipeline.config.json"
    
    if (Test-Path $configFile) {
        $actualPath = (Resolve-Path $configFile).Path
        Write-PipelineLog "[PASS] Config file found: $actualPath" -WriteHost -Color Green
        return $true
    }
    else {
        Write-PipelineLog "[FAIL] Config file missing: $configFile" -WriteHost -Color Red
        return $false
    }
}

function Invoke-Validation {

    param(
        [array]$Directories
    )

    Write-PipelineLog "[3/7] Running Validation Checks" -WriteHost

    if (-not (Test-ProjectStructure -Directories $Directories)) {
        Write-PipelineLog "Project structure validation failed." -Level 'ERROR' -WriteHost
        return $false
    }

    if (-not (Test-ProjectConfig)) {
        Write-PipelineLog "Config validation failed." -Level 'ERROR' -WriteHost
        return $false
    }

    Write-PipelineLog "[PASS] Validation checks passed." -WriteHost -Color Green
    Write-PipelineLog "" -Level '' -WriteHost

    return $true
}

Export-ModuleMember -Function Invoke-Validation