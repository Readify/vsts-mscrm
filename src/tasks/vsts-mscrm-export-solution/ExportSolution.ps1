[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectedServiceName,
    
    [String] [Parameter(Mandatory = $true)]
    $solutionName,

    [String] [Parameter(Mandatory = $true)]
    $publisherName,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportAsManaged,
    
    [String] [Parameter(Mandatory = $true)]
    $zipFile,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportAutoNumberingSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportCalendarSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportCustomizationSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportEmailTrackingSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportGeneralSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportMarketingSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportOutlookSynchronizationSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportRelationshipRolesSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportIsvConfigSettings,
    
    [Boolean] [Parameter(Mandatory = $true)]
    $exportSalesSettings            
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host "connectedServiceName=$connectedServiceName"
Write-Host "solutionName=$solutionName"
Write-Host "publisherName=$publisherName"
Write-Host "exportAsManaged=$exportAsManaged"
Write-Host "zipFile=$zipFile"
Write-Host "exportAutoNumberingSettings=$exportAutoNumberingSettings"
Write-Host "exportCalendarSettings=$exportCalendarSettings"
Write-Host "exportCustomizationSettingsx=$exportCustomizationSettings"
Write-Host "exportEmailTrackingSettings=$exportEmailTrackingSettings"
Write-Host "exportGeneralSettings=$exportGeneralSettings"
Write-Host "exportMarketingSettings=$exportMarketingSettings"
Write-Host "exportOutlookSynchronizationSettings=$exportOutlookSynchronizationSettings"
Write-Host "exportRelationshipRolesSettings=$exportRelationshipRolesSettings"
Write-Host "exportIsvConfigSettings=$exportIsvConfigSettings"
Write-Host "exportSalesSettings=$exportSalesSettings"
    
Write-Output "Getting service endpoint..."
$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

$url = $serviceEndpoint.Url
$username = $serviceEndpoint.Authorization.Parameters.UserName
$password = $serviceEndpoint.Authorization.Parameters.Password

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Write-Output "Importing PowerShell Module..."
Add-Type -Path .\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Tooling.Connector.dll
Import-Module .\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psm1
$connection = Connect-CrmOnline -ServerUrl $url -Credential $credential
Write-Host "Connected Org Version is $($connection.ConnectedOrgVersion)"