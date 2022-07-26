<#
    .SYNOPSIS
        Returns the current permissions for the database principal.

    .PARAMETER DatabasePermissionInfo
        Specifies current server connection object.

    .PARAMETER DatabaseName
        Specifies the database name.

    .PARAMETER Name
        Specifies the name of the database principal for which the permissions are
        returned.

    .OUTPUTS
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        $databasePermissionInfo = Get-SqlDscDatabasePermission -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal'
        ConvertTo-DatabasePermission -DatabasePermissionInfo $databasePermissionInfo

    .NOTES
#>
function ConvertTo-DatabasePermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([DatabasePermission[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]]
        $DatabasePermissionInfo
    )

    begin
    {
        [DatabasePermission[]] $permissions = @()
    }

    process
    {
        $permissionState = foreach ($currentDatabasePermissionInfo in $DatabasePermissionInfo)
        {
            # Convert from the type PermissionState to String.
            [System.String] $currentDatabasePermissionInfo.PermissionState
        }

        $permissionState = $permissionState | Select-Object -Unique

        foreach ($currentPermissionState in $permissionState)
        {
            $filteredDatabasePermission = $DatabasePermissionInfo |
                Where-Object -FilterScript {
                    $_.PermissionState -eq $currentPermissionState
                }

            $databasePermissionStateExist = $permissions.Where({
                $_.State -contains $currentPermissionState
            }) |
                Select-Object -First 1

            if ($databasePermissionStateExist)
            {
                $databasePermission = $databasePermissionStateExist
            }
            else
            {
                $databasePermission = [DatabasePermission] @{
                    State = $currentPermissionState
                    Permission = [System.String[]] @()
                }
            }

            foreach ($currentPermission in $filteredDatabasePermission)
            {
                # Get the permission names that is set to $true
                $permissionProperty = $currentPermission.PermissionType |
                    Get-Member -MemberType 'Property' |
                    Select-Object -ExpandProperty 'Name' -Unique |
                    Where-Object -FilterScript {
                        $currentPermission.PermissionType.$_
                    }


                foreach ($currentPermissionProperty in $permissionProperty)
                {
                    $databasePermission.Permission += $currentPermissionProperty
                }
            }

            # Only add the object if it was created.
            if (-not $databasePermissionStateExist)
            {
                $permissions += $databasePermission
            }
        }
    }

    end
    {
        return $permissions
    }
}
