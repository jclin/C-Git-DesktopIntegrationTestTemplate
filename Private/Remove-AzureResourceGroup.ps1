function Remove-AzureResourceGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )

    Write-Output "Removing resource group '$ResourceGroupName'"

    $existingResourceGroup = Find-AzureRmResourceGroup -Tag @{ Name="Purpose";Value="Integration Testing" }
    if (!$existingResourceGroup)
    {
        Write-Output "Resource group '$ResourceGroupName' doesn't exist, no removal needed"
        return
    }

    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
}