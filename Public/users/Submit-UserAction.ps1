function Submit-UserAction {
<#
.SYNOPSIS
    Add or remove roles from a user in your environment
.DESCRIPTION
    Requires usermgmt:write
.PARAMETER ID
    User identifier
.PARAMETER ACTION
    add_role    : Add a role to the user.
    remove_role : Remove a role from the user.
.PARAMETER ROLE
    One or more role identifiers
.EXAMPLE
    PS> Submit-CsUserAction -Id 'user_id_1' -Action add_role -Role 
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('add_role', 'remove_role')]
        [string] $Action,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Role
    )
    process {
        $Param = @{
            Uri = '/user-roles/entities/user-roles/v1?user_uuid=' + $Id
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($Action) {
            'add_role' {
                $Param['Method'] = 'post'
                $Param['Body'] = @{ roleIds = @( $Role ) } | ConvertTo-Json
            }
            'remove_role' {
                $Param.Uri += '&ids=' + ($Role -join '&ids=')
                $Param['Method'] = 'delete'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}