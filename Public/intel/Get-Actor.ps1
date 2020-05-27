function Get-Actor {
<#
.SYNOPSIS
    Search for actor identifiers and information
.DESCRIPTION
    Requires falconx-actors:read
.PARAMETER ID
    Retrieve detailed information about specific actor identifiers
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
    PS> Get-CsActor
    Returns actor identifiers
.EXAMPLE
    PS> Get-CsActor -Detailed
    Returns detailed actor information
.EXAMPLE
    PS> Get-CsActor -Filter "name:'Fancy Bear'"
    Returns the identifier for the actor named 'Fancy Bear'
.EXAMPLE
    PS> Get-CsActor -Id actor_id_1, actor_id_2
    Returns detail about actor identifiers 'actor_id_1' and 'actor_id_2'
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
            Uri    = '/intel/queries/actors/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $Param.Uri = '/intel/combined/actors/v1?fields=' + ($Field -join '&fields=')
            $LoopParam['Detailed'] = $true
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' +  [System.Web.HTTPUtility]::UrlEncode($Filter)
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
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/intel/entities/actors/v1?fields=' + ($Field -join '&fields=') +
                '&ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}