[CmdletBinding(PositionalBinding = $false)]
param
(
    [Parameter(Mandatory = $true)]
    [string] $UserName,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string] $PasswordFilePath,

    [Parameter(Mandatory = $true)]
    [string] $SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName
)

# Force non-terminating errors to throw
$ErrorActionPreference = "Stop"

# Ensures any errors encountered are from within this script
$Error.Clear()

try
{
    Set-StrictMode -Version Latest

    Import-Module .\DesktopIntegrationTesting.psm1

    Remove-AzureVMDeployment -UserName $UserName -PasswordFilePath $PasswordFilePath -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
}
catch
{
    Write-Output ($_ | Format-List -Force | Out-String)

    exit 1
}