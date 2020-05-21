function Edit-IOC {
<#
.SYNOPSIS
    Update an existing IOC
.DESCRIPTION
    Requires iocs:write
.PARAMETER TYPE
    Type of IOC
.PARAMETER VALUE
    IOC value
.PARAMETER DESCRIPTION
    Description of IOC
.PARAMETER POLICY
    Policy to use with IOC
.PARAMETER SHARE
    Share level for IOC
.PARAMETER SOURCE
    Source of IOC
.EXAMPLE
    PS> Edit-CsIOC -Type sha256 -Value sha_value_1 -Description 'Example'
    Set the description of 'sha256_value_1' to 'Example'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('domain', 'ipv4', 'ipv6', 'md5', 'sha256')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Value,

        [Parameter(ParameterSetName = 'default')]
        [string] $Description,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('detect', 'none')]
        [string] $Policy,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('red')]
        [string] $Share,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(1, 200)]
        [string] $Source
    )
    begin {
        $Body = @{ }

        switch ($PSBoundParameters.Keys) {
            'Description' { $Body['description'] = $Description }
            'Policy' { $Body['policy'] = $Policy }
            'Share' { $Body['share_level'] = $Share }
            'Source' { $Body['source'] = $Source }
        }
    }
    process {
        $Param = @{
            Uri    = '/indicators/entities/iocs/v1?'
            Method = 'patch'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = ConvertTo-Json $Body
        }
        switch ($PSBoundParameters.Keys) {
            'Type' { $Param.Uri += '&type=' + $Type }
            'Value' { $Param.Uri += '&value=' + $Value }
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}