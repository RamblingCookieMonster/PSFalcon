function Get-CCID {
<#
.SYNOPSIS
    Retrieve your customer identifier and checksum
.DESCRIPTION
    Requires sensor-installers:read
.EXAMPLE
    PS> Get-CsCCID
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param()
    process {
        $Param = @{
            Uri    = '/sensors/queries/installers/ccid/v1'
            Method = 'get'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}