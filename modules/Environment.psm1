#Environment.psm1
function Test-PipelineEnvironment {

    param(
        [array]$Directories
    )

    Write-PipelineLog "[1/7] Environment Validation" -WriteHost

    $requiredTools = @("git")

    foreach ($tool in $requiredTools) {
        try {
            $gitInstalled = [bool](Get-Command $tool -ErrorAction SilentlyContinue)

            if ($gitInstalled) {
                Write-PipelineLog "[PASS] $tool installed" -WriteHost -Color Green
            } else {
                Write-PipelineLog "$tool NOT installed... Please install to continue." -ErrorAction Stop
            }

        } catch {

            Write-PipelineLog "$($_.Exception.Message)" -Level 'ERROR' -WriteHost

            return $false

        }
    }

    foreach ($folder in $Directories) {
        $folderPath = Join-Path (Split-Path $PSScriptRoot -Parent) $folder

        try {
            if (-not (Test-Path $folderPath)) {
                Write-PipelineLog "Creating $folder directory..." -WriteHost
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            }
            Write-PipelineLog "[PASS] $folder directory ready" -WriteHost -Color Green

        } catch {

            Write-PipelineLog "$($_.Exception.Message)" -Level 'ERROR' -WriteHost

            return $false

        }
    }

    Write-PipelineLog "" -Level '' -WriteHost
    Write-PipelineLog " -- All TOOLS and DIRECTORIES are available! -- " -WriteHost -Color Green
    Write-PipelineLog "" -Level '' -WriteHost

    return $true
}

Export-ModuleMember -Function Test-PipelineEnvironment