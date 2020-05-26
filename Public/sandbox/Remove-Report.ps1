function Remove-Report {
<#
.SYNOPSIS
    Delete a set of sandbox reports by specifying their identifiers
.DESCRIPTION
    Requires falconx-sandbox:write
.PARAMETER ID
    The sandbox report identifiers to delete
.EXAMPLE
    PS> Remove-CsReport -Id report_id_1, report_id_2
    Removes sandbox reports 'report_id_1' and 'report_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Id
    )
    process {
        $Param = @{
            Uri    = '/falconx/entities/reports/v1?ids=' + ($Id -join '&ids=')
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