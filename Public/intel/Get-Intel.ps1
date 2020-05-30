function Get-Intel {
<#
.SYNOPSIS
    Search for intelligence report identifiers and information
.DESCRIPTION
    Requires falconx-reports:read
.PARAMETER ID
    Retrieve detailed information about specific intelligence report identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER FIELD
    Fields to return, or a predefined set of fields in the form of the collection name [default: __basic__]
.PARAMETER QUERY
    Perform a generic substring search across all fields
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
    PS> Get-CsIntel
    Returns intelligence report identifiers
.EXAMPLE
    PS> Get-CsIntel -Detailed
    Returns detailed intelligence report information
.EXAMPLE
    PS> Get-CsIntel -Filter "motivations:'espionage'"
    Returns identifiers for intelligence reports containing the motivation 'espionage'
.EXAMPLE
    PS> Get-CsIntel -Id report_id_1, report_id_2
    Returns detail about intelligence report identifiers 'report_id_1' and 'report_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [string] $Query,

        [Parameter(ParameterSetName = 'id')]
        [Parameter(ParameterSetName = 'combined')]
        [string] $Field,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'combined')]
        [switch] $All
    )
    begin {
        if ($Id -or $Detailed -and (-not($Field))) {
            $Field = '__basic__'
        }
    }
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/intel/queries/reports/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $Param.Uri = '/intel/combined/reports/v1?fields=' + ($Field -join '&fields=')
            $LoopParam['Detailed'] = $true
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' + [System.Web.HTTPUtility]::UrlEncode($Filter)
                $LoopParam['Filter'] = $Filter
            }
            'Query' {
                $Param.Uri += '&q=' + $Query
                $LoopParam['Query'] = $Query
            }
            'Field' {
                $Param.Uri += '&fields=' + ($Field -join '&fields=')
                $LoopParam['Field'] = $Field
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
            Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
        } elseif ($Id) {
            $Uri = '/intel/entities/reports/v1?fields=' + ($Field -join '&fields=') + '&ids='

            Split-Array -Uri $Uri -Join '&ids=' -Id $Id | ForEach-Object {
                $Param.Uri = $Uri + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}