PS > import-module dbatools
PS > [System.AppDomain]::CurrentDomain.GetAssemblies() | ? Location -like *SqlServer* | ft Location

Location
--------
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Smo.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.ConnectionInfo.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Management.Sdk.Sfc.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SqlEnum.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Dmf.Common.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SmoExtended.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.BatchParser.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.BatchParserClient.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.XE.Core.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Management.XEvent.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Management.XEventDbScoped.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SqlWmiManagement.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Management.RegisteredServers.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Management.Collector.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SqlClrProvider.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SqlTDiagm.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.SString.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Dac.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Dmf.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.Types.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.XEvent.Linq.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\Microsoft.SqlServer.XEvent.XELite.dll
C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.143\bin\smo\SqlServer.XEvent.dll

PS > $a = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer -ArgumentList localhost
PS > $a


ConnectionSettings : Microsoft.SqlServer.Management.Smo.Wmi.WmiConnectionInfo
Services           : {MSSQL$SQL2022, SQLAgent$SQL2022, SQLBrowser}
ClientProtocols    : {}
ServerInstances    : {SQL2022}
ServerAliases      : {}
Urn                : ManagedComputer[@Name='localhost']
Name               : localhost
Properties         : {}
UserData           :
State              : Existing

# dbatools.library and dbatools.core.library
https://github.com/dataplat/dbatools/blob/7cfc456124460958e798417e09d4ef8372515dcc/dbatools.psm1#L45-L51
https://github.com/dataplat/dbatools/blob/7cfc456124460958e798417e09d4ef8372515dcc/dbatools.psd1#L50-L60
https://github.com/dataplat/dbatools/blob/7cfc456124460958e798417e09d4ef8372515dcc/bin/library.ps1
https://github.com/dataplat/dbatools/blob/7cfc456124460958e798417e09d4ef8372515dcc/internal/scripts/libraryimport.ps1

https://www.powershellgallery.com/packages/dbatools.core.library/2022.11.8
https://www.powershellgallery.com/packages/dbatools.library/2022.11.8-preview


SqlServer:

PS C:\Windows\system32> [System.AppDomain]::CurrentDomain.GetAssemblies() | ? Location -like *SqlServer* | ft GlobalAssemblyCache, ImageRuntimeVersion, Location

GlobalAssemblyCache ImageRuntimeVersion Location
------------------- ------------------- --------
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.PSSnapins.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.ConnectionInfo.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.Sdk.Sfc.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Smo.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.SqlEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.AlwaysEncrypted.Types.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.SmoExtended.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.PolyKit.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.DC.Engine.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.SqlWmiManagement.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Dmf.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\DataSec.PAL.Interfaces.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.VA.Model.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.PSProvider.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.AnalysisServices.PowerShell.Provider.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.AnalysisServices.Core.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.AnalysisServices.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.WmiEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.AnalysisServices.PowerShell.Cmdlets.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.AnalysisServices.Tabular.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Assessment.Cmdlets.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Assessment.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Dmf.Common.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.ConnectionInfoExtended.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.RegisteredServers.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.RegSvrEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.ServiceBrokerEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.Collector.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.CollectorEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.Utility.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.UtilityEnum.dll
              False v4.0.30319          C:\Program Files\WindowsPowerShell\Modules\sqlserver\21.1.18256\Microsoft.SqlServer.Management.HadrDMF.dll
