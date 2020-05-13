function Get-ExportList {
<#
.SYNOPSIS
    Outputs 'FunctionsToExport' text for module manifest
#>
    [CmdletBinding()]
    param()
    begin {
        # Directories in Public folder
        $DirectoryList = (Get-ChildItem -Path ($PSScriptRoot + '\..\Public\')).Name

        # Files in Public folder
        $ModuleList = Get-ChildItem -Path ($PSScriptRoot + '\..\Public\*\*.ps1')
    }
    process {
        $ExportList = try {
            foreach ($Directory in $DirectoryList) {
                # Add comment header with directory name
                Write-Output ("`n# " + $Directory)

                # Add module names
                Write-Output ("'" + (($ModuleList | Where-Object { ($_.Directory |
                Split-Path -Leaf) -eq $Directory }).BaseName -join "',`n'") + "',")
            }
        } catch {
            Write-Output $_
        }
        # Trim trailing comma from final output string
        $Output = $ExportList -replace ($ExportList[($ExportList.Length-1)]),($ExportList[(
        $ExportList.Length-1)]).SubString(0,(($ExportList[($ExportList.Length-1)]).Length-1))
    }
    end {
        $Output
    }
}