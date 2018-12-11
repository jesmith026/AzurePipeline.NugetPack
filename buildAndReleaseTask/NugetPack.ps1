[CmdletBinding()]
param()

$project = Get-VstsInput -Name 'project' -Require;
$outputDir = Get-VstsInput -Name 'output' -Require
$version = Get-VstsInput -Name 'version' -Require

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
        $versionArg = "-p:PackageVersion=$version";
    }    

    $args += $versionArg;
}

Invoke-Expression "dotnet pack $args";