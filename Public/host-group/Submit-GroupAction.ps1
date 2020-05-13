function Submit-GroupAction {
<#
.SYNOPSIS
    Take various actions on Host Groups in your environment
.DESCRIPTION
    Requires host-group:write
.PARAMETER ID
    The host group identifier to target
.PARAMETER ACTION
    add-hosts    : Assign hosts to a static group
    remove-hosts : Remove hosts from a static group
.PARAMETER HOSTS
    The host identifiers to target
.EXAMPLE
    PS> Submit-CsGroupAction -Id group_id -Name add-hosts -Hosts host_id_1, host_id_2
    Adds 'host_id_1' and 'host_id_2' to static host group 'group_id'
.EXAMPLE
    PS> Submit-CsGroupAction -Id group_id -Name remove-hosts -Hosts host_id_1, host_id_2
    Removes 'host_id_1' and 'host_id_2' from static host group 'group_id'
.LINK
    https://assets.falcon.crowdstrike.com/support/api/swagger.html#/host-group/performGroupAction
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('add-hosts', 'remove-hosts')]
        [string] $Action,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Hosts
    )
    process {
        $Param = @{
            Uri    = '/devices/entities/host-group-actions/v1?action_name=' + $Action
            Method = 'post'
            Header = @{
                accept         = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = @{
                action_parameters = @(@{
                        name  = 'filter'
                        value = '(device_id:[' + (($Hosts |
                        ForEach-Object { "'" + $_ + "'" }) -join ', ') + '])'
                    })
                ids               = @( $Id )
            } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}