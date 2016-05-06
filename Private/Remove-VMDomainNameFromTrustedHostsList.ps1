function Remove-VMDomainNameFromTrustedHostsList
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $DomainName
    )

    Write-Output "Domain name of the VM to remove is '$DomainName'"

    if ((Get-Item WSMan:localhost\Client\TrustedHosts).Value.CompareTo("*") -eq 0)
    {
        Write-Output "The client trusts all hosts ('*' was specified), no need to remove '$DomainName' from the list"
        return;
    }

    $currentTrustedHostsArray = (Get-Item WSMan:localhost\Client\TrustedHosts).Value -split ","

    if (!$currentTrustedHostsArray.Contains($DomainName))
    {
        Write-Output "$DomainName is not in the trusted hosts list"
        return;
    }

    $trustedHostsArrayList = [System.Collections.ArrayList]($currentTrustedHostsArray);
    $trustedHostsArrayList.Remove($DomainName)
    $newTrustedHostsString = $trustedHostsArrayList -join ","

    Set-Item WSMan:\localhost\Client\TrustedHosts $newTrustedHostsString -Force
    Write-Output "Removed '$DomainName' from the trusted hosts list"
    Write-Output "Trusted hosts list is now = '$newTrustedHostsString'"
}