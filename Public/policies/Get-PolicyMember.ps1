function Get-PolicyMember {
<#
.SYNOPSIS
    Search for policy members in your environment
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:read
    firewall-management:read
    prevention-policies:read
    sensor-update-policies:read
.PARAMETER TYPE
    Type of policy
.PARAMETER ID
    Policy identifier
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
    PS> Get-CsPolicyMember -Id policy_id_1
    Returns member device identifiers
.EXAMPLE
    PS> Get-CsPolicyMember -Id policy_id_1 -Detailed
    Returns detailed member device information
.EXAMPLE
    PS> Get-CsPolicyMember -Id policy_id_1 -Filter "hostname:'Example'"
    Returns device identifiers for devices with hostname 'Example' in 'policy_id_1'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

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
    begin {
        switch ($Type) {
            'DeviceControl' {
                $QueryUri = '/policy/queries/device-control-members/v1?id='
                $CombinedUri = '/policy/combined/device-control-members/v1?id='
            }
            'Firewall' {
                $QueryUri = '/policy/queries/firewall-members/v1?id='
                $CombinedUri = '/policy/combined/firewall-members/v1?id='
            }
            'SensorUpdate' {
                $QueryUri = '/policy/queries/sensor-update-members/v1?id='
                $CombinedUri = '/policy/combined/sensor-update-members/v1?id='
            }
            'Prevention' {
                $QueryUri = '/policy/queries/prevention-members/v1?id='
                $CombinedUri = '/policy/combined/prevention-members/v1?id='
            }
        }
    }
    process {
        $LoopParam = @{
            Type = $Type
            Id = $Id
        }
        $Param = @{
            Uri    = $QueryUri + $Id
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $LoopParam['Detailed'] = $true

            $Param.Uri = $CombinedUri + $Id
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
        } else {
            Invoke-Api @Param
        }
    }
}