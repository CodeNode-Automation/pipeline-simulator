#SourceControl.psm1
function Update-Source {

    Write-PipelineLog "- Fetching latest source..." -Level 'DEBUG' -WriteHost

    try {

        if ($env:GITHUB_ACTIONS) {

            Write-PipelineLog "CI environment detected (GitHub Actions) - skipping git pull." -Level 'DEBUG' -WriteHost

        }
        else {

            $pullOutput = git pull 2>&1

            if ($LASTEXITCODE -ne 0) {

                Write-PipelineLog "Git pull failed. Are you in a valid git repository?" -Level 'ERROR' -WriteHost

                return $false
            }

            Write-PipelineLog "  > $pullOutput" -Level 'DEBUG' -WriteHost
        }

        $commit  = git rev-parse --short HEAD
        $branch  = git rev-parse --abbrev-ref HEAD
        $author  = git log -1 --pretty=format:'%an'
        $date    = git log -1 --pretty=format:'%cd' --date=relative
        $message = git log -1 --pretty=format:'%s'

        Write-PipelineLog "[PASS] Source synchronized at commit $commit" -WriteHost -Color Green
        Write-PipelineLog "       Branch:  $branch" -WriteHost -Color Cyan
        Write-PipelineLog "       Author:  $author" -WriteHost -Color Cyan
        Write-PipelineLog "       Date:    $date" -WriteHost -Color Cyan
        Write-PipelineLog "       Message: $message" -WriteHost -Color Cyan

        return $true

    } catch {

        Write-PipelineLog "Failed to execute git command: $($_.Exception.Message)" -Level 'ERROR' -WriteHost

        return $false
    }
}

function Update-ProjectSource {

    Write-PipelineLog "[2/7] Updating Source" -WriteHost

    if (-not (Update-Source)) {

        return $false
        
    }

    Write-PipelineLog "" -Level '' -WriteHost
    
    return $true
}

Export-ModuleMember -Function Update-ProjectSource