function New-User {
<#
.SYNOPSIS
    Create a new user in your environment
.DESCRIPTION
    Requires usermgmt:write
.PARAMETER EMAIL
    User's email address
.PARAMETER FIRST
    User's first name
.PARAMETER LAST
    User's last name
.EXAMPLE
    PS> New-CsUser -Email user@contoso.com
    Creates a user account and sends an email to 'user@contoso.com'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Email,

        [Parameter(ParameterSetName = 'default')]
        [string] $First,

        [Parameter(ParameterSetName = 'default')]
        [string] $Last
    )
    begin {
        $Body = @{
            uid = $Email
        }
        switch ($PSBoundParameters.Keys) {
            'First' { $Body['firstName'] = $First }
            'Last' { $Body['lastName'] = $Last }
        }
    }
    process {
        $Param = @{
            Uri    = '/users/entities/users/v1'
            Method = 'post'
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