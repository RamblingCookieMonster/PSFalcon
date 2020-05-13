function Invoke-Loop {
<#
.SYNOPSIS
    Repeats PSFalcon commands until all results are output
.PARAMETER COMMAND
    The command to repeat
.PARAMETER PARAM
    Parameters to include when running the command
.PARAMETER DETAIL
    Retrieve detailed information
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default')]
        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter(ParameterSetName = 'default')]
        [hashtable] $Param,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detail
    )
    process {
        # Run initial command
        if ($Detail) {
            & $Command -Id (& $Command @Param -OutVariable Loop).resources
        } else {
            & $Command @Param -OutVariable Loop
        }
        # Determine initial and total counts
        $Total = $Loop.meta.pagination.total
        $Count = $Loop.resources.count

        while (($Total -gt $Count) -and (-not($Loop.errors))) {
            # Output progress
            if ($Total -gt $Count) {
                $Progress = @{
                    Activity = $Command
                    Status = [string] $Count + ' of ' + [string] $Loop.meta.pagination.total
                    PercentComplete = ($Count/$Loop.meta.pagination.total)*100
                }
                Write-Progress @Progress
            }
            # Update pagination
            if ($Detail) {
                if ($Loop.meta.pagination.after) {
                    # token-based after
                    & $Command -Id (& $Command @Param -After (
                    $Loop.meta.pagination.after) -OutVariable Loop).resources
                } else {
                    $Offset = if ($Loop.meta.pagination.offset -match '\d{1,}$') {
                        # integer-based offset
                        $Count
                    } else {
                        # token-based offset
                        $Loop.meta.pagination.offset
                    }
                    # Repeat command
                    & $Command -Id (& $Command @Param -Offset $Offset -OutVariable Loop).resources
                }
            } else {
                if ($Loop.meta.pagination.after) {
                    # token-based after
                    & $Command @Param -After $Loop.meta.pagination.after -OutVariable Loop
                } else {
                    $Offset = if ($Loop.meta.pagination.offset -match '\d{1,}$') {
                        # integer-based offset
                        $Count
                    } else {
                        # token-based offset
                        $Loop.meta.pagination.offset
                    }
                    # Repeat command
                    & $Command @Param -Offset $Offset -OutVariable Loop
                }
            }
            # Update count
            $Count += $Loop.resources.count
        }
    }
}
