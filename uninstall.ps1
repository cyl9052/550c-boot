$ErrorActionPreference = 'SilentlyContinue'
$dst = Join-Path $env:LOCALAPPDATA '550C'
$startup = [Environment]::GetFolderPath('Startup')
Remove-Item (Join-Path $startup '550C-Boot.vbs') -Force
Remove-Item $dst -Recurse -Force
Write-Host '已卸载 550C 开机动画' -ForegroundColor Green
Start-Sleep -Seconds 2
