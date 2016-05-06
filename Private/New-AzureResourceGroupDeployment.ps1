function New-AzureResourceGroupDeployment
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $TemplateFile,

        [Parameter(Mandatory = $true)]
        [string] $TemplateParameterFile
    )

    Write-Output "Deploying resource group '$ResourceGroupName' at '$ResourceGroupLocation'"

    $deployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParameterFile -Force
    if ($deployment.ProvisioningState -ne "Succeeded")
    {
        throw "Failed to deploy the VM to the $ResourceGroupName resource group"
    }
}