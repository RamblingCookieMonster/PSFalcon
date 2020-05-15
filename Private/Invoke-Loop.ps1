function Invoke-Loop {
<#
.SYNOPSIS
    Repeats PSFalcon commands until all results are retrieved
.PARAMETER COMMAND
    The PSFalcon command to repeat
.PARAMETER PARAM
    Parameters to include when running the command
.PARAMETER DETAILED
    Retrieve detailed information
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Command,

        [Parameter(ParameterSetName = 'default')]
        [hashtable] $Param,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed
    )
    process {
        if ($Detailed) {
            # Request ids
            $Loop = & $Command @Param

            if ($Loop.resources) {
                # Output detail
                & $Command -Id $Loop.resources
            }
        } else {
            # Output ids
            & $Command @Param -OutVariable Loop
        }
        if ($Loop.resources) {
            for ($i = $Loop.resources.count; $i -lt $Loop.meta.pagination.total; $i += $Loop.resources.count) {
                # Output progress
                $Progress = @{
                    Activity = $Command
                    Status = [string] $i + ' of ' + [string] $Loop.meta.pagination.total
                    PercentComplete = ($i/$Loop.meta.pagination.total)*100
                }
                Write-Progress @Progress

                # Set pagination
                if ($Loop.meta.pagination.after) {
                    # token-based after
                    $Param['After'] = $Loop.meta.pagination.after
                } else {
                    $Param['Offset'] = if ($Loop.meta.pagination.offset -match '\d{1,}$') {
                        # integer-based offset, use current count
                        $i
                    } else {
                        # token-based offset
                        $Loop.meta.pagination.offset
                    }
                }
                if ($Detailed) {
                    # Retrieve ids
                    $Loop = & $Command @Param

                    if ($Loop.resources) {
                        # Output detail
                        & $Command -Id $Loop.resources
                    }
                } else {
                    # Output ids
                    & $Command @Param -OutVariable Loop
                }
            }
        } else {
            # Output error
            $Loop
        }
    }
}
