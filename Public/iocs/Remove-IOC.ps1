function Remove-IOC {
<#
.SYNOPSIS
    Delete an IOC
.DESCRIPTION
    Requires iocs:write
.PARAMETER TYPE
    Type of IOC
.PARAMETER VALUE
    IOC value
.EXAMPLE
    PS> Remove-CsIOC -Type domain -Value example.com
    Removes the IOC 'example.com' from your environment
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('domain', 'ipv4', 'ipv6', 'md5', 'sha256')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Value
    )
    process {
        $Param = @{
            Uri    = '/indicators/entities/iocs/v1?type=' + $Type + '&value=' + $Value
            Method = 'delete'
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