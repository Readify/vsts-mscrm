[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectionString,

    [String] [Parameter(Mandatory = $true)]
    $zipFile
)

Write-Host "connectionString=$connectionString"
Write-Host "zipFile=$zipFile"

Add-Type -Path "$PSScriptRoot\tools\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
Add-Type -Path "$PSScriptRoot\tools\Microsoft.Xrm.Sdk.dll"
Add-Type -Path "$PSScriptRoot\tools\Microsoft.Xrm.Sdk.Deployment.dll"
Add-Type -Path "$PSScriptRoot\tools\Microsoft.Xrm.Tooling.Connector.dll"

$client = New-Object -Type Microsoft.Xrm.Tooling.Connector.CrmServiceClient -Args $connectionString
$client