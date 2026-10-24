// Play the 550C boot sequence fullscreen, then close it.
const { spawn, execSync } = require("node:child_process");
const fs = require("node:fs");

const EDGE = [
  "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
].find((p) => fs.existsSync(p));

if (!EDGE) { console.error("没找到 Edge"); process.exit(1); }

const PROFILE = "F:\\Sentinel\\boot\\profile";

// 开机时把桌宠藏起来，别盖住 550C
function petVis(cmd) {
  try {
    execSync('powershell -NoProfile -ExecutionPolicy Bypass -File "F:\\Sentinel\\boot\\pet-vis.ps1" ' + cmd,
      { stdio: "ignore", windowsHide: true, timeout: 15000 });
  } catch (e) {}
}
const DURATION = Number(process.argv[2] || 12000);

petVis(0);
setTimeout(() => petVis(0), 2500);

const child = spawn(EDGE, [
  "--kiosk",
  "file:///F:/Sentinel/boot/550c.html",
  `--user-data-dir=${PROFILE}`,
  "--no-first-run",
  "--no-default-browser-check",
  "--autoplay-policy=no-user-gesture-required",
  "--disable-features=Translate",
  "--start-fullscreen",
  "--disable-sync",
  "--no-service-autorun",
  "--disable-extensions",
  "--disable-features=msEdgeSyncPromo,msImplicitSignin,EdgeSyncPromo,Translate",
], { windowsHide: true, stdio: "ignore", detached: true });

fs.writeFileSync("F:\\Sentinel\\boot\\boot.pid", String(child.pid));
console.log("550C 启动动画播放中 pid=" + child.pid);

setTimeout(() => {
  try {
    execSync(
      `powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \\"Name='msedge.exe'\\" | Where-Object { $_.CommandLine -like '*boot\\\\profile*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"`,
      { stdio: "ignore", windowsHide: true }
    );
  } catch (e) {}
  try { fs.unlinkSync("F:\\Sentinel\\boot\\boot.pid"); } catch {}
  petVis(5);
  console.log("550C 动画结束，桌宠已恢复");
  process.exit(0);
}, DURATION);
