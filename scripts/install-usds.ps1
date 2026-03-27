# USDS 远程安装脚本 (Windows PowerShell 版)
# 仓库地址: https://github.com/wxxzy/Claude-Code-Software-Studios

$RepoUrl = "https://github.com/wxxzy/Claude-Code-Software-Studios"
$ZipUrl = "$RepoUrl/archive/refs/heads/master.zip"
$TempZip = "$env:TEMP\usds-master.zip"
$TempDir = "$env:TEMP\usds-extract"

Write-Host "🚀 正在从 GitHub 获取 Universal Software Studio (USDS)..." -ForegroundColor Cyan

# 1. 下载 ZIP 包
Write-Host "📥 正在下载核心组件..." -ForegroundColor Gray
Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip

# 2. 解压文件
Write-Host "📦 正在解压并注入项目..." -ForegroundColor Gray
if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
Expand-Archive -Path $TempZip -DestinationPath $TempDir

# 注意：GitHub Zip 解压后的文件夹名通常是 [仓库名]-[分支名]
$SourceFolder = Join-Path $TempDir "Claude-Code-Software-Studios-master"

# 3. 复制核心文件到当前目录
$ItemsToCopy = @(".claude", "docs", "production", "scripts", "CLAUDE.md", "UNIVERSAL-STUDIO.md", "README.md")
foreach ($Item in $ItemsToCopy) {
    $Src = Join-Path $SourceFolder $Item
    if (Test-Path $Src) {
        Copy-Item -Path $Src -Destination "." -Recurse -Force
        Write-Host "✅ 已同步: $Item" -ForegroundColor Green
    }
}

# 4. 清理临时文件
Remove-Item -Path $TempZip -Force
Remove-Item -Path $TempDir -Recurse -Force

Write-Host "`n✨ USDS 工作室已成功注入当前项目！" -ForegroundColor Green
Write-Host "👉 现在运行 'claude' 后，输入 '/onboard' 开始您的旅程。" -ForegroundColor White
