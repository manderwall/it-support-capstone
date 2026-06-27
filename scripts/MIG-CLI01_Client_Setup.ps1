# ############################################################
# ##  RUN INSIDE THE CAPSTONE VM ONLY  —  DO NOT RUN ON YOUR HOST  ##
# ############################################################
#
#  MIG-CLI01  Client Setup  (with automatic evidence capture)
#  1024.3 AI-Enabled IT Support Capstone  -  Phase 1 Environment Build
#  Author: Amanda Kondrat'yev
#
#  Evidence: logs to C:\CapstoneEvidence\transcript_MIG-CLI01.txt and saves PNGs.
#  Manual (host-side): VirtualBox settings + snapshots.
#  Requires Windows 11 Pro/Enterprise (Home cannot join a domain).
#  Run as Administrator, one block at a time; re-paste the preamble each block.
#  The script auto-detects the active network adapter (no need to hardcode "Ethernet").
# ############################################################


# ===== EVIDENCE PREAMBLE — paste at the start of EVERY block =====
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\CapstoneEvidence\transcript_MIG-CLI01.txt" -Append
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


# ---------- BLOCK 1 : static IP + DNS + rename (client reboots) ----------
if ((Read-Host "Type YES only if you are INSIDE the MIG-CLI01 VM") -ne "YES") { Write-Warning "Aborted."; Stop-Transcript; return }
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# auto-detect the active network adapter (instead of assuming "Ethernet")
$IfAlias = (Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).Name
if (-not $IfAlias) { $IfAlias = (Get-NetAdapter | Select-Object -First 1).Name }
Write-Host "Using network adapter: $IfAlias" -ForegroundColor Cyan

New-NetIPAddress -InterfaceAlias $IfAlias -IPAddress 192.168.50.20 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $IfAlias -ServerAddresses 192.168.50.10
ipconfig /all
Save-Screenshot "p1_client_ipconfig"
Stop-Transcript
Rename-Computer -NewName "MIG-CLI01" -Restart


# ---------- BLOCK 2 : join the domain (client reboots) ----------
# (re-paste the EVIDENCE PREAMBLE first; sign in as MIGRATION\MigrationAdmin when prompted)
Add-Computer -DomainName "migration.local" -Credential (Get-Credential "MIGRATION\MigrationAdmin") -Restart


# ---------- BLOCK 3 : validate (sign in as MIGRATION\MigrationUser) ----------
# (re-paste the EVIDENCE PREAMBLE first)
ping MIG-SRV01
nslookup migration.local
Test-Path "\\MIG-SRV01\SharedData"
Save-Screenshot "p1_client_validation"
Start-Process "\\MIG-SRV01\SharedData"
Start-Sleep -Seconds 3
Save-Screenshot "p1_client_share_open"
Stop-Transcript

# ############################################################
#  Script author: Amanda Kondrat'yev  -  1024.3 AI-Enabled IT Support Capstone
# ############################################################
