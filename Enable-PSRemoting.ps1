try
{
    Write-Debug "Setting all network connection profiles to Private"
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction Stop

    Write-Debug "Enabling Powershell Remoting"
    Enable-PSRemoting -Force -ErrorAction Stop
}
catch
{
    Write-Debug $_.Exception
    throw
}