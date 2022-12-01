$script:dbatoolsLibraryModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/dbatools.library'
Import-Module -Name $script:dbatoolsLibraryModulePath

$sqlManagementObjectsPath = Join-Path $PSScriptRoot -ChildPath 'Modules\dbatools.library\*\lib'

if (Test-Path -Path $sqlManagementObjectsPath)
{
    $smoAssemblies = @(
        #'Microsoft.SqlServer.Management.PSSnapins.dll'
        'Microsoft.SqlServer.ConnectionInfo.dll'
        'Microsoft.SqlServer.Management.Sdk.Sfc.dll'
        'Microsoft.SqlServer.Smo.dll'
        'Microsoft.SqlServer.SqlEnum.dll'
        #'Microsoft.SqlServer.Management.AlwaysEncrypted.Types.dll'
        'Microsoft.SqlServer.SmoExtended.dll'
        #'Microsoft.PolyKit.dll'
        #'Microsoft.SqlServer.DC.Engine.dll'
        'Microsoft.SqlServer.SqlWmiManagement.dll'
        'Microsoft.SqlServer.Dmf.dll'
        #'DataSec.PAL.Interfaces.dll'
        #'Microsoft.SqlServer.VA.Model.dll'
        #'Microsoft.SqlServer.Management.PSProvider.dll'
        #'Microsoft.AnalysisServices.PowerShell.Provider.dll'
        #'Microsoft.AnalysisServices.Core.dll'
        #'Microsoft.AnalysisServices.dll'
        'Microsoft.SqlServer.WmiEnum.dll'
        #'Microsoft.AnalysisServices.PowerShell.Cmdlets.dll'
        #'Microsoft.AnalysisServices.Tabular.dll'
        #'Microsoft.SqlServer.Assessment.Cmdlets.dll'
        #'Microsoft.SqlServer.Assessment.dll' # Requires Newtonsoft.Json
        'Microsoft.SqlServer.Dmf.Common.dll'
        #'Microsoft.SqlServer.ConnectionInfoExtended.dll'
        'Microsoft.SqlServer.Management.RegisteredServers.dll'
        'Microsoft.SqlServer.RegSvrEnum.dll'
        'Microsoft.SqlServer.ServiceBrokerEnum.dll'
        'Microsoft.SqlServer.Management.Collector.dll'
        'Microsoft.SqlServer.Management.CollectorEnum.dll'
        #'Microsoft.SqlServer.Management.Utility.dll'
        #'Microsoft.SqlServer.Management.UtilityEnum.dll'
        #'Microsoft.SqlServer.Management.HadrDMF.dll'
    )

    foreach ($assemblyName in $smoAssemblies)
    {
        Write-Debug -Message 'Loading assembly ''{0}''.' -f $assemblyName

        Add-Type -Path (Join-Path $sqlManagementObjectsPath -ChildPath $assemblyName)
    }
}
else
{
    throw 'Path to SMO is invalid.'    <# Action when all if and elseif conditions are false #>
}

$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/DscResource.Common'
Import-Module -Name $script:dscResourceCommonModulePath

# TODO: The goal would be to remove this, when no classes and public or private functions need it.
$script:sqlServerDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/SqlServerDsc.Common'
Import-Module -Name $script:sqlServerDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
