﻿#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
#

function OpScanPrograms(
    [switch] $noExecute)
{
    @( @{Name = "Scan System for installed programs"; ShortName = "SCANPROG"; Info = "Scan System for installed programs";
         Verification = @( @{Function = "VerifyScanPrograms"; Params = @{} } );
         Download = @();
         Action = @();
        } )
}

function OpVs2015Runtime(
    [parameter(Mandatory=$true)][string] $rootDir,
    [switch] $noExecute)
{
    $installExe = Join-Path $rootDir prerequisites\VS2015\vc_redist.x64.exe

    @( @{Name = "Installation VS2015 Runtime"; ShortName = "VS2015"; Info = "Install VS2015 Runtime";
         Verification = @( @{Function = "VerifyWinProductExists"; Params = @{ match = "^Microsoft Visual C\+\+ 201(5|7) x64 Additional Runtime" } },
                           @{Function = "VerifyWinProductExists"; Params = @{ match = "^Microsoft Visual C\+\+ 201(5|7) x64 Minimum Runtime" } } );
         Download = @( );
         Action = @( @{Function = "RunDos"; Params = @{ cmd  = $installExe; param = (Write-Output /install /passive /norestart); 
                                                            message="Installing VS2015 Runtime...."; NoExecute= $noExecute } } )
        } )
}

function OpMSMPI(
    [parameter(Mandatory=$true)][string] $rootDir,
    [switch] $noExecute)
{
    $installExe = Join-Path $rootDir prerequisites\msmpisetup.EXE

    @( @{Name = "MSMPI Installation"; ShortName = "CNTK"; Info = "Install MSMPI";
         Verification = @( @{Function = "VerifyWinProductVersion"; Params = @{ match = "^Microsoft MPI \(\d+\."; version = "7.0.12437.6" } } );
         Download = @( );
         Action = @( @{Function = "RunDos"; Params = @{ cmd = $installExe; param = (Write-Output /unattend); 
                                                            message="Installing MSMPI ...."; NoExecute= $noExecute } } )
        } )
}

function OpAnaconda(
    [parameter(Mandatory=$true)][string] $localCache,
    [parameter(Mandatory=$true)][string] $anacondaBasePath,
    [switch] $noExecute)
{
     $cacheFile = Join-Path $localCache "Anaconda3-4.1.1-Windows-x86_64.exe"
     $source = "https://repo.continuum.io/archive/Anaconda3-4.1.1-Windows-x86_64.exe"
     
     @( @{Name = "Anaconda3-4.1.1"; ShortName = "ANA3-411"; Info = "Install Anaconda3-4.1.10";
          Verification = @( @{Function = "VerifyDirectory"; Params = @{ path = "$anacondaBasePath"; } } );
          Download = @( @{Function = "Download"; Params = @{ source = $source; destination = $cacheFile } } );
          Action = @( @{Function = "RunDos"; Params = @{ cmd = $cacheFile; param = (Write-Output /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=$anacondaBasePath); 
                                                             message="Installing Anaconda3-4.1.1 in the background - please be patient..."; NoExecute= $noExecute} } );
         } )
}
        
function OpPythonEnvironment(
    [parameter(Mandatory=$true)][string] $pyVersion,
    [parameter(Mandatory=$true)][string] $ymlDirectory,
    [parameter(Mandatory=$true)][string] $anacondaBasePath,
    [switch] $noExecute)
{        
     $ymlFile = Join-Path $ymlDir "conda-windows-cntk-py$pyVersion-environment.yml"

     @( @{Name = "CNTK Python Environment"; ShortName = "CNTKPY"; Info = "Setup CNTK PythonEnvironment $pyVersion";
          Verification  = @( @{Function = "VerifyRunAlways"; Params = @{} } );
          Download = @( );
          Action = @( @{Function = "InstallYml"; Params = @{ basePath = $anacondaBasePath; env = "cntk-py$pyVersion"; ymlFile= $ymlFile; pyVersion = $pyVersion; message="Setup/Update with yml file: $ymlFile" ; NoExecute= $noExecute } } )
         } )
}

function OpWhlInstall(
    [parameter(Mandatory=$true)][string] $pyVersion,
    [parameter(Mandatory=$true)][string] $whlUrl,
    [parameter(Mandatory=$true)][string] $anacondaBasePath,
    [switch] $noExecute)
{ 
     @( @{Name = "CNTK WHL Install"; ShortName = "CNTKWHL"; Info = "Setup/Update CNTK Wheel $pyVersion";
          Verification  = @( @{Function = "VerifyRunAlways"; Params = @{} } );
          Download = @( );
          Action = @( @{Function = "InstallWheel"; Params = @{ whlUrl = $whlUrl; basePath = $anacondaBasePath; envName = "cntk-py$pyVersion"; message="Setup/Update with wheel: $whlUrl"; NoExecute= $noExecute } } )
         } )
}

function OpPythonBatch(
    [parameter(Mandatory=$true)][string] $pyVersion,
    [parameter(Mandatory=$true)][string] $rootDir,
    [parameter(Mandatory=$true)][string] $anacondaBasePath,
    [switch] $noExecute)
{ 
    $batchFile = Join-Path $rootDir "scripts\cntkpy$pyVersion.bat"

    @( @{Name = "Create CNTKPY batch file"; ShortName = "BATCH"; Info = "Create CNTKPY batch file";
          Verification  = @( @{Function = "VerifyFile"; Params = @{ longFileName = $batchFile } } );
          Download = @( );
          Action = @( @{Function = "CreateBatch"; Params = @{ filename = $batchFile; pyVersion = $pyVersion; basePath = $anacondaBasePath; rootDir = $rootDir; NoExecute= $noExecute } } )
        } )
}

# vim:set expandtab shiftwidth=4 tabstop=4: