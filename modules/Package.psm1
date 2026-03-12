#Package.psm1
function New-BuildArtifact {

    param(
        [string]$ProjectName
    )
    
    $artifactsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "artifacts"

    if (-not (Test-Path $artifactsDir)) {
        New-Item -ItemType Directory -Path $artifactsDir -Force | Out-Null
    }

    $artifactsFile = Join-Path $artifactsDir "$($ProjectName)-App.exe"

    Write-PipelineLog "- Generating build output..." -WriteHost
    New-Item $artifactsFile -ItemType File -Force | Out-Null

    return $artifactsDir
}


function Compress-BuildArtifact {

    param(
        [string]$BuildDirectory,
        [string]$ProjectName
    )

    $artifactDir = Join-Path (Split-Path $PSScriptRoot -Parent) "artifacts"

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $zipName = "$($ProjectName)_$timestamp.zip"

    $zipPath = Join-Path $artifactDir $zipName

    Write-PipelineLog "- Packaging artifact..." -WriteHost

    Compress-Archive -Path "$BuildDirectory\*" -DestinationPath $zipPath -Force

    return $zipPath
}


function Invoke-Packaging {

    param(
        [string]$ProjectName
    )

    Write-PipelineLog "[6/7] Packaging Build Artifact" -WriteHost

    try {

        $buildDir = New-BuildArtifact -ProjectName $ProjectName

        $artifact = Compress-BuildArtifact `
                        -BuildDirectory $buildDir `
                        -ProjectName $ProjectName

        Write-PipelineLog "[PASS] Artifact created successfully" -WriteHost -Color Green
        $cleanPath = (Resolve-Path $artifact).Path
        Write-PipelineLog "Artifact location: $cleanPath" -WriteHost
        Write-PipelineLog "" -Level '' -WriteHost

        return $cleanPath

    }
    catch {

        Write-PipelineLog "$($_.Exception.Message)" -Level 'ERROR' -WriteHost
        return $false

    }

}

Export-ModuleMember -Function Invoke-Packaging