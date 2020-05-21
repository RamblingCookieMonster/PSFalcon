function New-IOC {
<#
.SYNOPSIS
    Create an IOC
.DESCRIPTION
    Requires iocs:write
.PARAMETER TYPE
    Type of IOC
.PARAMETER VALUE
    IOC value
.PARAMETER POLICY
    Policy to use with IOC
.PARAMETER DESCRIPTION
    Description of IOC
.PARAMETER SHARE
    Share level for IOC [default: red]
.PARAMETER SOURCE
    Source of IOC
.PARAMETER EXPIRATION
    Number of days for an domain/ipv4/ipv6 IOC to remain active
.EXAMPLE
    PS> New-CsIOC -Type domain -Value example.com -Policy detect -Expiration 90
    Creates a new IOC 'example.com' that will generate detections and expire in 90 days
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('domain', 'ipv4', 'ipv6', 'md5', 'sha256')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Value,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('detect', 'none')]
        [string] $Policy,

        [Parameter(ParameterSetName = 'default')]
        [string] $Description,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('red')]
        [string] $Share,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(1, 200)]
        [string] $Source,

        [Parameter(ParameterSetName = 'default')]
        [int] $Expiration
    )
    begin {
        $Body = @{
            type = $Type
            value = $Value
            policy = $Policy
        }
        switch ($PSBoundParameters.Keys) {
            'Description' { $Body['description'] = $Description }
            'Share' { $Body['share_level'] = $Share }
            'Source' { $Body['source'] = $Source }
            'Expiration' { 
                if ($Type -cin @('domain', 'ipv4', 'ipv6')) {
                    $Body['expiration_days'] = $Expiration
                }
            }
        }
    }
    process {
        $Param = @{
            Uri    = '/indicators/entities/iocs/v1'
            Method = 'post'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = ConvertTo-Json @($Body)
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}