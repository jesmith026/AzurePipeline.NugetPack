[CmdletBinding()]
param()

Set-PSDebug -Trace 0;

$project = Get-VstsInput -Name 'project' -Require;
$outputDir = Get-VstsInput -Name 'output' -Require
$majorVersion = Get-VstsInput -Name 'majorVersion' -Require
$minorVersion = Get-VstsInput -Name 'minorVersion' -Require

$command = . "$PSScriptRoot\buildPackCommand.ps1";
Invoke-Expression $command;