[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $folder,

    [String] [Parameter(Mandatory = $true)]
    $packageType,

    [String] [Parameter(Mandatory = $true)]
    $zipFile
)

$ErrorActionPreference = "Stop"

$taskMetadata = ConvertFrom-Json -InputObject $(Get-Content $PSScriptRoot\task.json -raw)
Write-Host "Task version is: $($taskMetadata.version)"

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host "folder is: $folder"
Write-Host "packageType is: $packageType"
Write-Host "zipFile is: $zipFile"

$solutionXmlPath = "$folder\Other\Solution.xml"
[xml] $solutionXml = Get-Content 
$node = $solutionXml.SelectSingleNode("ImportExportXml/SolutionManifest/Version")
$node.Value = "2"
$solutionXml.Save($solutionXmlPath)

.\tools\SolutionPackager.exe /action:Pack /zipfile:"$zipFile" /packagetype:$packageType /folder:"$folder"