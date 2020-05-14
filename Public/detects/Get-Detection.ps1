function Get-Detection {
<#
.SYNOPSIS
    Search for detections in your environment
.DESCRIPTION
    Requires detects:read
.PARAMETER ID
    Retrieve detailed information for specific detection identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER QUERY
    Search all detection metadata for the provided string
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset integer to retrieve next result set
.PARAMETER HIDDEN
    Narrow search to 'hidden' hosts
.PARAMETER DETAILED
    Retrieve detailed information
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsDetection
    Returns an unfiltered list of detection identifiers
.EXAMPLE
    PS> Get-CsDetection -Detailed
    Returns an unfiltered list of detailed detection information
.EXAMPLE
    PS> Get-CsDetection -Filter "status:'new'"
    Returns identifiers for detections with a status of 'new'
.EXAMPLE
    PS> Get-CsDetection -Id detection_id_1, detection_id_2
    Returns detail about detection identifiers 'detection_id_1' and 'detection_id_2'
.LINK
    https://assets.falcon.crowdstrike.com/support/api/swagger.html#/detects
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [ValidateScript({
            if ($_.count -le 1000) {
                $true
            } else {
                throw 'Maximum of 1,000 ids per request.'
            }
        })]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [string] $Query,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 9999)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/detects/queries/detects/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Id' {
                $Param.Uri = '/detects/entities/summaries/GET/v1'
                $Param.Method = 'post'
                $Param.Header['accept'] = 'application/json'
                $Param['Body'] = @{ ids = @( $Id ) } | ConvertTo-Json
            }
            'Filter' {
                $Param.Uri += '&filter=' + $Filter
                $LoopParam['Filter'] = $Filter
            }
            'Limit' {
                $Param.Uri += '&limit=' + [string] $Limit
                $LoopParam['Limit'] = $Limit
            }
            'Sort' {
                $Param.Uri += '&sort=' + $Sort
                $LoopParam['Sort'] = $Sort
            }
            'Query' {
                $Param.Uri += '&q=' + $Query
                $LoopParam['Query'] = $Query
            }
            'Offset' {
                $Param.Uri += '&offset=' + [string] $Offset
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
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detail
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                $Param.Uri = '/detects/entities/summaries/GET/v1'
                $Param.Method = 'post'
                $Param.Header['accept'] = 'application/json'
                $Param['Body'] = @{ ids = @( $Request.resources ) } | ConvertTo-Json

                Invoke-Api @Param
            } else {
                $Request
            }
        }
    }
}