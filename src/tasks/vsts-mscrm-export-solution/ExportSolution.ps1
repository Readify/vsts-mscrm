[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $connectedServiceName,
    
    [String] [Parameter(Mandatory = $true)]
    $solutionName,
    
    [String] [Parameter(Mandatory = $true)]
    $solutionType,
    
    [String] [Parameter(Mandatory = $false)]
    $solutionFilePath,
    
    [String] [Parameter(Mandatory = $false)]
    $solutionZipFileName,

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

Write-Verbose "connectedServiceName = $connectedServiceName"
Write-Verbose "solutionName = $solutionName"
Write-Verbose "solutionType = $solutionType"
Write-Verbose "solutionFilePath = $solutionFilePath"
Write-Verbose "solutionZipFileName = $solutionZipFileName"
Write-Verbose "exportAsManaged = $exportAsManaged"
Write-Verbose "exportAutoNumberingSettings = $exportAutoNumberingSettings"
Write-Verbose "exportCalendarSettings = $exportCalendarSettings"
Write-Verbose "exportCustomizationSettings = $exportCustomizationSettings"
Write-Verbose "exportEmailTrackingSettings = $exportEmailTrackingSettings"
Write-Verbose "exportGeneralSettings = $exportGeneralSettings"
Write-Verbose "exportMarketingSettings = $exportMarketingSettings"
Write-Verbose "exportOutlookSynchronizationSettings = $exportOutlookSynchronizationSettings"
Write-Verbose "exportRelationshipRoles = $exportRelationshipRoles"
Write-Verbose "exportIsvConfig = $exportIsvConfig"
Write-Verbose "exportSales = $exportSales"
    
Write-Host "Getting service endpoint..."
$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

$url = $serviceEndpoint.Url
Write-Verbose "url = $url"

$username = $serviceEndpoint.Authorization.Parameters.UserName
Write-Verbose "username = $username"

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

Write-Host "Exporting Solution..."

if ($solutionType -eq "unmanaged") {
    $managed = $false
} else {
    $managed = $true
}

$response = Export-CrmSolution `
    -conn $connection `
    -SolutionName $solutionName `
    -SolutionFilePath $solutionFilePath `
    -SolutionZipFileName $solutionZipFileName `
    -Managed:$managed `
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
Write-Host "Solution Path is: $($response.SolutionPath)"