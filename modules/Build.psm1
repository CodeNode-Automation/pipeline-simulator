#Build.psm1
function Start-ProjectBuild {

    param(
        [array]$Modules
    )

    Write-PipelineLog "  Build target: x64 | Configuration: Release" -Level 'DEBUG' -WriteHost
    Write-PipelineLog "" -Level '' -WriteHost

    foreach ($module in $Modules) {

        Write-PipelineLog "- Compiling $module..." -Level 'DEBUG' -WriteHost
        
        $fakeComponents = @("Core", "Data", "Interface")
        
        foreach ($component in $fakeComponents) {
            Start-Sleep -Milliseconds (Get-Random -Minimum 200 -Maximum 600)
            Write-PipelineLog "    -> $module.$component.obj" -Level 'DEBUG' -WriteHost
        }

        Write-PipelineLog "  [OK] $module built successfully." -WriteHost -Color Green
        Write-PipelineLog "" -Level '' -WriteHost
    }

    return $true
}

function Invoke-Build {

    param(
        [array]$Modules,
        [string]$ProjectName
    )

    Write-PipelineLog "[4/7] Building Project" -WriteHost

    try {

        $start = Get-Date

        $buildResult = Start-ProjectBuild -Modules $Modules

        $buildTime = (Get-Date) - $start

        if ($buildResult) {

            Write-PipelineLog "[PASS] Build completed successfully" -WriteHost -Color Green
            Write-PipelineLog "Build time: $([Math]::Round($buildTime.TotalSeconds,2)) seconds" -WriteHost

            $rootPath = Split-Path $PSScriptRoot -Parent
            $buildDir = Join-Path $rootPath "build"

            if (-not (Test-Path $buildDir)) {
                New-Item $buildDir -ItemType Directory -Force | Out-Null
            }

            $buildFile = "$($ProjectName)_build.exe"
            $fullBuildPath = Join-Path $buildDir $buildFile

            New-Item $fullBuildPath -ItemType File -Force | Out-Null

            Write-PipelineLog "Build artifact created: $fullBuildPath" -WriteHost
            Write-PipelineLog "" -Level '' -WriteHost

            return $true

        }
        else {

            Write-PipelineLog  "[FAIL] Build failed" -WriteHost -Color Red
            return $false

        }

    }
    catch {

        Write-PipelineLog  "$($_.Exception.Message)" -WriteHost -Color Red
        return $false

    }

}

Export-ModuleMember -Function Invoke-Build