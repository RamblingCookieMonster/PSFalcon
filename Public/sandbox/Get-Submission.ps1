function Get-Submission {
<#
.SYNOPSIS
    Search for sandbox submissions in your environment
.DESCRIPTION
    Requires falconx-sandbox:read
.PARAMETER ID
    Retrieve detailed information for specific sandbox submission identifiers
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
    PS> Get-CsSubmission
    Returns an unfiltered list of sandbox submission identifiers
.EXAMPLE
    PS> Get-CsSubmission -Detailed
    Returns an unfiltered list of detailed sandbox submission information
.EXAMPLE
    PS> Get-CsSubmission -Filter 
    Returns identifiers for sandbox submissions with
.EXAMPLE
    PS> Get-CsSubmission -Id submission_id_1, submission_id_2
    Returns detail about sandbox submission identifiers 'submission_id_1' and 'submission_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
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
        [string] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/falconx/queries/submissions/v1?'
            Method = 'get'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' + [System.Web.HTTPUtility]::UrlEncode($Filter)
                $LoopParam['Filter'] = $Filter
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
            if ($Detailed) {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } elseif ($Id) {
            $Uri = '/falconx/entities/submissions/v1?ids='

            Split-Array -Uri $Uri -Join '&ids=' -Id $Id | ForEach-Object {
                $Param.Uri = $Uri + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                $Uri = '/falconx/entities/submissions/v1?ids='

                Split-Array -Uri $Uri -Join '&ids=' -Id $Request.resources | ForEach-Object {
                    $Param.Uri = $Uri + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}