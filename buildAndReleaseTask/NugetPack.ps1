[CmdletBinding()]
param()

$project = Get-VstsInput -Name 'project' -Require;
$outputDir = Get-VstsInput -Name 'output' -Require
$version = Get-VstsInput -Name 'version' -Require
$branch = Get-VstsInput -Name 'branch' -Require

$args = @();

$args += $project + " ";

if (-Not [string]::IsNullOrEmpty($outputDir)) {
    $args += "-o $outputDir";
}

if (-Not [string]::IsNullOrEmpty($version)) {
    $versionArg = "-p:PackageVersion=$version";

    if ($branch -ne 'Dev') {
        $versionArg += '-alpha';
    }

    $args += $versionArg;
}

Invoke-Expression "dotnet pack $args";