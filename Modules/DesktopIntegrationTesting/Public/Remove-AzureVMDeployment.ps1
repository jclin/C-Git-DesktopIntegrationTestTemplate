function Remove-AzureVMDeployment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credentials,

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

        Disable-AzureDataCollection

        Login-AzureRmAccount -Credential $Credentials -SubscriptionId $SubscriptionId

        $vmDomainName = Get-VMDomainName $ResourceGroupName
        Remove-VMDomainNameFromTrustedHostsList $vmDomainName

        Remove-AzureResourceGroup $ResourceGroupName
    }
    catch
    {
        Write-Warning "Error removing Azure deployment for resource group '$ResourceGroupName'"
        throw
    }
}