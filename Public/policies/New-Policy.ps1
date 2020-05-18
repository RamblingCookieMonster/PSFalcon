function New-Policy {
<#
.SYNOPSIS
    Create Prevention Policies by specifying details about the policy to create
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:write
    firewall-management:write
    prevention-policies:write
    sensor-update-policies:write
.PARAMETER TYPE
    Type of policy
.PARAMETER CLONEID
    A policy id to clone
.PARAMETER NAME
    Policy name
.PARAMETER DESCRIPTION
    Policy description
.PARAMETER SETTINGS
    An array of policy settings
.EXAMPLE
    PS> New-CsPolicy -Type Prevention -CloneId policy_id_1 -Platform Windows -Name Example
    Clones the Windows-specific prevention policy 'policy_id_1' into a new policy named 'Example'
.EXAMPLE
    PS> New-CsPolicy -Type Prevention -Name Example -Settings @(@{ id = 'EndUserNotifications'; value = @{ enabled = $true }})
    Creates a new Windows-specific prevention policy named 'Example' with the 'EndUserNotifications' prevention setting enabled
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(32,32)]
        [string] $CloneId,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('Linux', 'Mac', 'Windows')]
        [string] $Platform,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
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
            'SensorUpdate' { $EntityUri = '/policy/entities/sensor-update/v1' }
            'Prevention' { $EntityUri = '/policy/entities/prevention/v1' }
        }
        $Body = @{
            platform_name = $Platform
        }
        switch ($PSBoundParameters.Keys) {
            'CloneId' { $Body['clone_id'] = $CloneId }
            'Name' { $Body['name'] = $Name }
            'Description' { $Body['description'] = $Description }
            'Settings' { $Body['settings'] = $Settings }
        }
    }
    process {
        $Param = @{
            Uri    = $EntityUri
            Method = 'post'
            Header = @{ 'content-type' = 'application/json' }
            Body   = @{ resources = @( $Body ) } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}