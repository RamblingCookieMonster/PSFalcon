function Edit-Detection {
<#
.SYNOPSIS
    Modify the state, assignee, and visibility of detections
.DESCRIPTION
    Requires detects:write
.PARAMETER ID
    One or more detection identifiers
.PARAMETER STATUS
    Detection status
.PARAMETER UUID
    Assign the detection to a specific user identifier
.PARAMETER COMMENT
    Optional comment to add to the detection
.PARAMETER SHOW
    Show/Hide the detection
.EXAMPLE
    PS> Edit-CsDetection -Id detection_id_1 -Status 'true_positive'
    Sets the status for 'detection_id_1' to 'true_positive'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('new', 'in_progress', 'true_positive', 'false_positive', 'ignored')]
        [string] $Status,

        [Parameter(ParameterSetName = 'default')]
        [string] $UUID,

        [Parameter(ParameterSetName = 'default')]
        [string] $Comment,

        [Parameter(ParameterSetName = 'default')]
        [boolean] $Show
    )
    process {
        $Body = @{ ids = @( $Id ) }

        switch ($PSBoundParameters.Keys) {
            'Comment' { $Body['comment'] = $Comment }
            'Show' { $Body['show_in_ui'] = $Show }
            'Status' { $Body['status'] = $Status }
            'UUID' { $Body['assigned_to_uuid'] = $UUID }
        }
        $Param = @{
            Uri    = '/detects/entities/detects/v2'
            Method = 'patch'
            Header = @{
                accept         = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = ConvertTo-Json -InputObject $Body
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}

