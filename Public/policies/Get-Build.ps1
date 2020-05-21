function Get-Build {
<#
.SYNOPSIS
    Retrieve available builds for use with Sensor Update Policies
.DESCRIPTION
    Requires sensor-update-policies:read
.PARAMETER PLATFORM
    Operating System platform
.EXAMPLE
    PS> Get-CsBuild
    Returns available builds for all operating system platforms
.EXAMPLE
    PS> Get-CsBuild -Platform Windows
    Returns available builds for Windows
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('Linux', 'Mac', 'Windows')]
        [string] $Platform,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $Param = @{
            Uri    = '/policy/combined/sensor-update-builds/v1'
            Method = 'get'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Platform' { $Param.Uri += '?platform=' + $Platform.ToLower() }
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}