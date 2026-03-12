#Logging.psm1
function Write-PipelineLog {

    param(
        [Parameter(Mandatory=$false)]
        [string]$Message,
        
        [ValidateSet('INFO', 'ERROR', 'DEBUG', '')]
        [string]$Level = 'INFO',

        [switch]$WriteHost,
        [string]$Color
    )

    $logDir = Join-Path (Split-Path $PSScriptRoot -Parent) "logs"

    if (-not (Test-Path $logDir)) {
        New-Item $logDir -ItemType Directory -Force | Out-Null
    }

    $logFile = Join-Path $logDir "pipeline.log"

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"

    if ([string]::IsNullOrWhiteSpace($Message)) {
        $entry = "" 
    } else {
        $entry = "[$timestamp] [$($Level.PadRight(5))] $Message"
    }

    if ($WriteHost) {

        $levelKey = $Level.ToUpper().Trim()

        $chosenColor = switch ($levelKey) {
            'INFO'  { 'Yellow' }
            'ERROR' { 'Red' }
            'DEBUG' { 'Gray' }
            Default { 'White' }
        }

        if (-not $Color) { $Color = $chosenColor }

        if ([string]::IsNullOrWhiteSpace($Level)) {
            Write-Host $Message -ForegroundColor $Color
        } else {
            Write-Host "[$($Level.PadRight(5))] $Message" -ForegroundColor $Color
        }
    }

    Add-Content -Path $logFile -Value $entry
}

Export-ModuleMember -Function Write-PipelineLog