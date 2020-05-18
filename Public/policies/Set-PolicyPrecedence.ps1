function Set-PolicyPrecedence {
<#
.SYNOPSIS
    Sets the precedence of policies based on identifiers, ordered highest to lowest
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:write
    firewall-management:write
    prevention-policies:write
    sensor-update-policies:write
.PARAMETER TYPE
    Type of policy
.PARAMETER PLATFORM
    Operating system platform
.PARAMETER ID
    Available policy identifiers (except platform defaults) in precedence order
.EXAMPLE
    PS> Set-CsPolicyPrecedence -Type Prevention -Platform Windows -Id policy_id_1, policy_id_2, policy_id_3
    Assigns precedence to Windows prevention policy identifiers policy_id_1, policy_id_2 and policy_id_3
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('Linux', 'Mac', 'Windows')]
        [string] $Platform,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id
    )
    begin {
        switch ($Type) {
            'DeviceControl' { $EntityUri = '/policy/entities/device-control-precedence/v1' }
            'Firewall' { $EntityUri = '/policy/entities/firewall-precedence/v1' }
            'SensorUpdate' { $EntityUri = '/policy/entities/sensor-update-precedence/v2' }
            'Prevention' { $EntityUri = '/policy/entities/prevention-precedence/v1' }
        }
        $Body = @{
            platform_name = $Platform
            ids = $Id
        }
    }
    process {
        $Param = @{
            Uri    = $EntityUri
            Method = 'post'
            Header = @{
                'content-type' = 'application/json'
            }
            Body   = ConvertTo-Json $Body
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}