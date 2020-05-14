function Get-Incident {
<#
.SYNOPSIS
    Search for incidents in your environment
.DESCRIPTION
    Requires incidents:read
.PARAMETER ID
    Retrieve detailed information for specific incident identifiers
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
    PS> Get-CsIncident
    Returns an unfiltered list of incident identifiers
.EXAMPLE
    PS> Get-CsIncident -Detail
    Returns an unfiltered list of detailed incident information
.EXAMPLE
    PS> Get-CsIncident -Filter "host_ids:'host_id_1'"
    Returns incidents identifiers involving 'host_id_1'
.EXAMPLE
    PS> Get-CsIncident -Id incident_id_1, incident_id_2
    Returns detail about incident identifiers 'incident_id_1' and 'incident_id_2'
.LINK
    https://assets.falcon.crowdstrike.com/support/api/swagger.html#/incidents
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
            Uri    = '/incidents/queries/incidents/v1?'
            Method = 'get'
            Header = @{
                accept         = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Id' {
                $Param.Uri = '/incidents/entities/incidents/GET/v1'
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
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detail
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                $Param.Uri = '/incidents/entities/incidents/GET/v1'
                $Param.Method = 'post'
                $Param['Body'] = @{ ids = $Request.resources } | ConvertTo-Json

                Invoke-Api @Param
            } else {
                $Request
            }
        }
    }
}