function Get-SecurePassword
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $PasswdPath,

        [Parameter(Mandatory = $true)]
        [Byte[]] $PasswordKey
    )

    return ConvertTo-SecureString (Get-Content -Path $PasswdPath) -Key $PasswordKey
}