# USDS 工作室一键安装脚本 (Windows PowerShell 版)

$USDS_SOURCE = "https://your-internal-git/usds-core.git" # 替换为您的核心仓库地址

Write-Host "🚀 正在为当前项目注入 Universal Software Studio (USDS)..." -ForegroundColor Cyan

# 1. 创建核心目录
$Dirs = ".claude/agents", ".claude/skills", ".claude/rules", ".claude/hooks", ".claude/docs/templates", "docs/specs", "docs/arch", "docs/reviews", "production/backlog"
foreach ($Dir in $Dirs) {
    if (!(Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
}

# 2. 复制核心配置文件 (这里假设您已经把核心文件打包或放在固定位置)
# 在实际分发时，可以使用 git clone 或 curl 下载
Write-Host "📦 正在同步代理定义、技能指令与底层规则..." -ForegroundColor Yellow

# 3. 提示完成
Write-Host "✅ USDS 注入完成！" -ForegroundColor Green
Write-Host "👉 请运行 'claude' 进入会话，并输入 '/start' 开始引导。" -ForegroundColor White
