function New-Group {
<#
.SYNOPSIS
    Create Host Groups by specifying details about the group to create
.DESCRIPTION
    Requires host-group:write
.PARAMETER NAME
    Host group name
.PARAMETER DESCRIPTION
    Host group description
.PARAMETER TYPE
    Type of host group
.PARAMETER RULE
    The assignment rule, used with dynamic host groups
.EXAMPLE
    PS> New-CsGroup -Name Example -Type static
    Creates a new static host group named 'Example'
.EXAMPLE
    PS> New-CsGroup -Name Workstations -Type dynamic -Rule product_type_desc:'Workstation'+os_version:'Windows 10'"
    Creates a new dynamic host group named 'Workstations' with assignment rules 'Type: Workstations' and "OS: Windows 10"
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Name,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('dynamic', 'static')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default')]
        [string] $Description,

        [Parameter(ParameterSetName = 'default')]
        [ValidateScript({
            if ($PSBoundParameters.Type -eq 'dynamic') {
                $true
            } else {
                throw 'Assignment rule is used with dynamic host groups.'
            }
        })]
        [string] $Rule
    )
    process {
        $Resources = @{
            name       = $Name
            group_type = $Type
        }
        switch ($PSBoundParameters.Keys) {
            'Description' {	$Resources['description'] = $Description }
            'Rule' { $Resources['assignment_rule'] = $Rule }
        }
        $Param = @{
            Uri    = '/devices/entities/host-groups/v1'
            Method = 'post'
            Header = @{
                'content-type' = 'application/json'
            }
            Body   = @{ resources = @( $Resources ) } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}