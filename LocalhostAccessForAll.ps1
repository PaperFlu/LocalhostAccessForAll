### Force Run as Administrator.
$currentWi = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentWp = [Security.Principal.WindowsPrincipal]$currentWi

if( -not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  $boundPara = ($MyInvocation.BoundParameters.Keys | foreach{
    '-{0} {1}' -f  $_ ,$MyInvocation.BoundParameters[$_]} ) -join ' '
  $currentFile = $MyInvocation.MyCommand.Path
  $fullPara = $boundPara + ' ' + $args -join ' '

  Start-Process "$psHome\powershell.exe"   -ArgumentList "$currentFile $fullPara"   -verb runas
  return
}

### Actural Start.

# Get package family names.
[System.Collections.Generic.HashSet[string]]$package_names = get-appxpackage | findstr /B /C:"PackageFamilyName : "

# Save all package family names.
# Set-Content -Path "package_names.txt" -Value ($package_names -join "`r`n")

# Main trick.
foreach ($n in $package_names)
{
  Invoke-Expression "CheckNetIsolation LoopbackExempt /a /n='$($n.Substring(20))'"
}
