function Submit-PolicyAction {
<#
.SYNOPSIS
    Take various actions on policies in your environment
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:write
    firewall-management:write
    prevention-policies:write
    sensor-update-policies:write
.PARAMETER TYPE
    Type of policy
.PARAMETER ID
    Policy identifiers
.PARAMETER ACTION
    add-host-group    : Add a host group to the policy
    disable           : Disable the policy
    enable            : Enable the policy
    remove-host-group : Remove a host group from the policy
.PARAMETER GROUPID
    Host group idenfitier, if using 'add-host-group' or 'remove-host-group'
.EXAMPLE
    PS> Submit-CsPolicyAction -Type Prevention -Id policy_id_1, policy_id_2 -Action enable
    Enables prevention policy identifiers 'policy_id_1' and 'policy_id_2'
.EXAMPLE
    PS> Submit-CsPolicyAction -Type Prevention -Id policy_id_1, policy_id_2 -Action add-host-group -GroupId group_id_1
    Adds host group identifier 'group_id_1' to prevention policy identifiers 'policy_id_1' and 'policy_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('add-host-group', 'disable', 'enable', 'remove-host-group')]
        [string] $Action,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(32,32)]
        [string] $GroupId
    )
    begin {
        switch ($Type) {
            'DeviceControl' { $EntityUri = '/policy/entities/device-control-actions/v1?action_name=' }
            'Firewall' { $EntityUri = '/policy/entities/firewall-actions/v1?action_name=' }
            'SensorUpdate' { $EntityUri = '/policy/entities/sensor-update-actions/v1?action_name=' }
            'Prevention' { $EntityUri = '/policy/entities/prevention-actions/v1?action_name=' }
        }
        $Body = @{
            'ids' = $Id
        }
        if ($Action -cin @('add-host-group', 'remove-host-group')) {
            $Body['action_parameters'] = @(@{ name = 'group_id'; value = $GroupId })
        }
    }
    process {
        $Param = @{
            Uri    = $EntityUri + $Action 
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