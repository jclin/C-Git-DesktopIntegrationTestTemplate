function New-AzureResourceGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [string] $ResourceGroupLocation = "West US"
    )

    Write-Output "Creating resource group '$ResourceGroupName' at '$ResourceGroupLocation' to contain the VM and dependent resources"

    $existingResourceGroup = Find-AzureRmResourceGroup -Tag @{ Name="Purpose";Value="Integration Testing" }
    if ($existingResourceGroup)
    {
        throw "Resource group '$ResourceGroupName' at '$ResourceGroupLocation' already exists"
    }

    $resourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Tag @{ Name="Purpose";Value="Integration Testing" } -Force
    if (!$resourceGroup)
    {
        throw "Failed to create resource group '$ResourceGroupName' at '$ResourceGroupLocation'"
    }

    if ($resourceGroup.ProvisioningState -ne "Succeeded")
    {
        throw "Provisioning failed for resource group $ResourceGroupName at $ResourceGroupLocation"
    }
}