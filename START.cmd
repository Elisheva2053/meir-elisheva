@echo off
setlocal EnableExtensions
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$root=(Get-Location).Path;" ^
  "$template=Join-Path $root 'index.html';" ^
  "$output=Join-Path $root '_run.html';" ^
  "$imageExt=@('.jpg','.jpeg','.jfif','.png','.webp','.gif','.bmp','.avif','.svg');" ^
  "$musicExt=@('.mp3','.wav','.m4a','.aac','.ogg','.flac','.wma');" ^
  "function Get-Media([string]$folder,[string[]]$exts){" ^
  "  $dir=Join-Path $root $folder;" ^
  "  if(-not (Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir | Out-Null };" ^
  "  @((Get-ChildItem -LiteralPath $dir -File -Recurse -ErrorAction SilentlyContinue |" ^
  "    Where-Object { $exts -contains $_.Extension.ToLowerInvariant() } |" ^
  "    Sort-Object FullName | ForEach-Object {" ^
  "      $rel=$_.FullName.Substring($root.Length) -replace '^[\\/]+','' -replace '\\','/';" ^
  "      $encoded=(($rel -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/';" ^
  "      './'+$encoded" ^
  "    }))" ^
  "};" ^
  "$data=[ordered]@{images=@(Get-Media 'images' $imageExt);music=@(Get-Media 'music' $musicExt)};" ^
  "$json=$data | ConvertTo-Json -Compress -Depth 5;" ^
  "$html=[System.IO.File]::ReadAllText($template,[System.Text.Encoding]::UTF8);" ^
  "$payload='<script>window.MEDIA_LIST = '+$json+';</script>';" ^
  "if(-not $html.Contains('<!--MEDIA_LIST-->')){ throw 'MEDIA_LIST placeholder is missing from index.html' };" ^
  "$html=$html.Replace('<!--MEDIA_LIST-->',$payload);" ^
  "$utf8=New-Object System.Text.UTF8Encoding($false);" ^
  "[System.IO.File]::WriteAllText($output,$html,$utf8);" ^
  "Start-Process $output;"

if errorlevel 1 (
  echo.
  echo Could not scan the images and music folders.
  echo Make sure index.html, START.cmd, images and music are together.
  pause
  exit /b 1
)

endlocal
