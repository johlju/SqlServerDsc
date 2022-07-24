<#
    .SYNOPSIS
        The `SqlDatabasePermission` DSC resource is used to grant, deny or revoke
        permissions for a user in a database

    .DESCRIPTION
        The `SqlDatabasePermission` DSC resource is used to grant, deny or revoke
        permissions for a user in a database. For more information about permissions,
        please read the article [Permissions (Database Engine)](https://docs.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine).

        >**Note:** When revoking permission with PermissionState 'GrantWithGrant', both the
        >grantee and _all the other users the grantee has granted the same permission to_,
        >will also get their permission revoked.

        ## Requirements

        * Target machine must be running Windows Server 2012 or later.
        * Target machine must be running SQL Server Database Engine 2012 or later.

        ## Known issues

        All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabasePermission).

        ### `PSDscRunAsCredential` not supported

        The built-in property `PSDscRunAsCredential` does not work with class-based
        resources that using advanced type like the parameter `Permission` does.
        Use the parameter `Credential` instead of `PSDscRunAsCredential`.

        ### Using `Credential` property.

        SQL Authentication and Group Managed Service Accounts is not supported as
        impersonation credentials. Currently only Windows Integrated Security is
        supported to use as credentials.

        For Windows Authentication the username must either be provided with the User
        Principal Name (UPN), e.g. 'username@domain.local' or if using non-domain
        (for example a local Windows Server account) account the username must be
        provided without the NetBIOS name, e.g. 'username'. The format 'DOMAIN\username'
        will not work.

        See more information in [Credential Overview](https://github.com/dsccommunity/SqlServerDsc/wiki/CredentialOverview).

        ### Invalid values during compilation

        The parameter Permission is of type `[DatabasePermission]`. If a property
        in the type is set to an invalid value an error will occur, this is expected.
        This happens when the values are validated against the `[ValidateSet()]`
        of the resource. In such case the following error will be thrown from
        PowerShell DSC during the compilation of the configuration:

        ```plaintext
        Failed to create an object of PowerShell class SqlDatabasePermission.
            + CategoryInfo          : InvalidOperation: (root/Microsoft/...ConfigurationManager:String) [], CimException
            + FullyQualifiedErrorId : InstantiatePSClassObjectFailed
            + PSComputerName        : localhost
        ```

    .PARAMETER InstanceName
        The name of the SQL Server instance to be configured. Default value is
        'MSSQLSERVER'.

    .PARAMETER DatabaseName
        The name of the database.

    .PARAMETER Name
        The name of the user that should be granted or denied the permission.

    .PARAMETER ServerName
        The host name of the SQL Server to be configured. Default value is the
        current computer name.

    .PARAMETER Permission
        An array of database permissions to enforce. Any permission that is not
        part of the desired state will be revoked.

        Must provide all permission states (`Grant`, `Deny`, `GrantWithGrant`) with
        at least an empty string array for the advanced type `DatabasePermission`'s
        property `Permission`.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToInclude
        An array of database permissions to include to the current state. The
        current state will not be affected unless the current state contradict the
        desired state. For example if the desired state specifies a deny permissions
        but in the current state that permission is granted, that permission will
        be changed to be denied.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToExclude
        An array of database permissions to exclude (revoke) from the current state.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER Credential
        Specifies the credential to use to connect to the _SQL Server_ instance.
        The username of the credentials must be in the format `user@domain`, e.g.
        `MySqlUser@company.local`.

        If parameter **Credential'* is not provided then the resource instance is
        run using the credential that runs the configuration.

    .PARAMETER Ensure
        If the permission should be granted ('Present') or revoked ('Absent').

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.

    .EXAMPLE
        Invoke-DscResource -ModuleName SqlServerDsc -Name SqlDatabasePermission -Method Get -Property @{
            Ensure               = 'Present'
            ServerName           = 'localhost'
            InstanceName         = 'SQL2017'
            DatabaseName         = 'AdventureWorks'
            Credential           = (Get-Credential -UserName 'myuser@company.local' -Message 'Password:')
            Name                 = 'INSTANCE\SqlUser'
            Permission           = [Microsoft.Management.Infrastructure.CimInstance[]] @(
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                            State = 'Grant'
                            Permission = @('select')
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                        State = 'GrantWithGrant'
                        Permission = [System.String[]] @()
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                        State = 'Deny'
                        Permission = [System.String[]] @()
                    }
                )
            )
        }

        This example shows how to call the resource using Invoke-DscResource.

    .NOTES
        The built-in property `PsDscRunAsCredential` is not supported on this DSC
        resource as it uses a complex type (another class as the type for a DSC
        property). If the property `PsDscRunAsCredential` would be used, then the
        complex type will not return any values from Get(). This is most likely an
        issue (bug) with _PowerShell DSC_. Instead (as a workaround) the property
        `Credential` must be used to specify how to connect to the SQL Server
        instance.

