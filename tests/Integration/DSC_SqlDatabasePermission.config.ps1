#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file,
        for real testing scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName          = 'localhost'
                CertificateFile   = $env:DscPublicCertificatePath

                # This must be the FQDN username (username@domain).
                UserName          = 'SqlAdmin@{0}' -f $env:COMPUTERNAME
                Password          = 'P@ssw0rd1'

                ServerName        = $env:COMPUTERNAME
                InstanceName      = 'DSCSQLTEST'

                # This is created by the SqlDatabase integration tests.
                DatabaseName      = 'Database1'

                # This is created by the SqlDatabaseUser integration tests.
                User1_Name        = 'User1'
            }
        )
    }
}

<#
    .SYNOPSIS
        Grant rights in a database for a user.
#>
Configuration DSC_SqlDatabasePermission_Grant_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            ServerName           = $Node.ServerName
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = $Node.User1_Name
            Permission   = @(
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                        'Select'
                        'CreateTable'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
            )

            Credential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.UserName, (ConvertTo-SecureString -String $Node.Password -AsPlainText -Force))
        }
    }
}

<#
    .SYNOPSIS
        Remove granted rights in the database for a user.
#>
Configuration DSC_SqlDatabasePermission_RemoveGrant_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = $Node.User1_Name
            Permission   = @(
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Deny rights in a database for a user.
#>
Configuration DSC_SqlDatabasePermission_Deny_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = $Node.User1_Name
            Permission   = @(
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @(
                        'Select'
                        'CreateTable'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                    )
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Remove deny rights in a database for a user.
#>
Configuration DSC_SqlDatabasePermission_RemoveDeny_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = $Node.User1_Name
            Permission   = @(
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                    )
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Grant rights in a database for the guest user.

    .NOTES
        Regression test for issue #1134.
#>
Configuration DSC_SqlDatabasePermission_GrantGuest_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = 'guest'
            Permission   = @(
                <#
                    These are in the order Deny, Grant, and GrantWithGrant on purpose,
                    to verify the objects are sorted correctly by Compare().
                #>
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                        'Select'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Remove the granted rights in a database for the guest user.

    .NOTES
        Regression test for issue #1134.
#>
Configuration DSC_SqlDatabasePermission_RemoveGrantGuest_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = 'guest'
            Permission   = @(
                <#
                    These are in the order Deny, Grant, and GrantWithGrant on purpose,
                    to verify the objects are sorted correctly by Compare().
                #>
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Grant rights in a database for the user-defined role 'public'.

    .NOTES
        Regression test for issue #1498.
#>
Configuration DSC_SqlDatabasePermission_GrantPublic_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = 'public'
            Permission   = @(
                <#
                    These are in the order Deny, Grant, and GrantWithGrant on purpose,
                    to verify the objects are sorted correctly by Compare().
                #>
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                        'Select'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
            )
        }
    }
}

<#
    .SYNOPSIS
        Remove the granted rights in a database for the user-defined role 'public'.

    .NOTES
        Regression test for issue #1498.
#>
Configuration DSC_SqlDatabasePermission_RemoveGrantPublic_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlDatabasePermission 'Integration_Test'
        {
            InstanceName         = $Node.InstanceName
            DatabaseName         = $Node.DatabaseName
            Name                 = 'public'
            Permission   = @(
                <#
                    These are in the order Deny, Grant, and GrantWithGrant on purpose,
                    to verify the objects are sorted correctly by Compare().
                #>
                DatabasePermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
                DatabasePermission
                {
                    State      = 'Grant'
                    Permission = @(
                        'Connect'
                    )
                }
                DatabasePermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
            )
        }
    }
}
