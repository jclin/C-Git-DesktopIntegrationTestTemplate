function New-AzureVMDeployment
{
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
        [string] $ResourceGroupName,

        [string] $ResourceGroupLocation = "West US"
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

        New-AzureResourceGroup -ResourceGroupName $ResourceGroupName -ResourceGroupLocation $ResourceGroupLocation

        New-AzureResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $script:TemplateFile -TemplateParameterFile $script:TemplateParameterFile

        $vmDomainName = Get-VMDomainName $ResourceGroupName
        Add-VMDomainNameToTrustedHostsList $vmDomainName
    }
    catch
    {
        Write-Warning -Message "An error occurred for deployment. '$ResourceGroupName' will be deleted..."
        Remove-AzureResourceGroup $ResourceGroupName

        throw
    }
}