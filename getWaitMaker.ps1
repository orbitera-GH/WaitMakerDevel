$ip=""
$exit=0
$log = "C:\Windows\Panther\getWaitMaker.log"
$vmName=($env:computername).ToLower()
$RG="orbiteratestdrive"+$vmName.Replace('gate','')
$SupervisorIP = Get-Content -Path "c:\Windows\OEM\SuperVisorIP.txt"
function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}

echo "$(czas)  Disable ServerManager" >> $log
$serverManagerProcess = Get-Process | where {$_.name -like "ServerManager"}
If ($($serverManagerProcess.Id)) {
	echo "$(czas)  ServerManager process is running, try to stopping." >> $log
	Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Server Manager\' -TaskName 'ServerManager'
	Stop-Process -Id $serverManagerProcess.Id -Force
	$serverManagerProcess = Get-Process | where {$_.name -like "ServerManager"}
	If ($($serverManagerProcess.Id)) {
		echo "$(czas)  ERROR ServerManager process still running." >> $log
	}else{
		echo "$(czas)  Success, ServerManager process stoped." >> $log
	}
}else{
	Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Server Manager\' -TaskName 'ServerManager'
	echo "$(czas) not found ServerManager process." >> $log
}
echo "$(czas)  Disable ServerManager END" >> $log

while ($ip.Length -lt 7) {
	echo "$(czas)  Uploading resource group name...$RG " >> $log
	   #(new-object net.webclient).DownloadString('http://168.62.183.34/azurecheck.php?group='+$RG)
	$ip=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/azurecheck.php?group='+$RG)
	$z=$ip.Length
    #date >> $log
	echo "$(czas)  (WaitMaker) Length: $z ip: $ip" >> $log
	start-sleep -s 5
}
#date >> $log
echo "$(czas)  (WaitMaker) Script End" >> $log

#$ip_port=$ip +":3395"
$ip_port=$ip +":3389"
echo "$(czas)  change NetAppStorage.RDP" >> C:\Windows\Panther\get.log
$sqlName=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/azurecheck.php?group='+$RG+'&getsqlname=true')
while ($exit -eq 0) {
    if (Test-Path -Path "C:\Users\Public\Desktop") {
		if (!(Test-Path -Path "C:\Windows\OEM\NetAppStorage.RDP")) {
			write "$ip  $sqlName" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Append -Encoding ascii
			#(Get-Content C:\Users\Public\Desktop\NetAppStorage.RDP).Replace($ip,"$ip_port") | Set-Content C:\Users\Public\Desktop\NetAppStorage.RDP
				(Get-Content C:\Users\Public\Desktop\NetAppStorage.RDP).Replace($ip,"$sqlName") | Set-Content C:\Users\Public\Desktop\NetAppStorage.RDP
			#date >> C:\Windows\Panther\get.log
			echo "$(czas)  NetAppStorage.RDP changed" >> C:\Windows\Panther\get.log
				echo "$(czas)  Rename shortcut" >> C:\Windows\Panther\get.log
				Rename-Item C:\Users\Public\Desktop\NetAppStorage.RDP "C:\Users\Public\Desktop\SQL Server.RDP"
			$exit=1
		}else{
			echo "$(czas)  wait for move shortcut by get.ps1" >> $log
			start-sleep -s 2 
		}
    }else{
        #date >> C:\Windows\Panther\get.log
        echo "$(czas)  Waiting for NetAppStorage.RDP..." >> C:\Windows\Panther\get.log
	    start-sleep -s 5
    }
}