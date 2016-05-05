# Initialize module wide variables. These variables must be referenced with script scoping (i.e., $script:PasswordKey)

# TODO: This should be probably stored in a file as an encrypted string
$PasswordKey = (65,82,84,73,67,85,76,65,84,69,8,8,8,8,8,8)
$TemplateFile = ".\azuredeploy.json"
$TemplateParameterFile = ".\azuredeploy.parameters.json"

# Get public and private function file paths.
$publicFiles  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$privateFiles = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot import the function files
foreach($importFile in @($publicFiles + $privateFiles))
{
    try
    {
        . $importFile.FullName
    }
    catch
    {
        Write-Error -Message "Failed to import function $($importFile.FullName): $_"
    }
}

#Export public functions
Export-ModuleMember -Function $publicFiles.BaseName