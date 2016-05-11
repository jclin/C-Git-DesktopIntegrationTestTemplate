$ErrorActionPreference = "Stop"

try
{
    Write-Output "Setting all network connection profiles to Private"
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

    Write-Output "Enabling Powershell Remoting"
    Enable-PSRemoting -Force

    Write-Output "Setting up a custom PSSessionConfig for sending large files over a remote session"
    Register-PSSessionConfiguration -Name "Articulate.PSSessionConfig" -Force
    Set-PSSessionConfiguration -Name "Articulate.PSSessionConfig" -MaximumReceivedDataSizePerCommandMB 500 -MaximumReceivedObjectSizeMB 500 -Force
}
catch
{
    Write-Output $_.Exception
    throw
}