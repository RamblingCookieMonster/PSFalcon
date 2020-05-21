function Receive-Installer {
<#
.SYNOPSIS
    Download a sensor installer file
.DESCRIPTION
    Requires sensor-installers:read
.PARAMETER ID
    SHA256 hash
.PARAMETER PATH
    Destination path
.EXAMPLE
    PS> Receive-CsInstaller -Id sha256_hash -Path .\WindowsSensor.exe
    Downloads the sensor installer 'sha256_hash' and as .\WindowsSensor.exe
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateLength(64,64)]
        [string] $Id,

        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    process {
        $Param = @{
            Uri    = '/sensors/entities/download-installer/v1?id=' + $Id
            Method = 'get'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
            OutFile = $Path
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
    end {
        if (Test-Path $Path) {
            Get-ChildItem $Path | Out-Host
        }
    }
}