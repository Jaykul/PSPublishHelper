function Resolve-NugetCommand {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet
    )
    end {
        $ErrorCmdlet = $Cmdlet
        if (-not $Cmdlet) {
            $ErrorCmdlet = $PSCmdlet
        }
        $Params = @{
            Name        = 'nuget', "dotnet"
            CommandType = 'Application'
            ErrorAction = 'SilentlyContinue'
        }
        $App = Get-Command @Params
        if ($dotnet = $App.Where({ $_.Name -match "^dotnet" -and $_.Version -gt "10.0" }) | Sort-Object Version -Descending | Select-Object -First 1) {
            return $dotnet
        }
        if ($nuget = $App.Where({ $_.Name -match "^nuget" }) | Sort-Object Version -Descending | Select-Object -First 1) {
            return $nuget
        }

        $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.ItemNotFoundException]::new(
                "Unable to find nuget binary or dotnet SDK >= 10. Nuget (or SDK 10 or higher) is required for packing."
            ),
            "NugetNotFound",
            [System.Management.Automation.ErrorCategory]::NotInstalled,
            $null
        )
        $ErrorCmdlet.ThrowTerminatingError($ErrorRecord)
    }
}