#>

[DscResource(RunAsCredential = 'NotSupported')]
class SqlDatabasePermission : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $InstanceName

    [DscProperty(Key)]
    [System.String]
    $DatabaseName

    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty()]
    [System.String]
    $ServerName = (Get-ComputerName)

    [DscProperty()]
    [DatabasePermission[]]
    $Permission

    [DscProperty()]
    [DatabasePermission[]]
    $PermissionToInclude

    [DscProperty()]
    [DatabasePermission[]]
    $PermissionToExclude

    [DscProperty()]
    [PSCredential]
    $Credential

    [DscProperty(NotConfigurable)]
    [Reason[]]
    $Reasons

    SqlDatabasePermission() : base ()
    {
        # These properties will not be enforced.
        $this.notEnforcedProperties = @(
            'ServerName'
            'InstanceName'
            'DatabaseName'
            'Name'
            'Credential'
        )
    }

    [SqlDatabasePermission] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Get() call this method to get the current state as a hashtable.
        The parameter properties will contain the key properties.
    #>
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $currentStateCredential = $null

        if ($this.Credential)
        {
            <#
                TODO: This does not work, Get() will return an empty PSCredential-object.
                      Using MOF-based resource variant does not work either as it throws
                      an error: https://github.com/dsccommunity/ActiveDirectoryDsc/blob/b2838d945204e1153cc3cbfca1a3d90671e0a61c/source/Modules/ActiveDirectoryDsc.Common/ActiveDirectoryDsc.Common.psm1#L1834-L1856
            #>
            $currentStateCredential = [PSCredential]::new(
                $this.Credential.UserName,
                [SecureString]::new()
            )
        }

        # The property Ensure and key properties will be handled by the base class.
        $currentState = @{
            Credential = $currentStateCredential
            Permission = [DatabasePermission[]] @()
        }

        $connectSqlDscDatabaseEngineParameters = @{
            ServerName = $this.ServerName
            InstanceName = $properties.InstanceName
        }

        if ($this.Credential)
        {
            $connectSqlDscDatabaseEngineParameters.Credential = $this.Credential
        }

        # TODO: By adding a hidden property that holds the server object we only need to connect when that property is $null.
        $serverObject = Connect-SqlDscDatabaseEngine @connectSqlDscDatabaseEngineParameters

        # TODO: TA BORT -VERBOSE!
        Write-Verbose -Verbose -Message (
            $this.localizedData.EvaluateDatabasePermissionForPrincipal -f @(
                $properties.Name,
                $properties.DatabaseName,
                $properties.InstanceName
            )
        )

        $databasePermissionInfo = $serverObject |
            Get-SqlDscDatabasePermission -DatabaseName $this.DatabaseName -Name $this.Name -ErrorAction 'SilentlyContinue'

        # If permissions was returned, build the current permission array of [DatabasePermission].
        if ($databasePermissionInfo)
        {
            # TODO: Below code could be a command ConvertTo-DatabasePermission that returns an array of [DatabasePermission]
            <#
                Single out all unique states since every single permission can be
                one object in the $databasePermissionInfo
            #>
            $permissionState = @(
                $databasePermissionInfo | ForEach-Object -Process {
                    # Convert from the type PermissionState to String.
                    [System.String] $_.PermissionState
                }
            ) | Select-Object -Unique

            foreach ($currentPermissionState in $permissionState)
            {
                $filteredDatabasePermission = $databasePermissionInfo |
                    Where-Object -FilterScript {
                        $_.PermissionState -eq $currentPermissionState
                    }

                $databasePermission = [DatabasePermission] @{
                    State = $currentPermissionState
                    Permission = [System.String[]] @()
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

                [DatabasePermission[]] $currentState.Permission += $databasePermission
            }

            # TODO: This need to be done for other permission properties as well.
            <#
                Sort the permissions so they are in the order Grant, GrantWithGrant,
                and Deny. It is because tests that evaluates property $Reasons
                can know the expected order. If there is a better way of handling
                tests for Reasons this can be removed.
            #>
            $currentState.Permission = $currentState.Permission | Sort-Object
        }

        # Always return all State; 'Grant', 'GrantWithGrant', and 'Deny'.
        foreach ($currentPermissionState in @('Grant', 'GrantWithGrant', 'Deny'))
        {
            if ($currentState.Permission.State -notcontains $currentPermissionState)
            {
                [DatabasePermission[]] $currentState.Permission += [DatabasePermission] @{
                    State      = $currentPermissionState
                    Permission = @()
                }
            }
        }

        $isPropertyPermissionToIncludeAssigned = $this | Test-ResourcePropertyIsAssigned -Name 'PermissionToInclude'

        if ($isPropertyPermissionToIncludeAssigned)
        {
            $currentState.PermissionToInclude = [DatabasePermission[]] @()

            # Evaluate so that the desired state is present in the current state.
            foreach ($desiredIncludePermission in $this.PermissionToInclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredIncludePermission.State
                    }

                $currentStatePermissionToInclude = [DatabasePermission] @{
                    State      = $desiredIncludePermission.State
                    Permission = @()
                }

                foreach ($desiredIncludePermissionName in $desiredIncludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredIncludePermissionName)
                    {
                        <#
                            If the permission exist in the current state, add the
                            permission to $currentState.PermissionToInclude so that
                            the base class's method Compare() sees the property as
                            being in desired state (when the property PermissionToInclude
                            in the current state and desired state are equal).
                        #>
                        $currentStatePermissionToInclude.Permission += $desiredIncludePermissionName
                    }
                    else
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredPermissionAreAbsent -f @(
                                $desiredIncludePermissionName
                            )
                        )
                    }
                }

                [DatabasePermission[]] $currentState.PermissionToInclude += $currentStatePermissionToInclude
            }
        }

        $isPropertyPermissionToExcludeAssigned = $this | Test-ResourcePropertyIsAssigned -Name 'PermissionToExclude'

        if ($isPropertyPermissionToExcludeAssigned)
        {
            $currentState.PermissionToExclude = [DatabasePermission[]] @()

            # Evaluate so that the desired state is missing from the current state.
            foreach ($desiredExcludePermission in $this.PermissionToExclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredExcludePermission.State
                    }

                $currentStatePermissionToExclude = [DatabasePermission] @{
                    State      = $desiredExcludePermission.State
                    Permission = @()
                }

                foreach ($desiredExcludedPermissionName in $desiredExcludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredExcludedPermissionName)
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredAbsentPermissionArePresent -f @(
                                $desiredExcludedPermissionName
                            )
                        )
                    }
                    else
                    {
                        <#
                            If the permission does _not_ exist in the current state, add
                            the permission to $currentState.PermissionToExclude so that
                            the base class's method Compare() sees the property as being
                            in desired state (when the property PermissionToExclude in
                            the current state and desired state are equal).
                        #>
                        $currentStatePermissionToExclude.Permission += $desiredExcludedPermissionName
                    }
                }

                [DatabasePermission[]] $currentState.PermissionToExclude += $currentStatePermissionToExclude
            }
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced are not in desired state. It is not called if all properties
        are in desired state. The variable $properties contain the properties
        that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $connectSqlDscDatabaseEngineParameters = @{
            ServerName = $this.ServerName
            InstanceName = $this.InstanceName
        }

        if ($this.Credential)
        {
            $connectSqlDscDatabaseEngineParameters.Credential = $this.Credential
        }

        $serverObject = Connect-SqlDscDatabaseEngine @connectSqlDscDatabaseEngineParameters

        $testSqlDscIsDatabasePrincipalParameters = @{
            ServerObject      = $serverObject
            DatabaseName      = $this.DatabaseName
            Name              = $this.Name
            ExcludeFixedRoles = $true
        }

        # This will test wether the database and the principal exist.
        $isDatabasePrincipal = Test-SqlDscIsDatabasePrincipal @testSqlDscIsDatabasePrincipalParameters

        if (-not $isDatabasePrincipal)
        {
            $missingPrincipalMessage = $this.localizedData.NameIsMissing -f @(
                $this.Name,
                $this.DatabaseName,
                $this.InstanceName
            )

            New-InvalidOperationException -Message $missingPrincipalMessage
        }

        # This holds each state and their permissions to be revoked.
        [DatabasePermission[]] $permissionsToRevoke = @()
        [DatabasePermission[]] $permissionsToGrantOrDeny = @()

        if ($properties.ContainsKey('Permission'))
        {
            $keyProperty = $this | Get-DscProperty -Type 'Key'

            $currentState = $this.GetCurrentState($keyProperty)

            <#
                Evaluate if there are any permissions that should be revoked
                from the current state.
            #>
            # TODO: replace all $this.Permission* with $properties.Permission*
            foreach ($currentDesiredPermissionState in $this.Permission)
            {
                $currentPermissionsForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $currentDesiredPermissionState.State
                    }

                foreach ($permissionName in $currentPermissionsForState.Permission)
                {
                    if ($permissionName -notin $currentDesiredPermissionState.Permission)
                    {
                        # Look for an existing object in the array.
                        $updatePermissionToRevoke = $permissionsToRevoke |
                            Where-Object -FilterScript {
                                $_.State -eq $currentDesiredPermissionState.State
                            }

                        # Update the existing object in the array, or create a new object
                        if ($updatePermissionToRevoke)
                        {
                            $updatePermissionToRevoke.Permission += $permissionName
                        }
                        else
                        {
                            [DatabasePermission[]] $permissionsToRevoke += [DatabasePermission] @{
                                State = $currentPermissionsForState.State
                                Permission = $permissionName
                            }
                        }
                    }
                }
            }

            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [DatabasePermission[]] $permissionsToGrantOrDeny = $this.Permission
        }

        if ($properties.ContainsKey('PermissionToExclude'))
        {
            <#
                At least one permission were present in the current state. Revoke
                all permission assigned to the property PermissionToExclude
                regardless if they were already revoked or not.
            #>
            [DatabasePermission[]] $permissionsToRevoke = $this.PermissionToExclude
        }

        if ($properties.ContainsKey('PermissionToInclude'))
        {
            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [DatabasePermission[]] $permissionsToGrantOrDeny = $this.PermissionToInclude
        }

        # Revoke all the permissions set in $permissionsToRevoke
        if ($permissionsToRevoke)
        {
            foreach ($currentStateToRevoke in $permissionsToRevoke)
            {
                $revokePermissionSet = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.DatabasePermissionSet'

                foreach ($revokePermissionName in $currentStateToRevoke.Permission)
                {
                    $revokePermissionSet.$revokePermissionName = $true
                }

                $setSqlDscDatabasePermissionParameters = @{
                    ServerObject = $serverObject
                    DatabaseName = $this.DatabaseName
                    Name         = $this.Name
                    Permission   = $revokePermissionSet
                    State        = 'Revoke'
                }

                if ($currentStateToRevoke.State -eq 'GrantWithGrant')
                {
                    $setSqlDscDatabasePermissionParameters.WithGrant = $true
                }

                try
                {
                    Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters
                }
                catch
                {
                    $errorMessage = $this.localizedData.FailedToRevokePermissionFromCurrentState -f @(
                        $this.Name,
                        $this.DatabaseName
                    )

                    <#
                        TODO: Update the CONTRIBUTING.md section "Class-based DSC resource"
                                that now says that 'throw' should be used.. we should use
                                helper function instead. Or something similar to commands
                                where the ID number is part of code? But might be a problem
                                tracing a specific verbose string down?
                    #>
                    New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                }
            }
        }

        if ($permissionsToGrantOrDeny)
        {
            foreach ($currentDesiredPermissionState in $permissionsToGrantOrDeny)
            {
                # If there is not an empty array, change permissions.
                if (-not [System.String]::IsNullOrEmpty($currentDesiredPermissionState.Permission))
                {
                    $permissionSet = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.DatabasePermissionSet'

                    foreach ($permissionName in $currentDesiredPermissionState.Permission)
                    {
                        $permissionSet.$permissionName = $true
                    }

                    $setSqlDscDatabasePermissionParameters = @{
                        ServerObject = $serverObject
                        DatabaseName = $this.DatabaseName
                        Name         = $this.Name
                        Permission   = $permissionSet
                    }

                    try
                    {
                        switch ($currentDesiredPermissionState.State)
                        {
                            'GrantWithGrant'
                            {
                                Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters -State 'Grant' -WithGrant
                            }

                            default
                            {
                                Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters -State $currentDesiredPermissionState.State
                            }
                        }
                    }
                    catch
                    {
                        $errorMessage = $this.localizedData.FailedToSetPermission -f @(
                            $this.Name,
                            $this.DatabaseName
                        )

                        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                    }
                }
            }
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        # TODO: Add the evaluation so that one permission can't be added two different states ('Grant' and 'Deny') in the same resource instance.

        # TODO: PermissionToInclude and PermissionToExclude must not contain an empty collection for property Permission

        # PermissionToInclude and PermissionToExclude should be mutually exclusive from Permission
        $assertBoundParameterParameters = @{
            BoundParameterList = $properties
            MutuallyExclusiveList1 = @(
                'Permission'
            )
            MutuallyExclusiveList2 = @(
                'PermissionToInclude'
                'PermissionToExclude'
            )
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Get all assigned permission properties.
        $assignedPermissionProperty = $properties.Keys.Where({
            $_ -in @(
                'Permission',
                'PermissionToInclude',
                'PermissionToExclude'
            )
        })

        # Must include either of the permission properties.
        if ([System.String]::IsNullOrEmpty($assignedPermissionProperty))
        {
            # TODO: Should throw ArgumentException
            throw $this.localizedData.MustAssignOnePermissionProperty
        }

        # One State cannot exist several times in the same resource instance.
        foreach ($currentAssignedPermissionProperty in $assignedPermissionProperty)
        {
            $permissionStateGroupCount = @(
                $properties.$currentAssignedPermissionProperty |
                    Group-Object -NoElement -Property 'State' -CaseSensitive:$false |
                    Select-Object -ExpandProperty 'Count'
            )

            if ($permissionStateGroupCount -gt 1)
            {
                # TODO: Should throw ArgumentException
                throw $this.localizedData.DuplicatePermissionState
            }
        }

        if ($assignedPermissionProperty -contains 'Permission')
        {
            # Each State must exist once.
            $missingPermissionState = (
                $properties.Permission.State -notcontains 'Grant' -or
                $properties.Permission.State -notcontains 'GrantWithGrant' -or
                $properties.Permission.State -notcontains 'Deny'
            )

            if ($missingPermissionState)
            {
                # TODO: Should throw ArgumentException
                throw $this.localizedData.MissingPermissionState
            }
        }
    }
}
