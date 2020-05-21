function Get-Indicator {
<#
.SYNOPSIS
    Search for indicator identifiers and information
.DESCRIPTION
    Requires falconx-indicators:read
.PARAMETER ID
    Retrieve detailed information about specific indicator identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER QUERY
    Perform a generic substring search across all fields
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset integer to retrieve next result set
.PARAMETER DELETED
    Include both published and deleted indicators [default: false]
.PARAMETER DETAILED
    Retrieve detailed information
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsIndicator
    Returns indicator identifiers
.EXAMPLE
    PS> Get-CsIndicator -Detailed
    Returns detailed indicator information
.EXAMPLE
    PS> Get-CsIndicator -Filter "type:'hash_sha256'"
    Returns identifiers for indicators of type 'hash_sha256'
.EXAMPLE
    PS> Get-CsIndicator -Id indicator_id_1, indicator_id_2
    Returns detail about indicator identifiers 'indicator_id_1' and 'indicator_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [string] $Query,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Deleted,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/intel/queries/indicators/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $Param.Uri = '/intel/combined/indicators/v1?'
            $LoopParam['Detailed'] = $true
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' + $Filter
                $LoopParam['Filter'] = $Filter
            }
            'Query' {
                $Param.Uri += '&q=' + $Query
                $LoopParam['Query'] = $Query
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
            'Deleted' {
                $Param.Uri += '&includedeleted=' + $Deleted
                $LoopParam['Deleted'] = $Deleted
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
            $Param.Uri = '/intel/entities/indicators/GET/v1'
            $Param.Method = 'post'
            $Param.Header['accept'] = 'application/json'
            $Param['Body'] = @{ ids = $Id } | ConvertTo-Json

            Invoke-Api @Param
        } else {
            Invoke-Api @Param
        }
    }
}