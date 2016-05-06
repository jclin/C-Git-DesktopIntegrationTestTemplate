function Remove-AzureVMDeployment
{
    [CmdletBinding()]
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

        $securePassword = Get-SecurePassword -PasswdPath $PasswordFilePath -PasswordKey $script:PasswordKey
        Login-AzureAccount -UserName $UserName -SecurePassword $securePassword -SubscriptionId $SubscriptionId

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