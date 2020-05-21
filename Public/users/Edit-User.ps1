function Edit-User {
<#
.SYNOPSIS
    Modify an existing user's first or last name
.DESCRIPTION
    Requires usermgmt:write
.PARAMETER ID
    User identifier
.PARAMETER FIRST
    User's first name
.PARAMETER LAST
    User's last name
.EXAMPLE
    PS> Edit-CsUser -Id user_id_1 -First John
    Changes the first name of 'user_id_1' to 'John'
.EXAMPLE
    PS> Edit-CsUser -Id user_id_2 -First Jane -Last Doe
    Changes the first name of 'user_id_2' to 'Jane' and last name to 'Doe'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateLength(36,36)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $First,

        [Parameter(ParameterSetName = 'default')]
        [string] $Last
    )
    begin {
        $Body = @{ }

        switch ($PSBoundParameters.Keys) {
            'First' { $Body['firstName'] = $First }
            'Last' { $Body['lastName'] = $Last }
        }
    }
    process {
        $Param = @{
            Uri    = '/users/entities/users/v1?user_uuid=' + $Id
            Method = 'patch'
            Header = @{
                accept = 'application/json'
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