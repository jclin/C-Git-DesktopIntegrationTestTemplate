function Add-VMDomainNameToTrustedHostsList
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $DomainName
    )

    Write-Debug -Message "Domain name of the VM to add is '$DomainName'"

    if ((Get-Item WSMan:localhost\Client\TrustedHosts).Value.CompareTo("*") -eq 0)
    {
        Write-Debug "The client trusts all hosts ('*' was specified), no need to add '$DomainName' to the list"
        return;
    }

    $currentTrustedHostsArray = (Get-Item WSMan:localhost\Client\TrustedHosts).Value -split ","

    if ($currentTrustedHostsArray.Contains($DomainName))
    {
        Write-Debug -Message "$DomainName is already in the trusted hosts list"
        return;
    }

    Set-Item WSMan:\localhost\Client\TrustedHosts $DomainName -Concatenate -Force
    Write-Debug -Message "Added '$DomainName' to the trusted hosts list"
}