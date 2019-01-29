function getNewPatchVersion() {
    Write-Host 'Getting new patch version';
    $projectFile = Get-ChildItem $project;
    $output = '';

    nuget.exe list $projectFile.BaseName | %{ 
        if($_.split()[0] -eq $projectFile.BaseName) {
            $output = $_;
        }
    };

    $splitOutput = $output.split('.');

    $lastMajorVersion = $splitOutput[-3].Split()[-1];
    $lastMinorVersion = $splitOutput[-2];
    $lastPatch = $splitOutput[-1];

    Write-Host "Latest version found: '$lastMajorVersion.$lastMinorVersion.$lastPatch'";    

    
    if ([string]::IsNullOrEmpty($lastPatch) -Or $lastMajorVersion -ne $majorVersion -Or $lastMinorVersion -ne $minorVersion) {
        Write-Host "New patch version is '0'";
        0;
    }
    else {        
        $patch = $([convert]::ToInt32($lastPatch)+1);
        Write-Host "New patch version is '$patch'";
        $patch;
    }
}

function tryAddOutputArg([parameter(ValueFromPipeline)] $args) {
    Write-Host 'Attempting to add output argument';

    if (-Not [string]::IsNullOrEmpty($outputDir)) {
        $args += "-o $outputDir ";
        Write-Host "Output argument added '-o $outputDir'";
    }
    else {
        Write-Host 'No output argument added';
    }

    $args;
}

function addVersioningArgs([parameter(ValueFromPipeline)] $args) {
    if ($env:BUILD_SOURCEBRANCHNAME -eq 'dev') {
        $args | addDevVersionArgs;
    }
    else {
        $args | addNonReleaseVersionArgs;
    }
}

function addDevVersionArgs([parameter(ValueFromPipeline)]$args) {
    Write-Host 'Adding versioning args for building dev branch';

    $patch = getNewPatchVersion;
    $versionArg = "-p:PackageVersion=$majorVersion.$minorVersion.$patch ";
    $assemblyArg = "-p:AssemblyVersion=$majorVersion.$minorVersion.$patch ";

    $args += $versionArg;
    $args += $assemblyArg;

    Write-Host "Package version set to '$majorVersion.$minorVersion.$patch'";
    Write-Host "Assembly version set to '$majorVersion.$minorVersion.$patch'";

    $args;
}

function addNonReleaseVersionArgs([parameter(ValueFromPipeline)]$args) {
    Write-Host 'Adding versioning args for build non-dev branch';

    $versionArg = "-p:PackageVersion=$env:BUILD_BUILDNUMBER-alpha ";
    $assemblyArg = "-p:AssemblyVersion=$env:BUILD_BUILDNUMBER ";

    $args += $versionArg;
    $args += $assemblyArg;

    Write-Host "Package version set to '$env:BUILD_BUILDNUMBER-alpha'";
    Write-Host "Assembly version set to '$env:BUILD_BUILDNUMBER'";

    $args;
}

function addConfigurationArg([parameter(ValueFromPipeline)]$args) {
    $args += '-c Release ';
    Write-Host 'Configuration arg set to Release';

    $args;
}

function addProjectArg([parameter(ValueFromPipeline)]$args) {
    $args += $project + " ";
    $args;
}

function finalConstruction([parameter(ValueFromPipeline)]$args) {
    $command = "dotnet pack $args";
    Write-Host "Command constructed '$command'";
    $command;
}

"" | addProjectArg | tryAddOutputArg | addVersioningArgs | addConfigurationArg | finalConstruction;

