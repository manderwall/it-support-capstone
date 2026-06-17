# ############################################################
#  Evidence-Helpers.ps1   (run INSIDE the VM)
#  1024.3 AI-Enabled IT Support Capstone  -  Amanda Kondrat'yev
#
#  Dot-source this at the start of any session to turn on capture:
#      . .\Evidence-Helpers.ps1
#      Start-Evidence "MIG-CLI01"      # names the transcript
#      Save-Screenshot "my_step"       # saves a PNG anytime
#  Everything lands in  C:\CapstoneEvidence\
# ############################################################
New-Item -Path "C:\CapstoneEvidence" -ItemType Directory -Force | Out-Null
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

function Start-Evidence([string]$tag="session"){
  Start-Transcript -Path "C:\CapstoneEvidence\transcript_$tag.txt" -Append
}
function Save-Screenshot([string]$name){
  $s=[System.Windows.Forms.SystemInformation]::VirtualScreen
  $bmp=New-Object Drawing.Bitmap $s.Width,$s.Height
  $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($s.Location,[Drawing.Point]::Empty,$s.Size)
  $p="C:\CapstoneEvidence\$(Get-Date -f yyyyMMdd_HHmmss)_$name.png"
  $bmp.Save($p,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  Write-Host "  [screenshot saved] $p" -ForegroundColor Cyan
}
Write-Host "Evidence helpers loaded. Use Start-Evidence and Save-Screenshot." -ForegroundColor Green
