function Remove-VMDomainNameFromTrustedHostsList
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $DomainName
    )

    Write-Debug -Message "Domain name of the VM to remove is '$DomainName'"

    if ((Get-Item WSMan:localhost\Client\TrustedHosts).Value.CompareTo("*") -eq 0)
    {
        Write-Debug "The client trusts all hosts ('*' was specified), no need to remove '$DomainName' from the list"
        return;
    }

    $currentTrustedHostsArray = (Get-Item WSMan:localhost\Client\TrustedHosts).Value -split ","

    if (!$currentTrustedHostsArray.Contains($DomainName))
    {
        Write-Debug -Message "$DomainName is not in the trusted hosts list"
        return;
    }

    $trustedHostsArrayList = [System.Collections.ArrayList]($currentTrustedHostsArray);
    $trustedHostsArrayList.Remove($DomainName)
    $newTrustedHostsString = $trustedHostsArrayList -join ","

    Set-Item WSMan:\localhost\Client\TrustedHosts $newTrustedHostsString -Force
    Write-Debug -Message "Removed '$DomainName' from the trusted hosts list"
    Write-Debug -Message "Trusted hosts list is now = '$newTrustedHostsString'"
}