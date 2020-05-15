function Get-Policy {
<#
.SYNOPSIS
    Search for policies in your environment
.DESCRIPTION
    Requires prevention-policies:read
.PARAMETER TYPE
    Type of policy
.PARAMETER ID
    Retrieve detailed information about specific policy identifiers
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
    PS> Get-CsPolicy
    Returns policy identifiers
.EXAMPLE
    PS> Get-CsPolicy -Detailed
    Returns detailed policy information
.EXAMPLE
    PS> Get-CsPolicy -Filter "name:'Example'"
    Returns the policy identifier for a policy named 'Example'
.EXAMPLE
    PS> Get-CsPolicy -Id policy_id_1, policy_id_2
    Returns detail about policy identifiers 'policy_id_1' and 'policy_id_2'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

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
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    begin {
        switch ($Type) {
            'DeviceControl' {
                $QueryUri = '/policy/queries/device-control/v1?'
                $CombinedUri = '/policy/combined/device-control/v1?'
                $EntityUri = '/policy/entities/device-control/v1?ids='
            }
            'Firewall' {
                $QueryUri = '/policy/queries/firewall/v1?'
                $CombinedUri = '/policy/combined/firewall/v1?'
                $EntityUri = '/policy/entities/firewall/v1?ids='
            }
            'SensorUpdate' {
                $QueryUri = '/policy/queries/sensor-update/v1?'
                $CombinedUri = '/policy/combined/sensor-update/v2?'
                $EntityUri = '/policy/entities/sensor-update/v2?ids='
            }
            'Prevention' {
                $QueryUri = '/policy/queries/prevention/v1?'
                $CombinedUri = '/policy/combined/prevention/v1?'
                $EntityUri = '/policy/entities/prevention/v1?ids='
            }
        }
    }
    process {
        $LoopParam = @{
            Type = $Type
        }
        $Param = @{
            Uri    = $QueryUri
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $LoopParam['Detailed'] = $true

            $Param.Uri = $CombinedUri
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
            Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
        } elseif ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = $EntityUri + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}