function Edit-Policy {
<#
.SYNOPSIS
    Update policies by specifying the type and id of the policy
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:write
    firewall-management:write
    prevention-policies:write
    sensor-update-policies:write
.PARAMETER TYPE
    Type of policy
.PARAMETER ID
    Policy id
.PARAMETER NAME
    Policy name
.PARAMETER DESCRIPTION
    Policy description
.PARAMETER SETTINGS
    An array of policy settings
.EXAMPLE
    PS> Edit-CsPolicy -Type Prevention -Id policy_id_1 -Name Example
    Sets the name of 'policy_id_1' to 'Example'
.EXAMPLE
    PS> Edit-CsPolicy -Type Prevention -Id policy_id_1 -Settings @(@{ id = 'EndUserNotifications'; value = @{ enabled = $true }})
    Enables the 'EndUserNotifications' setting on 'policy_id_1'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(32,32)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Name,

        [Parameter(ParameterSetName = 'default')]
        [string] $Description,

        [Parameter(ParameterSetName = 'default')]
        [array] $Settings
    )
    begin {
        switch ($Type) {
            'DeviceControl' { $EntityUri = '/policy/entities/device-control/v1' }
            'Firewall' { $EntityUri = '/policy/entities/firewall/v1' }
            'SensorUpdate' { $EntityUri = '/policy/entities/sensor-update/v2' }
            'Prevention' { $EntityUri = '/policy/entities/prevention/v1' }
        }
        $Body = @{
            id = $Id
        }
        switch ($PSBoundParameters.Keys) {
            'Name' { $Body['name'] = $Name }
            'Description' { $Body['description'] = $Description }
            'Settings' { $Body['settings'] = $Settings }
        }
    }
    process {
        $Param = @{
            Uri    = $EntityUri
            Method = 'patch'
            Header = @{ 'content-type' = 'application/json' }
            Body   = @{ resources = @( $Body ) } | ConvertTo-Json -Depth 8
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}