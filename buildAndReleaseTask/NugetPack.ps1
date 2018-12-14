[CmdletBinding()]
param()

$project = Get-VstsInput -Name 'project' -Require;
$outputDir = Get-VstsInput -Name 'output' -Require
$majorVersion = Get-VstsInput -Name 'majorVersion' -Require
$minorVersion = Get-VstsInput -Name 'minorVersion' -Require

function getNewPatchVersion() {
    $projectName = Get-ChildItem $project;

    $output = nuget.exe list $projectName.BaseName -ConfigFile "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\NuGet.Config";
        $output = nuget.exe list $projectName.BaseName -ConfigFile "$env:BUILD_SOURCESDIRECTORY\NuGet.Config";

    $patchStr = $output.split('.')[-1];

    if ([string]::IsNullOrEmpty($patchStr)) {
        0;
    }
    else {
        $([convert]::ToInt32($patchStr)+1);
    }
}

$args = @();

$args += $project + " ";

if (-Not [string]::IsNullOrEmpty($outputDir)) {
    $args += "-o $outputDir";
}

if ($Env:BUILD_SOURCEBRANCHNAME -ne 'Dev') {
    $versionArg = "-p:PackageVersion=$($Env:BUILD_BUILDNUMBER)-alpha";
}
else {
    $patch = getNewPatchVersion;
    $versionArg = "-p:PackageVersion=$majorVersion.$minorVersion.$patch";
}    

$args += $versionArg;


Invoke-Expression "dotnet pack $args";