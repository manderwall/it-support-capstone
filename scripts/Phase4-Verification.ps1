# ############################################################
# ##  RUN INSIDE THE CAPSTONE VMs  —  FIX VERIFICATION  ##
# ############################################################
#
#  Phase4-Verification.ps1   (with automatic evidence capture)
#  1024.3 AI-Enabled IT Support Capstone  -  Amanda Kondrat'yev
#
#  YOUR FIXES come from your Phase 3 evidence - decide and apply them
#  yourself (no blind/shotgun fixes). This script RE-TESTS each ticket
#  so you can capture proof. Run a ticket's block BEFORE your fix and
#  AGAIN after, to show the change. All output -> C:\CapstoneEvidence.
#  Most blocks run on the CLIENT; share/permission checks on the SERVER.
# ############################################################

# --- evidence preamble (re-paste each session / machine) ---
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\CapstoneEvidence\transcript_Phase4.txt" -Append
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
function Save-Screenshot($name){ $s=[System.Windows.Forms.SystemInformation]::VirtualScreen; $bmp=New-Object Drawing.Bitmap $s.Width,$s.Height; $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($s.Location,[Drawing.Point]::Empty,$s.Size); $p="C:\CapstoneEvidence\$(Get-Date -f yyyyMMdd_HHmmss)_$name.png"; $bmp.Save($p,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); Write-Host "  [screenshot] $p" -ForegroundColor Cyan }

# ===== INC-001 / INC-006  file access (client; perms on server) =====
Write-Host "`n[Verify INC-001/006] shared file access" -ForegroundColor Yellow
Get-ChildItem "\\MIG-SRV01\SharedData"            # CLIENT: should now list contents
# On SERVER instead: Get-SmbShareAccess "SharedData"; (Get-Acl "C:\SharedData").Access | ft -Auto
Save-Screenshot "p4_inc001_006_fileaccess"

# ===== INC-002 / INC-003  logon & Group Policy (client) =====
Write-Host "`n[Verify INC-002/003] Group Policy applies" -ForegroundColor Yellow
gpupdate /force
gpresult /r
Save-Screenshot "p4_inc002_003_grouppolicy"

# ===== INC-004  printer (client) =====
Write-Host "`n[Verify INC-004] printer present & spooler running" -ForegroundColor Yellow
Get-Service Spooler | Format-Table Name,Status,StartType -Auto
Get-Printer -ErrorAction SilentlyContinue | Format-Table Name,DriverName,PortName -Auto
Save-Screenshot "p4_inc004_printer"

# ===== INC-005  performance / services (client) =====
Write-Host "`n[Verify INC-005] auto services running" -ForegroundColor Yellow
Get-Service | Where-Object {$_.Status -ne 'Running' -and $_.StartType -eq 'Automatic'} | Format-Table Name,Status -Auto
Save-Screenshot "p4_inc005_services"

# ===== INC-006  DNS / secure channel / time (client) =====
Write-Host "`n[Verify INC-006] name resolution & secure channel" -ForegroundColor Yellow
Resolve-DnsName "migration.local" -ErrorAction SilentlyContinue
Test-ComputerSecureChannel -Verbose
w32tm /query /status
Save-Screenshot "p4_inc006_dns_securechannel"

Write-Host "`nVerification pass complete." -ForegroundColor Green
Stop-Transcript
