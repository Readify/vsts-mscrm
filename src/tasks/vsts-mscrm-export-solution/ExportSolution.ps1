[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectedServiceName,
    
    [String] [Parameter(Mandatory = $true)]
    $solutionName,

    [String] [Parameter(Mandatory = $true)]
    $exportAsManaged,
    
    [String] [Parameter(Mandatory = $true)]
    $exportAutoNumberingSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportCalendarSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportCustomizationSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportEmailTrackingSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportGeneralSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportMarketingSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportOutlookSynchronizationSettings,
    
    [String] [Parameter(Mandatory = $true)]
    $exportRelationshipRoles,
    
    [String] [Parameter(Mandatory = $true)]
    $exportIsvConfig,
    
    [String] [Parameter(Mandatory = $true)]
    $exportSales           
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

[Boolean]$exportAsManaged = Convert-String $exportAsManaged Boolean
[Boolean]$exportAutoNumberingSettings = Convert-String $exportAutoNumberingSettings Boolean
[Boolean]$exportCalendarSettings = Convert-String $exportCalendarSettings Boolean
[Boolean]$exportCustomizationSettings = Convert-String $exportCustomizationSettings Boolean
[Boolean]$exportEmailTrackingSettings = Convert-String $exportEmailTrackingSettings Boolean
[Boolean]$exportGeneralSettings = Convert-String $exportGeneralSettings Boolean
[Boolean]$exportMarketingSettings = Convert-String $exportMarketingSettings Boolean
[Boolean]$exportOutlookSynchronizationSettings = Convert-String $exportOutlookSynchronizationSettings Boolean
[Boolean]$exportRelationshipRoles = Convert-String $exportRelationshipRoles Boolean
[Boolean]$exportIsvConfig = Convert-String $exportIsvConfig Boolean
[Boolean]$exportSales = Convert-String $exportSales Boolean

Write-Host "connectedServiceName=$connectedServiceName"
Write-Host "solutionName=$solutionName"
Write-Host "exportAsManaged=$exportAsManaged"
Write-Host "exportAutoNumberingSettings=$exportAutoNumberingSettings"
Write-Host "exportCalendarSettings=$exportCalendarSettings"
Write-Host "exportCustomizationSettings=$exportCustomizationSettings"
Write-Host "exportEmailTrackingSettings=$exportEmailTrackingSettings"
Write-Host "exportGeneralSettings=$exportGeneralSettings"
Write-Host "exportMarketingSettings=$exportMarketingSettings"
Write-Host "exportOutlookSynchronizationSettings=$exportOutlookSynchronizationSettings"
Write-Host "exportRelationshipRoles=$exportRelationshipRoles"
Write-Host "exportIsvConfig=$exportIsvConfig"
Write-Host "exportSales=$exportSales"
    
Write-Host "Getting service endpoint..."
$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

$url = $serviceEndpoint.Url
$username = $serviceEndpoint.Authorization.Parameters.UserName
$password = $serviceEndpoint.Authorization.Parameters.Password

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Write-Host "Importing PowerShell Module..."
Add-Type -Path $PSScriptRoot\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Tooling.Connector.dll
Import-Module $PSScriptRoot\tools\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psm1
$connection = Connect-CrmOnline -ServerUrl $url -Credential $credential

Write-Host "Exporting Solution..."
Export-CrmSolution `
    -conn $connection `
    -SolutionName $solutionName `
    -ExportAutoNumberingSettings:$exportAutoNumberingSettings `
    -ExportCalendarSettings:$exportCalendarSettings `
    -ExportCustomizationSettings:$exportCustomizationSettings `
    -ExportEmailTrackingSettings:$exportEmailTrackingSettings `
    -ExportGeneralSettings:$exportGeneralSettings `
    -ExportMarketingSettings:$exportMarketingSettings `
    -ExportOutlookSynchronizationSettings:$exportOutlookSynchronizationSettings `
    -ExportRelationshipRoles:$exportRelationshipRoles `
    -ExportIsvConfig:$exportIsvConfig `
    -ExportSales:$exportSales