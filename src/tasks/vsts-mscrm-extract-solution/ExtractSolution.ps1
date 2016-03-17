[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $folder,

    [String] [Parameter(Mandatory = $true)]
    $zipFile
)

$ErrorActionPreference = "Stop"

$taskMetadata = ConvertFrom-Json -InputObject $(Get-Content $PSScriptRoot\task.json -raw)
Write-Host "Task version is: $($taskMetadata.version)"

Write-Host "folder is: $folder"
Write-Host "zipFile is: $zipFile"

.\tools\SolutionPackager.exe /action:Extract /zipfile:"$zipFile" /folder:"$folder"

$solutionXmlPath = "$folder\Other\Solution.xml"
[xml] $solutionXml = Get-Content $solutionXmlPath
$node = $solutionXml.SelectSingleNode("ImportExportXml/SolutionManifest/Managed")
$node.'#text' = "2"
$solutionXml.Save($solutionXmlPath)