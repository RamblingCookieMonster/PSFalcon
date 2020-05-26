function Get-Report {
<#
.SYNOPSIS
    Search for sandbox reports in your environment
.DESCRIPTION
    Requires falconx-sandbox:read
.PARAMETER ID
    Retrieve detailed information for specific sandbox report identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset integer to retrieve next result set
.PARAMETER DETAILED
    Retrieve detailed information
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsReport
    Returns an unfiltered list of sandbox report identifiers
.EXAMPLE
    PS> Get-CsReport -Detailed
    Returns an unfiltered list of detailed sandbox report information
.EXAMPLE
    PS> Get-CsReport -Filter 
    Returns identifiers for sandbox reports with
.EXAMPLE
    PS> Get-CsReport -Id report_id_1, report_id_2
    Returns detail about sandbox report identifiers 'report_id_1' and 'report_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [string] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/falconx/queries/reports/v1?'
            Method = 'get'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' + $Filter
                $LoopParam['Filter'] = $Filter
            }
            'Offset' {
                $Param.Uri += '&offset=' + $Offset
                $LoopParam['Offset'] = $Offset
            }
            'Limit' {
                $Param.Uri += '&limit=' + $Limit
                $LoopParam['Limit'] = $Limit
            }
            'Sort' {
                $Param.Uri += '&sort=' + $Sort
                $LoopParam['Sort'] = $Sort
            }
            'Verbose' {
                $Param['Verbose'] = $true
                $LoopParam['Verbose'] = $true
            }
            'Debug' {
                $Param['Debug'] = $true
                $LoopParam['Debug'] = $true
            }
        }
        if ($All) {
            if ($Detailed) {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } elseif ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/falconx/entities/report-summaries/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                Split-Array -Uri $Param.Uri -Id $Request.resources | ForEach-Object {
                    $Param.Uri = '/falconx/entities/report-summaries/v1?ids=' + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}