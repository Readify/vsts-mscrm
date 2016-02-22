[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectedServiceName,
    
    [String] [Parameter(Mandatory = $false)]
    $solutionFilePath,
    
    [String] [Parameter(Mandatory = $true)]
    $activatePlugIns,
    
    [String] [Parameter(Mandatory = $true)]
    $overwriteUnManagedCustomizations,
    
    [String] [Parameter(Mandatory = $true)]
    $skipDependancyOnProductUpdateCheckOnInstall,
    
    [String] [Parameter(Mandatory = $true)]
    $publishChanges
)

$ErrorActionPreference = "Stop"

$taskMetadata = ConvertFrom-Json -InputObject $(Get-Content $PSScriptRoot\task.json -raw)
Write-Host "Task version is: $($taskMetadata.version)"

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

[Boolean]$activatePlugIns = Convert-String $activatePlugIns Boolean
[Boolean]$overwriteUnManagedCustomizations = Convert-String $overwriteUnManagedCustomizations Boolean
[Boolean]$skipDependancyOnProductUpdateCheckOnInstall = Convert-String $skipDependancyOnProductUpdateCheckOnInstall Boolean
[Boolean]$publishChanges = Convert-String $publishChanges Boolean

Write-Host "connectedServiceName is: $connectedServiceName"
Write-Host "solutionFilePath is: $solutionFilePath"
Write-Host "activatePlugIns is: $activatePlugIns"
Write-Host "overwriteUnManagedCustomizations is: $overwriteUnManagedCustomizations"
Write-Host "skipDependancyOnProductUpdateCheckOnInstall is: $skipDependancyOnProductUpdateCheckOnInstall"
Write-Host "publishChanges is: $publishChanges"
    
Write-Host "Getting service endpoint..."
$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

$url = $serviceEndpoint.Url
Write-Host "url is: $url"

$username = $serviceEndpoint.Authorization.Parameters.UserName
Write-Host "username is: $username"

$password = $serviceEndpoint.Authorization.Parameters.Password

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Write-Host "Importing PowerShell Module..."
Add-Type -Path $PSScriptRoot\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Tooling.Connector.dll
Import-Module $PSScriptRoot\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psm1

Write-Host "Connecting to CRM..."
$connection = Connect-CrmOnline -ServerUrl $url -Credential $credential
Write-Host "ConnectedOrgFriendlyName is: $($connection.ConnectedOrgFriendlyName)"
Write-Host "ConnectedOrgVersion is: $($connection.ConnectedOrgVersion)"