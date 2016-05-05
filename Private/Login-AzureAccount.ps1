function Login-AzureAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $UserName,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString] $SecurePassword,

        [Parameter(Mandatory = $true)]
        [string] $SubscriptionId
    )

    Write-Debug -Message "Logging into Azure account as '$UserName' with subscription id='$SubscriptionId'"

    $credentials = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

    Login-AzureRmAccount -Credential $credentials -SubscriptionId $SubscriptionId
}