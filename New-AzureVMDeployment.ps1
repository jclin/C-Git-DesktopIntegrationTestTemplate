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

    [Parameter(Mandatory = $false)]
    [string] $ResourceGroupLocation = "West US"
)

$templateFile = ".\azuredeploy.json"
$templateParamterFile = ".\azuredeploy.parameters.json"

function Get-SecurePassword([string] $PasswdPath)
{
    return ConvertTo-SecureString (Get-Content -Path $PasswdPath)
}

function Login-AzureAccount([string] $UserName, [System.Security.SecureString] $SecurePassword, [string] $SubscriptionId)
{
    Write-Debug -Message "Logging into Azure account as '$UserName' with subscription id='$SubscriptionId'"

    $credentials = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

    Login-AzureRmAccount -Credential $credentials -SubscriptionId $SubscriptionId
}

function New-AzureResourceGroup([string] $ResourceGroupName, [string] $ResourceGroupLocation)
{
    Write-Debug -Message "Creating resource group '$ResourceGroupName' at '$ResourceGroupLocation' to contain the VM and dependent resources"

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

function New-AzureResourceGroupDeployment([string] $ResourceGroupName, [string] $TemplateFile, [string] $TemplateParameterFile)
{
    Write-Debug -Message "Deploying resource group '$ResourceGroupName' at '$ResourceGroupLocation'"

    $deployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParamterFile -Force
    if ($deployment.ProvisioningState -ne "Succeeded")
    {
        throw "Failed to deploy the VM to the $ResourceGroupName resource group"
    }
}

function Get-VMDomainName([string] $ResourceGroupName)
{
    return ((Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName).DnsSettings.Fqdn)
}

function Add-VMDomainNameToTrustedHostsList([string] $domainName, [string] $ResourceGroupName)
{
    Write-Debug -Message "Domain name of the VM to add is '$domainName'"

    $currentTrustedHostsArray = (Get-Item WSMan:localhost\Client\TrustedHosts).Value -split ","

    if ($currentTrustedHostsArray.Contains($domainName))
    {
        Write-Debug -Message "$domainName is already in the trusted hosts list"
        return;
    }

    $trustedHostsArray = $currentTrustedHostsArray += $domainName

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value ($trustedHostsArray -join ",") -Force
    $currentTrustedHostsString = (Get-Item WSMan:localhost\Client\TrustedHosts).Value
    Write-Debug -Message "Added VM's domain to the list of trusted hosts. The list is now= '$currentTrustedHostsString'"
}

$ErrorActionPreference = "Stop"
# Uncomment the line below to view debug output
# $DebugPreference = "Continue"
try
{
    Set-StrictMode -Version Latest

    $securePassword = Get-SecurePassword $PasswordFilePath
    Login-AzureAccount $UserName $securePassword $SubscriptionId

    New-AzureResourceGroup $ResourceGroupName $ResourceGroupLocation

    New-AzureResourceGroupDeployment $ResourceGroupName $templateFile $templateParamterFile

    $vmDomainName = Get-VMDomainName $ResourceGroupName
    Add-VMDomainNameToTrustedHostsList $vmDomainName $ResourceGroupName
}
catch
{
    Write-Debug -Message $_.Exception
    Write-Debug -Message "Deleting the resource group '$ResourceGroupName'"
    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force

    throw $_.Exception
}
