# === Config ===
$ThresholdSeconds = 300
$CheckIntervalSeconds = 10

# === Win32 idle time ===
Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class IdleTime {
    [StructLayout(LayoutKind.Sequential)]
    struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static uint GetIdleMilliseconds() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(lii);
        GetLastInputInfo(ref lii);
        return ((uint)Environment.TickCount - lii.dwTime);
    }
}
"@

$LastRequestTime = Get-Date

function Test-ActivePowerRequest {
    $out = powercfg /requests 2>$null
    if (-not $out) { return $false }

    # Split output into lines
    $lines = $out -split "`r?`n"

    $currentCategory = ""
    $currentContent = @()
    foreach ($line in $lines + "") {  # Add empty line to flush last block
        if ($line -match "^(DISPLAY|SYSTEM|AWAYMODE|EXECUTION|PERFBOOST|ACTIVELOCKSCREEN):") {
            # Process previous category
            if ($currentCategory -and ($currentContent -join "`n") -notmatch "None\." ) {
                return $true
            }
            # Start new category
            $currentCategory = $line.TrimEnd(":")
            $currentContent = @()
        } else {
            if ($line.Trim()) { $currentContent += $line }
        }
    }

    # Final block check
    if ($currentCategory -and ($currentContent -join "`n") -notmatch "None\." ) {
        return $true
    }

    return $false
}


Write-Host "Idle shutdown monitor started..."

while ($true) {

    $now = Get-Date
    $idleMs = [IdleTime]::GetIdleMilliseconds()
    $userIdleSec = [math]::Floor($idleMs / 1000)

    $activeRequest = Test-ActivePowerRequest
    if ($activeRequest) {
        $LastRequestTime = $now
    }

    $requestIdleSec = ($now - $LastRequestTime).TotalSeconds

    Write-Host ("{0:T} | UserIdle={1}s | RequestIdle={2:n0}s | ActiveRequest={3}" -f `
        $now, $userIdleSec, $requestIdleSec, $activeRequest)

    if ($userIdleSec -ge $ThresholdSeconds -and
        $requestIdleSec -ge $ThresholdSeconds) {

        Write-Host "Shutdown triggered."
        shutdown.exe /s /t 0
        break
    }

    Start-Sleep -Seconds $CheckIntervalSeconds
}
