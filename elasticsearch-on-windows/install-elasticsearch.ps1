param
(
      [string]$IPaddresses = $null,
      [string]$clusterName = $null
)

try {
	#download java from a location you choose.
	$jdkSource = "https://jdharm.blob.core.windows.net/powershell/jdk-8u40-windows-x64.exe"
	$jdkDestination = "D:\jdk-8u40-windows-x64.exe"

	Invoke-WebRequest $jdkSource -OutFile $jdkDestination

	#install java
	Start-Process -FilePath $jdkDestination -ArgumentList "/s" -PassThru -Wait

	# download elasticsearch
	$source = "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.0.zip"
	$destination = "D:\elasticsearch-1.5.0.zip"
 
	Invoke-WebRequest $source -OutFile $destination

	#unzip files
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($destination)

	foreach($item in $zip.items())
	{
		$shell.Namespace("C:\").copyhere($item)
	}

	$jdkPath = 'C:\Program Files\Java\jdk1.8.0_40' 
	$elasticSearchPath = 'C:\elasticsearch-1.5.0'

	$elasticSearchBinPath = join-path $elasticSearchPath '\bin'
	$configPath = join-path $elasticSearchPath  '\config\elasticsearch.yml'

	$esAreadyInstalled = $FALSE		
	$configOK = $true
		
	# Validate the configuration
	write-host "Validating config" -foregroundcolor green

	if (-not (test-path $elasticSearchBinPath))
	{
		write-host "ElasticSearch bin path doesn't exist: $elasticSearchBinPath"  -foregroundcolor red
		return;	
	}

	if (-not (test-path $jdkPath))
	{
		write-host "Java JDK path doesn't exist: $jdkPath"  -foregroundcolor red
		return;
	}

	
	# Setting JAVA_HOME	
	write-host "setting JAVA_HOME system variable" -foregroundcolor green

	if ([environment]::GetEnvironmentVariable("JAVA_HOME","machine") -eq $null)
	{
		[environment]::setenvironmentvariable("JAVA_HOME",$jdkpath,"machine")
		$env:JAVA_HOME = $jdkpath
	}

	write-host "JAVA_HOME system variable set to: " $jdkpath -foregroundcolor gray

	# Set cluster name
	Write-Host "Setting cluster name" -foregroundcolor green 
		
	if($clusterName -eq $null)
	{
		$clusterName = "elasticsearch"
	}

	(Get-Content $configPath) | ForEach-Object { $_ -replace "#?\s?cluster.name: .+" , "cluster.name: $clusterName" } | Set-Content $configPath
	Write-Host "Cluster name is: $clusterName"   -foregroundcolor gray	

	# Set discovery
	Write-Host "Changing discovery settings" -foregroundcolor green 
		
	(Get-Content $configPath) | ForEach-Object { $_ -replace "#?\s?discovery.zen.ping.multicast.enabled: false+" , "discovery.zen.ping.multicast.enabled: false" } | Set-Content $configPath
	Write-Host "Enabled unicast"   -foregroundcolor gray

	(Get-Content $configPath) | ForEach-Object { $_ -replace '#?\s?discovery.zen.ping.unicast.hosts: .+' , "discovery.zen.ping.unicast.hosts: [$IPaddresses]" } | Set-Content $configPath
	Write-Host "added ip addresses of nodes"   -foregroundcolor gray			 

	#Install ElasticSearch as a service
	Write-Host "Install ElasticSearch as a service" -foregroundcolor green 

	cd $elasticSearchBinPath 

	if (-not (Get-Service "elasticsearch-service-x64" -ErrorAction SilentlyContinue) )
	{
		.\service.bat install
		Write-Host "ElasticSearch installed." -foregroundcolor gray
	}
	else
	{
		Write-Host "ElasticSearch have been already installed." -foregroundcolor gray
		$esAreadyInstalled = $TRUE
	}

	# Install HEAD plugin	
	Write-Host "Install HEAD plugin" -foregroundcolor green 

	cd $elasticSearchBinPath 

	.\plugin.bat -install mobz/elasticsearch-head

	Write-Host "HEAD plugin installed." -foregroundcolor gray
		 
	# Start ElasticSearch service	
	Write-Host "Start ElasticSearch service" -foregroundcolor green

	Start-Service 'elasticsearch-service-x64'

	Write-Host "ElasticSearch service status: " (service "elasticsearch-service-x64").Status   -foregroundcolor gray
		
	Write-Host "Set service startup type to automatic" -foregroundcolor green 

	set-service 'elasticsearch-service-x64' -startuptype automatic

	# Enable ports through firewall 
	New-NetFirewallRule -DisplayName "Allow Port 9200 in" -Direction Inbound -LocalPort 9200 -Protocol TCP -Action Allow
	New-NetFirewallRule -DisplayName "Allow Port 9200 out" -Direction Outbound -LocalPort 9200 -Protocol TCP -Action Allow
	New-NetFirewallRule -DisplayName "Allow Port 9300 in" -Direction Inbound -LocalPort 9300 -Protocol TCP -Action Allow
	New-NetFirewallRule -DisplayName "Allow Port 9300 out" -Direction Outbound -LocalPort 9300 -Protocol TCP -Action Allow

	if(-not $esAreadyInstalled ){
		Write-Host "Now sleep 20s for ElasticSearch to start" -foregroundcolor yellow
		Start-Sleep -s 20
	}
	 
	# Confirm that it is installed and running. 
	Write-Host "Checking install... " -foregroundcolor green 
		
	$esRequest = [System.Net.WebRequest]::Create("http://localhost:9200")
	$esRequest.Method = "GET"
	$esResponse = $esRequest.GetResponse()
	$reader = new-object System.IO.StreamReader($esResponse.GetResponseStream())
	Write-Host "ElasticSearch service response status: " $esResponse.StatusCode   -foregroundcolor gray
	Write-Host "ElasticSearch service response full text: " $reader.ReadToEnd()   -foregroundcolor gray	
	
	Write-Host "ElasticSearch endpoint: http://localhost:9200" -foregroundcolor green 
	write-host
	write-host
	Write-Host "Completed with success" -foregroundcolor green 

}
finally{
	Write-Host "End"
}