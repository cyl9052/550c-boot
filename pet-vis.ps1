param([int]$Cmd = 0)   # 0 = 隐藏, 5 = 显示

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PetVis {
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
}
"@

$procs = Get-Process -Name '大肥鱼桌宠' -ErrorAction SilentlyContinue |
  Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }

if (-not $procs) { Write-Output 'nopet'; exit 0 }

foreach ($p in $procs) {
  [PetVis]::ShowWindow($p.MainWindowHandle, $Cmd) | Out-Null
  if ($Cmd -eq 5) {
    # 重新置顶，避免被其他窗口压住
    [PetVis]::SetWindowPos($p.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0001 -bor 0x0002) | Out-Null
  }
}
Write-Output ('ok ' + $procs.Count)
