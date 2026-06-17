# ############################################################
# ##  RUN INSIDE THE CAPSTONE VM ONLY  —  DO NOT RUN ON YOUR HOST  ##
# ############################################################
#
#  MIG-SRV01  Server Setup  (with automatic evidence capture)
#  1024.3 AI-Enabled IT Support Capstone  -  Amanda Kondrat'yev
#
#  WHAT THE EVIDENCE CAPTURE DOES:
#   - Logs every command + output to  C:\CapstoneEvidence\transcript_MIG-SRV01.txt
#   - Saves a full-screen PNG after key steps to  C:\CapstoneEvidence\
#  STILL MANUAL (script can't see the host): VirtualBox VM settings,
#  snapshot list, and the internal-network screen. Capture those yourself.
#
#  HOW TO RUN:
#   - Windows PowerShell as Administrator, INSIDE the VM.
#   - Run ONE BLOCK at a time; the server reboots between blocks.
#   - Paste the evidence preamble at the top of EACH block (a reboot
#     starts a fresh session, so the helper must be re-defined).
#   - AI-drafted: read each line and verify the results yourself.
#   - Confirm the adapter name first:   Get-NetAdapter   (assumed "Ethernet")
# ############################################################


# ===== EVIDENCE PREAMBLE — paste at the start of EVERY block =====
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\CapstoneEvidence\transcript_MIG-SRV01.txt" -Append
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
function Save-Screenshot($name){
  $s=[System.Windows.Forms.SystemInformation]::VirtualScreen
  $bmp=New-Object Drawing.Bitmap $s.Width,$s.Height
  $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($s.Location,[Drawing.Point]::Empty,$s.Size)
  $p="C:\CapstoneEvidence\$(Get-Date -f yyyyMMdd_HHmmss)_$name.png"
  $bmp.Save($p,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  Write-Host "  [screenshot saved] $p" -ForegroundColor Cyan
}
# =================================================================


# ---------- BLOCK 1 : static IP + DNS + rename (server reboots) ----------
if ((Read-Host "Type YES only if you are INSIDE the MIG-SRV01 VM") -ne "YES") { Write-Warning "Aborted."; Stop-Transcript; return }
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.50.10 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
ipconfig /all
Save-Screenshot "p1_server_ipconfig"
Stop-Transcript
Rename-Computer -NewName "MIG-SRV01" -Restart


# ---------- BLOCK 2 : install AD DS + promote to DC (server reboots) ----------
# (re-paste the EVIDENCE PREAMBLE first)
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Save-Screenshot "p1_adds_feature_installed"
Import-Module ADDSDeployment
Install-ADDSForest -DomainName "migration.local" -DomainNetbiosName "MIGRATION" -InstallDns `
  -SafeModeAdministratorPassword (Read-Host "Enter a DSRM recovery password" -AsSecureString) -Force
# (server reboots automatically after promotion)


# ---------- BLOCK 3 : users, groups, file share ----------
# (re-paste the EVIDENCE PREAMBLE first; sign in as MIGRATION\Administrator)
# NOTE: passwords must meet AD complexity (8+ chars, upper+lower+number+symbol).
New-ADUser -Name "MigrationAdmin" -SamAccountName "MigrationAdmin" -AccountPassword (Read-Host "Set MigrationAdmin password" -AsSecureString) -Enabled $true
Add-ADGroupMember "Domain Admins" "MigrationAdmin"
New-ADUser -Name "MigrationUser" -SamAccountName "MigrationUser" -AccountPassword (Read-Host "Set MigrationUser password" -AsSecureString) -Enabled $true
New-ADGroup -Name "IT-Admins"      -GroupScope Global -GroupCategory Security
New-ADGroup -Name "Domain-Users"   -GroupScope Global -GroupCategory Security
New-ADGroup -Name "FileShareUsers" -GroupScope Global -GroupCategory Security
Add-ADGroupMember "IT-Admins"      "MigrationAdmin"
Add-ADGroupMember "Domain-Users"   "MigrationUser"
Add-ADGroupMember "FileShareUsers" "MigrationUser"

New-Item -Path "C:\SharedData" -ItemType Directory -Force
New-SmbShare -Name "SharedData" -Path "C:\SharedData" -ChangeAccess "MIGRATION\FileShareUsers"
$acl  = Get-Acl "C:\SharedData"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("MIGRATION\FileShareUsers","Modify","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($rule); Set-Acl "C:\SharedData" $acl

# print the proof into the transcript, then screenshot it
Get-ADUser -Filter * | Select-Object Name,SamAccountName | Format-Table -Auto
Get-ADGroup -Filter * | Where-Object {$_.Name -in "IT-Admins","Domain-Users","FileShareUsers"} | Select-Object Name | Format-Table -Auto
Get-ADGroupMember "FileShareUsers" | Select-Object Name | Format-Table -Auto
Get-SmbShareAccess "SharedData" | Format-Table -Auto
Save-Screenshot "p1_users_groups_share_proof"
Write-Host "Server setup complete." -ForegroundColor Green
Stop-Transcript
