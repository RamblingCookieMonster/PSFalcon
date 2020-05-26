function Remove-Group {
<#
.SYNOPSIS
    Delete a set of Host Groups by specifying their identifiers
.DESCRIPTION
    Requires host-group:write
.PARAMETER ID
    The host group identifiers to delete
.EXAMPLE
    PS> Remove-Group -Id group_id_1, group_id_2
    Removes host groups 'group_id_1' and 'group_id_2'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id
    )
    process {
        $Param = @{
            Uri    = '/devices/entities/host-groups/v1?ids=' + ($Id -join '&ids=')
            Method = 'delete'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}