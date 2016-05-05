function Get-VMDomainName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string] $ResourceGroupName
    )

    return ((Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName).DnsSettings.Fqdn)
}