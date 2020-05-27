function Get-GroupMember {
<#
.SYNOPSIS
    Search for host group members in your environment
.DESCRIPTION
    Requires host-group:read
.PARAMETER ID
    Host group identifier
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
    PS> Get-CsGroupMember -Id group_id_1
    Returns member device identifiers
.EXAMPLE
    PS> Get-CsGroupMember -Id group_id_1 -Detailed
    Returns detailed member device information
.EXAMPLE
    PS> Get-CsGroupMember -Id group_id_1 -Filter "hostname:'Example'"
    Returns device identifiers for devices with hostname 'Example' in 'group_id_1'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 5000)]
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
        $LoopParam = @{
            Id = $Id
        }
        $Param = @{
            Uri    = '/devices/queries/host-group-members/v1?id=' + $Id
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $LoopParam['Detailed'] = $true

            $Param.Uri = '/devices/combined/host-group-members/v1?id=' + $Id
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' +  [System.Web.HTTPUtility]::UrlEncode($Filter)
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
            Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
        } else {
            Invoke-Api @Param
        }
    }
}