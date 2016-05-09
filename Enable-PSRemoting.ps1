$ErrorActionPreference = "Stop"

try
{
    Write-Output "Setting all network connection profiles to Private"
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction Stop

    Write-Output "Enabling Powershell Remoting"
    Enable-PSRemoting -Force -ErrorAction Stop
}
catch
{
    Write-Output "Error enabling PS Remoting on the VM" + $_.Exception.Message
    throw
}
