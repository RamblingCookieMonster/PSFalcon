function Submit-IncidentAction {
<#
.SYNOPSIS
    Perform a set of actions on one or more incidents
.DESCRIPTION
    Requires incidents:write
.PARAMETER ID
    The incident ids to target
.PARAMETER ACTION
    add_tag            : Adds one or more tag values
    delete_tag         : Deletes one or more tag values
    update_name        : Update name
    update_description : Update description
    update_status      : Update status ('new', 'reopened', 'in_progress', 'closed')
.PARAMETER VALUE
    The associated value for the provided action name
.EXAMPLE
    PS> Submit-CsIncidentAction -Id 'incident_id_1' -Action add_tag -Value PSFalcon
    Adds the tag 'PSFalcon' to 'incident_id_1'
.EXAMPLE
    PS> Submit-CsIncidentAction -Id 'incident_id_1' -Action update_status -Value closed
    Sets the status for 'incident_id_1' to 'closed'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('add_tag', 'delete_tag', 'update_name', 'update_description', 'update_status')]
        [string] $Action,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Value
    )
    begin {
        if ($Action -eq 'update_status') {
            switch ($Value) {
                'new' { $Value = 20 }
                'reopened' { $Value = 25 }
                'in_progress' { $Value = 30 }
                'closed' { $Value = 40 }
                default { throw "Valid values for 'update_status': 'new', 'reopened', 'in_progress', 'closed'." }
            }
        }
    }
    process {
        $Param = @{
            Uri    = '/incidents/entities/incident-actions/v1'
            Method = 'post'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = @{
                action_parameters = @(@{
                    name = $Action
                    value = $Value
                })
                ids = @( $Id )
            } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug'   { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}