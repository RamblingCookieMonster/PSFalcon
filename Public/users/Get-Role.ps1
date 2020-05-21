function Get-Role {
<#
.SYNOPSIS
    Search for available user roles and roles assigned to users in your environment
.DESCRIPTION
    Requires usermgmt:read
.PARAMETER ID
    Retrieve roles assigned to a specific user identifier
.PARAMETER DETAILED
    Retrieve detailed information
.EXAMPLE
    PS> Get-CsRole -Detailed
    Returns detailed information about all available user roles in your environment
.EXAMPLE
    PS> Get-CsRole -Id user_id_1
    Returns role identifiers assigned to user identifier 'user_id_1'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [ValidateLength(36,36)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed
    )
    process {
        $Param = @{
            Uri    = '/user-roles/queries/user-role-ids-by-cid/v1'
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
            $Param.Uri = '/user-roles/queries/user-role-ids-by-user-uuid/v1?user_uuid=' + $Id

            Invoke-Api @Param
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                Split-Array -Uri $Param.Uri -Id $Request.resources | ForEach-Object {
                    $Param.Uri = '/user-roles/entities/user-roles/v1?ids=' + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}