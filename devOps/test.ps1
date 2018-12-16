$env:BUILD_SOURCEBRANCHNAME = 'dev';
$env:BUILD_BUILDNUMBER = '2018.12.13.1';

Import-Module "$PSScriptRoot\..\buildAndReleaseTask\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1";
& "$PSScriptRoot\..\buildAndReleaseTask\task.ps1";
Remove-Module "VstsTaskSdk";