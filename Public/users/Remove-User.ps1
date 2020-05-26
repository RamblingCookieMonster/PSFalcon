function Remove-User {
<#
.SYNOPSIS
    Remove a user from your environment
.DESCRIPTION
    Requires usermgmt:write
.PARAMETER ID
    User identifier
.EXAMPLE
    PS> Remove-CsUser -Id 'user_id_1'
    Removes 'user_id_1' from your environment
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 0)]
        [ValidateLength(36,36)]
        [string] $Id
    )
    process {
        $Param = @{
            Uri    = '/users/entities/users/v1?user_uuid=' + $Id
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