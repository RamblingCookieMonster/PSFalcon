function Get-Group {
<#
.SYNOPSIS
    Search for host groups in your environment
.DESCRIPTION
    Requires host-group:read
.PARAMETER ID
    Retrieve detailed information or members for specific host group identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset integer to retrieve next result set
.PARAMETER DETAIL
    Retrieve detailed information
.PARAMETER MEMBERS
    Retrieve identifiers for the members of a host group
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsGroup
    Returns an unfiltered list of host group identifiers
.EXAMPLE
    PS> Get-CsGroup -Detail
    Returns an unfiltered list of detailed host group information
.EXAMPLE
    PS> Get-CsGroup -Id group_id_1 -Members -Detail
    Returns detailed host information for members of 'group_id_1'
.EXAMPLE
    PS> Get-CsGroup -Filter "name:'Example'"
    Returns the identifier for a host group named 'Example'
.EXAMPLE
    PS> Get-CsGroup -Id group_id_1, group_id_2
    Returns detail about host group identifiers 'group_id_1' and 'group_id_2'
.LINK
    https://assets.falcon.crowdstrike.com/support/api/swagger.html#/host-group
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [Parameter(ParameterSetName = 'members', Mandatory = $true)]
        [ValidateScript({
            if (($PSBoundParameters.Members -eq $true) -and ($_.count -eq 1)) {
                $true
            } else {
                throw 'Only one identifier permitted when requesting members.'
            }
            if ($_.count -le 2000) {
                $true
            } else {
                throw 'Maximum of 2000 ids per request.'
            }
        })]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [ValidateRange(1, 2000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [switch] $Detail,

        [Parameter(ParameterSetName = 'members', Mandatory = $true)]
        [switch] $Members,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/devices/queries/host-groups/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Members) {
            if ($Detail) {
                $Param.Uri = '/devices/combined/host-group-members/v1?id=' + [string] $Id
            } else {
                $Param.Uri = '/devices/queries/host-group-members/v1?id=' + [string] $Id
            }
            $LoopParam['Members'] = $true
        } elseif ($Detail) {
            $Param.Uri = '/devices/combined/host-groups/v1?'
        } elseif ($Id) {
            $Param.Uri = '/devices/entities/host-groups/v1?ids=' + ($Id -join '&ids=')
        }
        switch ($PSBoundParameters.Keys) {
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
            if ($Detail) {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detail
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } else {
            Invoke-Api @Param
        }
    }
}