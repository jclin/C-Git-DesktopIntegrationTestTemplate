[CmdletBinding(PositionalBinding = $false)]
param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $CredentialsName,

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

    Import-Module .\Modules\StoredCredential\StoredCredential.psm1
    Import-Module .\Modules\DesktopIntegrationTesting\DesktopIntegrationTesting.psm1

    $credentials = Get-StoredCredential -Name $CredentialsName
    Remove-AzureVMDeployment -Credentials $credentials -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
}
catch
{
    Write-Output ($_ | Format-List -Force | Out-String)

    exit 1
}
finally
{
    Remove-Module StoredCredential
    Remove-Module DesktopIntegrationTesting
}