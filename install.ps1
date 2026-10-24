<#
  550C 开机动画 · 一键安装
#>
$ErrorActionPreference = 'Stop'
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$dst = Join-Path $env:LOCALAPPDATA '550C'
New-Item -ItemType Directory -Path $dst -Force | Out-Null

Write-Host ''
Write-Host '  ================================' -ForegroundColor Red
Write-Host '   550C 开机动画 · 安装程序' -ForegroundColor White
Write-Host '  ================================' -ForegroundColor Red
Write-Host ''

$pw = Read-Host '  设置 6 位数字口令（必须填 6 位数字，别用生日/手机号）'
while (-not $pw -or $pw -notmatch '^\d{6}$') { Write-Host '  必须是 6 位数字：' -NoNewline -ForegroundColor Yellow; $pw = Read-Host }
if ($pw -notmatch '^\d{6}$') { Write-Host '  口令必须是 6 位数字，请重新输入' -ForegroundColor Yellow; $pw = '000000' }

foreach ($f in '550c.html','play-boot.cjs','pet-vis.ps1') {
  Copy-Item (Join-Path $src $f) (Join-Path $dst $f) -Force
}

$html = Get-Content (Join-Path $dst '550c.html') -Raw -Encoding UTF8
$html = $html -replace 'const PASS = "\d+"', ('const PASS = "' + $pw + '"')
Set-Content (Join-Path $dst '550c.html') $html -Encoding UTF8

$vbs = @"
' 550C boot animation at logon
Set sh = CreateObject("WScript.Shell")
sh.Run """C:\Program Files\nodejs\node.exe"" ""$dst\play-boot.cjs"" 16000", 0, False
"@
$startup = [Environment]::GetFolderPath('Startup')
Set-Content (Join-Path $startup '550C-Boot.vbs') $vbs -Encoding ASCII

Write-Host ''
Write-Host '  安装完成！' -ForegroundColor Green
Write-Host "  安装位置: $dst"
Write-Host "  开机口令: $pw"
Write-Host "  开机动画: 下次登录时自动播放"
Write-Host ''
Write-Host '  想立刻看效果？按 Y 预览一次：' -ForegroundColor Cyan -NoNewline
$ans = Read-Host
if ($ans -match '^[Yy]') {
  Start-Process -FilePath 'node' -ArgumentList (Join-Path $dst 'play-boot.cjs'), '16000' -WindowStyle Hidden
}
