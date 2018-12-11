[CmdletBinding()]
param()

$project = Get-VstsInput -Name 'project' -Require;
$outputDir = Get-VstsInput -Name 'output' -Require
$majorVersion = Get-VstsInput -Name 'majorVersion' -Require
$minorVersion = Get-VstsInput -Name 'minorVersion' -Require

function getNewPatchVersion() {
    $projectName = Get-ChildItem $project

    $output = nuget list $projectName.BaseName -ConfigFile .\NuGet.Config;

    Write-Output $([convert]::ToInt32($output.split('.')[-1])+1);
}

$args = @();

$args += $project + " ";

if (-Not [string]::IsNullOrEmpty($outputDir)) {
    $args += "-o $outputDir";
}

if (-Not [string]::IsNullOrEmpty($version)) {
    if ($Env:BUILD_SOURCEBRANCHNAME -ne 'Dev') {
        $versionArg = "-p:PackageVersion=$($Env:BUILD_BUILDNUMBER)-alpha";
    }
    else {
        $patch = getNewPatchVersion;
        $versionArg = "-p:PackageVersion=$majorVersion.$minorVersion.$patch";
    }    

    $args += $versionArg;
}

Invoke-Expression "dotnet pack $args";