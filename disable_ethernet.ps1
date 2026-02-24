$timeoutSeconds = 120
$start = Get-Date

do {
    $eth = Get-NetAdapter |
        Where-Object {
            $_.HardwareInterface -and
            ($_.Name -match "Ethernet" -or $_.InterfaceDescription -match "Ethernet")
        }

    if ($eth) { break }

    Start-Sleep -Seconds 5
} while ((Get-Date) - $start -lt [TimeSpan]::FromSeconds($timeoutSeconds))

if ($eth) {
    $eth | Where-Object { $_.Status -ne "Disabled" } |
        Disable-NetAdapter -Confirm:$false
}
