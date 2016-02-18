[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $zipFile
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host "connectedServiceName=$connectedServiceName"
Write-Host "zipFile=$zipFile"

Write-Output "Getting service endpoint..."
$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

$url = $serviceEndpoint.Url
$username = $serviceEndpoint.Authorization.Parameters.UserName
$password = $serviceEndpoint.Authorization.Parameters.Password

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -Args $username, $securePassword

Write-Output "Importing PowerShell Module..."
Import-Module .\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psm1
$connection = Connect-CrmOnline -ServerUrl $url -Credential $credential
$connection | Format-List