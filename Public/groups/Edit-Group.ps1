function Edit-Group {
<#
.SYNOPSIS
    Update Host Groups by specifying the group identifier and details to update
.DESCRIPTION
    Requires host-group:write
.PARAMETER ID
    The existing host group identifier
.PARAMETER NAME
    Host group name
.PARAMETER DESCRIPTION
    Host group description
.PARAMETER RULE
    The assignment rule, used with dynamic host groups
.EXAMPLE
    PS> Edit-CsGroup -Id group_id_1
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateLength(32, 32)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Name,

        [Parameter(ParameterSetName = 'default')]
        [string] $Description,

        [Parameter(ParameterSetName = 'default')]
        [string] $Rule
    )
    process {
        $Resources = @{ id = $Id }

        switch ($PSBoundParameters.Keys) {
            'Description' {	$Resources['description'] = $Description }
            'Name' { $Resources['name'] = $Name }
            'Rule' { $Resources['assignment_rule'] = $Rule }
        }
        $Param = @{
            Uri    = '/devices/entities/host-groups/v1'
            Method = 'patch'
            Header = @{
                'content-type' = 'application/json'
            }
            Body   = @{ resources = @( $Resources ) } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}