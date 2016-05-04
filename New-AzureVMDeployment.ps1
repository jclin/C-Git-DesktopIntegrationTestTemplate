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

# Work-around for a PShell bug where the exit code is always 0 when running PShell with the -File parameter
# See: http://stackoverflow.com/questions/15777492/why-are-my-powershell-exit-codes-always-0
trap
{
    Write-Error -Message ($_ | Format-List -Force | Out-String)
    exit 1
}

$templateFile = ".\azuredeploy.json"
$templateParamterFile = ".\azuredeploy.parameters.json"

# TODO: This should be probably stored in a file as an encrypted string
$passwordKey = (65,82,84,73,67,85,76,65,84,69,8,8,8,8,8,8)

function Get-SecurePassword([string] $PasswdPath)
{
    return ConvertTo-SecureString (Get-Content -Path $PasswdPath) -Key $passwordKey
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

function Remove-AzureResourceGroup([string] $ResourceGroupName)
{
    Write-Debug -Message "Removing resource group '$ResourceGroupName'"

    $existingResourceGroup = Find-AzureRmResourceGroup -Tag @{ Name="Purpose";Value="Integration Testing" }
    if (!$existingResourceGroup)
    {
        Write-Debug -Message "Resource group '$ResourceGroupName' doesn't exist, no removal needed"
        return
    }

    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
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

function Add-VMDomainNameToTrustedHostsList([string] $domainName)
{
    Write-Debug -Message "Domain name of the VM to add is '$domainName'"

    if ((Get-Item WSMan:localhost\Client\TrustedHosts).Value.CompareTo("*") -eq 0)
    {
        Write-Debug "The client trusts all hosts ('*' was specified), no need to add '$domainName' to the list"
        return;
    }

    $currentTrustedHostsArray = (Get-Item WSMan:localhost\Client\TrustedHosts).Value -split ","

    if ($currentTrustedHostsArray.Contains($domainName))
    {
        Write-Debug -Message "$domainName is already in the trusted hosts list"
        return;
    }

    Set-Item WSMan:\localhost\Client\TrustedHosts $domainName -Concatenate -Force
    Write-Debug -Message "Added '$domainName' to the trusted hosts list"
}

$ErrorActionPreference = "Stop"

# Ensures any errors encountered are from within this script
$Error.Clear()

# Uncomment the line below to view debug output
$DebugPreference = "Continue"

try
{
    Set-StrictMode -Version Latest

    # jclin: Purposely throwing an error to get TC builds to actually fail
    1/0

    # $securePassword = Get-SecurePassword $PasswordFilePath
    # Login-AzureAccount $UserName $securePassword $SubscriptionId

    # New-AzureResourceGroup $ResourceGroupName $ResourceGroupLocation

    # New-AzureResourceGroupDeployment $ResourceGroupName $templateFile $templateParamterFile

    # $vmDomainName = Get-VMDomainName $ResourceGroupName
    # Add-VMDomainNameToTrustedHostsList $vmDomainName
}
catch
{
    Write-Debug -Message "An error occurred for deployment. '$ResourceGroupName' will be deleted..."
    Remove-AzureResourceGroup $ResourceGroupName

    throw
}
