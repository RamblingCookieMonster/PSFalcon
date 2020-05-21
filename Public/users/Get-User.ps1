function Get-User {
<#
.SYNOPSIS
    Search for users in your environment
.DESCRIPTION
    Requires usermgmt:read
.PARAMETER ID
    Retrieve detailed information for specific user identifiers
.PARAMETER DETAILED
    Retrieve detailed information
.EXAMPLE
    PS> Get-CsUser
    Returns all user identifiers in your environment
.EXAMPLE
    PS> Get-CsUser -Detailed
    Returns detailed information about all user identifiers in your environment
.EXAMPLE
    PS> Get-CsUser -Id user_id_1, user_id_2
    Returns detail about user identifiers 'user_id_1' and 'user_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed
    )
    process {
        $Param = @{
            Uri    = '/users/queries/user-uuids-by-cid/v1'
            Method = 'get'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        if ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/users/entities/users/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                Split-Array -Uri $Param.Uri -Id $Request.resources | ForEach-Object {
                    $Param.Uri = '/users/entities/users/v1?ids=' + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}