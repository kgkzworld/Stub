<#
    .SYNOPSIS
        Stub comes from the Active Setup idea of "Just in time" setup.

        The Stub executable can be changed to any name. The binary becomes that entity, and looks for a .ps1 file with the same name in the
            root / execution directory.

    .DESCRIPTION
        Stub comes from the Active Setup idea of "Just in time" setup.

        The Stub executable can be changed to any name. The binary becomes that entity, and looks for a .ps1 file with the same name in the
            root / execution directory.

        Rename Stub.exe to the same name of the External .ps1 file to launch the .ps1 file like an Executable.

        [Parameters]
        /?                              Show this help and Exit
        /Version                        Show version information

        [Environment Information]
        $env:StubCommandLine            Full command line passed to Executable
        $env:StubParameters             All Parameters passed to Executable separated by a ( ; )
        $env:StubPath                   Full path to the Executable
        $env:StubBaseName               Base name of the Executable
        $env:StubPid                    Launchers PID
        $env:StubCommandLinePassThrough The command line with all valid parameter switches removed

    .PARAMETER /?
        Description:  Show this help and Exit
        Notes:
        Alias:
        ValidateSet:

    .PARAMETER /Version
        Description: Show version information
        Notes:
        Alias:
        ValidateSet:

    .NOTES

        • [Original Author]
            o    Michael Arroyo
        • [Original Build Version]
            o    22.03.22.01 [XX = Year (.) XX = Month (.) XX = Day XX = Build revision]
        • [Latest Author]
            o
        • [Latest Build Version]
            o
        • [Comments]
            o
        • [PowerShell Compatibility]
            o    2,3,4,5.x
        • [Forked Project]
            o
        • [Links]
            o
        • [Dependencies]
            o None
        • [Build Version Details]
            o 22.03.22.01: * [Michael Arroyo] Posted
#>

#region Query File Name
    $FileInfo = Get-Process -Id $PID | Select-Object -ExpandProperty Path
#endregion Query File Name

#region Setup Env
    $ErrorActionPreference = 'SilentlyContinue'
    $ExePath = $FileInfo | Split-Path -Parent
    $FileDetails = Get-Item -Path $FileInfo -Force
    $FileBaseName = $FileDetails | Select-Object -ExpandProperty BaseName
    $FileVersion = $FileDetails | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
#endregion Setup Env

#region Bound Parameters
	$env:StubCommandLine = $MyInvocation.UnboundArguments -join " "
    $env:StubParameters = $MyInvocation.UnboundArguments -join ";"
	$env:StubPath = $ExePath
	$env:StubBaseName = $FileBaseName
    $env:StubPid = $PID
    $CommandLine = $env:StubCommandLine
    $Parameters = $env:StubParameters
    $env:StubFullname = $FileInfo
#endregion Bound Parameters

#region Command Line Parameters
	If ( $CommandLine -match '/' ) {
		$TempParameters = $CommandLine -replace '/','///'
		$SplitParams = $TempParameters -split '//'
	} Else {
		$SplitParams = $CommandLine
	}

	[bool]$StubNoExit = $true
    [bool]$StubHidden = $false
    [bool]$StubNoProfile = $false
    [string]$StubExecutionPolicy = 'Bypass'
    [bool]$StubHelp = $false
    [bool]$StubNoLogo = $true

    $Parameters -split ';' | ForEach-Object -Process {
        $CurParam = $_

        $HelpHere = @"
    $($FileBaseName).exe 22.03.22.01 (Author: Michael Arroyo)

    Rename $($FileBaseName).exe to the same name of the External .ps1 file to launch the .ps1 file like an Executable.

    [Parameters]
    /?                              Show this help and Exit
    /Version                        Show version information

    [Environment Information]
    `$env:StubCommandLine            Full command line passed to Executable
    `$env:StubParameters             All Parameters passed to Executable separated by a ( ; )
    `$env:StubPath                   Full path to the Executable
    `$env:StubBaseName               Base name of the Executable
    `$env:StubPid                    Launchers PID
    `$env:StubCommandLinePassThrough The command line with all valid parameter switches removed
"@

        switch -regex ( $CurParam ) {
    		'/Version' {
    			Write-Host $FileVersion -ForegroundColor Yellow
                Exit
    		}
            '/\?' {
                $HelpHere | Out-Default
                Exit
    		}
        }
    }

    If ( $CommandLine ) {
	    $CommandLine = $($CommandLine).Trim()
		If ( -Not $($CommandLine -match '\d|\w') ) {
			$Commandline = $null
		}
    }

    $env:StubCommandLinePassThrough = $CommandLine
#endregion Command Line Parameters

#region Process Posh File
    If ( Test-Path -Path $('{0}\{1}.ps1' -f $ExePath, $FileBaseName) ) {
        $CurSBContent = Get-Content -Path $('{0}\{1}.ps1' -f $ExePath, $FileBaseName) -Raw
        $CurSB = [ScriptBlock]::Create($CurSBContent)
        $CurSB.Invoke()
    } Else {
        $HelpHere | Out-Default
    }
#region Process Posh File