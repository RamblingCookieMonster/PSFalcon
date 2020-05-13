function Format-Response {
<#
.SYNOPSIS
    Formats a CrowdStrike Falcon OAuth2 API response as a PSObject
.PARAMETER REQUEST
    Result object from Invoke-Api
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 0)]
        [psobject] $Request
    )
    process {
        # Create output
        $Output = [PSCustomObject] @{
            PSTypeName = 'PSFalcon.Object'
        }
        # Add response headers
        if ($Request.Headers) {
            $Output.PSObject.Properties.Add((New-Object PSNoteProperty('headers',$Request.Headers)))
        }
        # Add status message
        if ($Request.StatusCode) {
            $Output.PSObject.Properties.Add((New-Object PSNoteProperty('status',(
            [string] $Request.StatusCode + ' ' + $Request.StatusDescription))))
        }
        $Json = if ($Request.Content) {
            # Convert successful result from Json
            ConvertFrom-Json -InputObject $Request.Content
        } elseif ($Request.Message) {
            # Convert error from Json
            ConvertFrom-Json -InputObject $Request.Message
        }
        [array] $Default = if ($Json) {
            ($Json | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
                # Add Json content to output
                $Output.PSObject.Properties.Add((New-Object PSNoteProperty($_,$Json.$_)))

                # Collect populated fields for display
                if (($Json.$_) -and ($_ -ne 'meta')) {
                    Write-Output $_
                }
            }
        }
        # Select 'status' if all other response fields are empty
        if ($Default.count -eq 0) {
            [array] $Default = 'status'
        }
        # Set default display properties for output
        $Display = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',
        [string[]] $Default)

        $Standard = [System.Management.Automation.PSMemberInfo[]] @($Display)

        $Output | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $Standard
    }
    end {
        $Output
    }
}