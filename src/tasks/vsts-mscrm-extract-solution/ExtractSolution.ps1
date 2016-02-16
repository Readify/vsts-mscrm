[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $folder,

    [String] [Parameter(Mandatory = $true)]
    $zipFile
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host "folder=$folder"
Write-Host "zipFile=$zipFile"

.\tools\SolutionPackager.exe /action:Extract /zipfile:"$zipFile" /folder:"$folder"