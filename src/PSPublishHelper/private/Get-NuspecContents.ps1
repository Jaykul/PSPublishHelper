function Get-NuspecContents {
    [OutputType([String])]
    [CmdletBinding()]
    param (
        [PSModuleInfo]
        $Module,

        [Hashtable]
        $PSData
    )
    end {

        $VersionText = Resolve-PSModuleVersion -Module $Module -PSData $PSData

        $TagsText = Resolve-PSModuleTags -Module $Module -Tags $PSData.Tags

        $RequireLicenseAcceptanceText = ([bool]$PSData.RequireLicenseAcceptance).ToString().ToLower()

        $Description = $Module.Description
        if ([string]::IsNullOrWhiteSpace($Description)) {
            $Description = $Module.Name
        }

        $ArgumentList = [System.Collections.Generic.List[string]]::new()
        @(
            $Module.Name,
            $VersionText,
            $Module.Author,
            $Module.CompanyName,
            $Description,
            $Module.ReleaseNotes,
            $RequireLicenseAcceptanceText,
            $Module.Copyright,
            $TagsText
        ) | Get-EscapedString | ForEach-Object {
            $ArgumentList.Add($_)
        }

        $LicenseUriText = if ($PSData.LicenseUri) {
            if (($Uri = $PSData.LicenseUri -as [Uri]) -and -not $Uri.IsAbsoluteUri) {
                if ($PSData.LicenseUri -notmatch "\\|/") {
                    '<license type="expression">{0}</license>' -f ($PSData.LicenseUri | Get-EscapedString)
                } else {
                    '<license type="file">{0}</license>' -f ($PSData.LicenseUri | Get-EscapedString)
                }
            } else {
                '<licenseUrl>{0}</licenseUrl>' -f ($PSData.LicenseUri | Get-EscapedString)
            }
        }
        $ArgumentList.Add($LicenseUriText)

        $ProjectUriText = if ($PSData.ProjectUri) {
            '<projectUrl>{0}</projectUrl>' -f ($PSData.ProjectUri | Get-EscapedString)
        }
        $ArgumentList.Add($ProjectUriText)

        $IconUriText = if ($PSData.IconUri) {
            if (($Uri = $PSData.IconUri -as [Uri]) -and -not $Uri.IsAbsoluteUri) {
                '<icon>{0}</icon>' -f ($PSData.IconUri | Get-EscapedString)
            } else {
                '<iconUrl>{0}</iconUrl>' -f ($PSData.IconUri | Get-EscapedString)
            }
        }
        $ArgumentList.Add($IconUriText)

        $DependencyText = @(
            $Module | Resolve-PSModuleDependency -ExternalModuleDependencies $PSData.ExternalModuleDependencies | Format-PSModuleDependency
        ) -Join ([Environment]::NewLine)
        $ArgumentList.Add($DependencyText)

        $Script:Nuspec -f $ArgumentList.ToArray()
    }
}
