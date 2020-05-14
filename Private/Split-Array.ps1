function Split-Array {
<#
.SYNOPSIS
    Splits large 'id' arrays into smaller groups
.PARAMETER URI
    Destination Uri, used to find maximum string length for Invoke-WebRequest Uri parameter
.PARAMETER ID
    Array of 'id' values
#>
[CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Uri,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id
    )
    process {
        # Character length of longest value in the array
        $LargestId = ($Id | Measure-Object -Maximum -Property Length).Maximum

        # Maximum number of ids
        $MaxIds = [Math]::Floor([decimal](((65535 - ($Falcon.host + $Uri).length)/$LargestId)/1))

        # Output smaller groups
        for ($i = 0; $i -lt $Id.count; $i += $MaxIds) { ,@($Id)[$i..($i + ($MaxIds - 1))] }
    }
}
