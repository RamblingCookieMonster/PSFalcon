function Get-Behavior {
<#
.SYNOPSIS
    Search for behaviors in your environment
.DESCRIPTION
    Requires incidents:read
.PARAMETER ID
    Retrieve detailed information for specific behavior identifiers
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
    PS> Get-CsBehavior
    Returns an unfiltered list of behavior identifiers
.EXAMPLE
    PS> Get-CsBehavior -Detailed
    Returns an unfiltered list of detailed behavior information
.EXAMPLE
    PS> Get-CsBehavior -Filter "aid:'host_id_1'"
    Returns behavior identifiers involving 'host_id_1'
.EXAMPLE
    PS> Get-CsBehavior -Id behavior_id_1, behavior_id_2
    Returns detail about behavior identifiers 'behavior_id_1' and 'behavior_id_2'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 500)]
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
            Uri    = '/incidents/queries/behaviors/v1?'
            Method = 'get'
            Header = @{
                accept         = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Id' {
                $Param.Uri = '/incidents/entities/behaviors/GET/v1'
                $Param.Method = 'post'
                $Param['Body'] = @{ ids = $Id } | ConvertTo-Json
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
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                $Param.Uri = '/incidents/entities/behaviors/GET/v1'
                $Param.Method = 'post'
                $Param['Body'] = @{ ids = $Request.resources } | ConvertTo-Json

                Invoke-Api @Param
            } else {
                $Request
            }
        }
    }
}