# ############################################################
# ##  RUN INSIDE THE CAPSTONE VMs  —  READ-ONLY DIAGNOSTICS  ##
# ############################################################
#
#  Phase3-Investigation.ps1   (with automatic evidence capture)
#  1024.3 AI-Enabled IT Support Capstone  -  Amanda Kondrat'yev
#
#  Phase 3 is INVESTIGATE-ONLY. These commands gather evidence and
#  CHANGE NOTHING. Run PART A on the client, PART B on the server.
#  Everything is logged to C:\CapstoneEvidence and screenshotted.
#  Read the output yourself and decide the root cause - the script
#  does not diagnose for you.
# ############################################################


# ========================= PART A : RUN ON MIG-CLI01 (client) =========================
# --- evidence preamble ---
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\CapstoneEvidence\transcript_Phase3_CLI.txt" -Append
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
function Save-Screenshot($name){ $s=[System.Windows.Forms.SystemInformation]::VirtualScreen; $bmp=New-Object Drawing.Bitmap $s.Width,$s.Height; $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($s.Location,[Drawing.Point]::Empty,$s.Size); $p="C:\CapstoneEvidence\$(Get-Date -f yyyyMMdd_HHmmss)_$name.png"; $bmp.Save($p,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); Write-Host "  [screenshot] $p" -ForegroundColor Cyan }

Write-Host "`n===== INC-001 / INC-006  shared file access =====" -ForegroundColor Yellow
Get-ChildItem "\\MIG-SRV01\SharedData" -ErrorAction Continue
net use

Write-Host "`n===== INC-002 / INC-003  logon speed & Group Policy =====" -ForegroundColor Yellow
gpresult /r
gpresult /h "C:\CapstoneEvidence\gpresult_client.html" /f
Get-WinEvent -LogName "Microsoft-Windows-GroupPolicy/Operational" -MaxEvents 25 -ErrorAction SilentlyContinue |
  Select-Object TimeCreated,Id,LevelDisplayName,Message | Format-Table -Wrap

Write-Host "`n===== INC-004  printer =====" -ForegroundColor Yellow
Get-Printer -ErrorAction SilentlyContinue | Format-Table Name,DriverName,PortName -Auto
Get-Service Spooler | Format-Table Name,Status,StartType -Auto

Write-Host "`n===== INC-005  performance / services =====" -ForegroundColor Yellow
Get-Service | Where-Object {$_.Status -ne 'Running' -and $_.StartType -eq 'Automatic'} | Format-Table Name,Status,StartType -Auto
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name,CPU,WS | Format-Table -Auto

Write-Host "`n===== INC-006  DNS / secure channel / time =====" -ForegroundColor Yellow
ipconfig /all
Resolve-DnsName "migration.local" -ErrorAction SilentlyContinue
Resolve-DnsName "MIG-SRV01" -ErrorAction SilentlyContinue
Test-ComputerSecureChannel -Verbose
w32tm /query /status

Save-Screenshot "p3_client_diagnostics"
Write-Host "`nPART A complete. Review the output and the transcript." -ForegroundColor Green
Stop-Transcript


# ========================= PART B : RUN ON MIG-SRV01 (server) =========================
# (re-paste this preamble on the server)
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\CapstoneEvidence\transcript_Phase3_SRV.txt" -Append
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
function Save-Screenshot($name){ $s=[System.Windows.Forms.SystemInformation]::VirtualScreen; $bmp=New-Object Drawing.Bitmap $s.Width,$s.Height; $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($s.Location,[Drawing.Point]::Empty,$s.Size); $p="C:\CapstoneEvidence\$(Get-Date -f yyyyMMdd_HHmmss)_$name.png"; $bmp.Save($p,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); Write-Host "  [screenshot] $p" -ForegroundColor Cyan }

Write-Host "`n===== INC-001 / INC-006  share & NTFS permissions =====" -ForegroundColor Yellow
Get-SmbShareAccess "SharedData" | Format-Table -Auto
(Get-Acl "C:\SharedData").Access | Format-Table IdentityReference,FileSystemRights,AccessControlType -Auto
Get-ADGroupMember "FileShareUsers" -ErrorAction SilentlyContinue | Format-Table Name,objectClass -Auto

Write-Host "`n===== Core AD / DNS / time services =====" -ForegroundColor Yellow
Get-Service ADWS,DNS,Netlogon,NTDS,W32Time -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -Auto
w32tm /query /status

Write-Host "`n===== Group Policy plumbing (SYSVOL / NETLOGON / GPOs) =====" -ForegroundColor Yellow
Get-SmbShare | Where-Object {$_.Name -in "SYSVOL","NETLOGON"} | Format-Table Name,Path -Auto
Get-GPO -All -ErrorAction SilentlyContinue | Select-Object DisplayName,GpoStatus | Format-Table -Auto

Write-Host "`n===== Domain controller health =====" -ForegroundColor Yellow
dcdiag /q

Save-Screenshot "p3_server_diagnostics"
Write-Host "`nPART B complete. Review the output and the transcript." -ForegroundColor Green
Stop-Transcript
