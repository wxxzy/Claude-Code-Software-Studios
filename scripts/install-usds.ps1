# ============================================================================
# USDS (Universal Software Studio) v2 安装脚本 - Windows PowerShell
# 仓库: https://github.com/wxxzy/Claude-Code-Software-Studios
#
# 用法:
#   .\install-usds.ps1 -Profile <minimal|vibe|studio|full>
#                      [-DryRun] [-Force] [-NoSamples]
#                      [-Uninstall] [-Ref <branch|tag>]
#
# 远程安装:
#   irm <raw-url>/install-usds.ps1 | iex
#   & ([scriptblock]::Create((irm <raw-url>/install-usds.ps1))) -Profile vibe -DryRun
# ============================================================================

[CmdletBinding()]
param(
    [ValidateSet('minimal','vibe','studio','full','')]
    [string]$Profile = '',
    [switch]$DryRun,
    [switch]$Force,
    [switch]$NoSamples,
    [switch]$Uninstall,
    [string]$Ref = 'master'
)

$ErrorActionPreference = 'Stop'

# ---------- 检测管道模式 (irm | iex 等) ----------
# 管道模式下 stdin 被占用，Read-Host 会静默返回空 → 导致覆盖询问全被跳过
$IsPipedInstall = [Console]::IsInputRedirected -or -not [Environment]::UserInteractive

if ($IsPipedInstall) {
    Write-Host ""
    Write-Host "⚠ 检测到管道/非交互式安装模式" -ForegroundColor Yellow
    Write-Host "  Read-Host 无法接收输入，已自动启用 -Force" -ForegroundColor Yellow
    Write-Host "  若要交互式菜单，请：irm <url> -OutFile install-usds.ps1 后本地执行" -ForegroundColor Yellow
    Write-Host ""

    # 强制启用 Force，否则每个已存在文件都会被静默跳过
    $Force = $true

    # 管道模式必须显式指定 Profile
    if (-not $Profile) {
        Write-Host "✗ 管道模式必须显式指定 -Profile" -ForegroundColor Red
        Write-Host ""
        Write-Host "示例:" -ForegroundColor White
        Write-Host "  & ([scriptblock]::Create((irm <url>))) -Profile vibe"
        Write-Host "  & ([scriptblock]::Create((irm <url>))) -Profile studio -DryRun"
        exit 1
    }
}

# ---------- 常量 ----------
$RepoUrl = "https://github.com/wxxzy/Claude-Code-Software-Studios"
$ManifestFile = ".usds-manifest"
$ModeFile = ".usds-mode"

function Write-Info($msg)    { Write-Host $msg -ForegroundColor Cyan }
function Write-Dim($msg)     { Write-Host $msg -ForegroundColor DarkGray }
function Write-Ok($msg)      { Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg)    { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)     { Write-Host $msg -ForegroundColor Red }

# ---------- 卸载分支 ----------
if ($Uninstall) {
    if (-not (Test-Path $ManifestFile)) {
        Write-Err "✗ 找不到 $ManifestFile，无法卸载"; exit 1
    }
    Write-Warn "⚠ 将删除以下由 USDS 安装的文件:"
    Get-Content $ManifestFile
    $ans = Read-Host "确认继续？[y/N]"
    if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "已取消"; exit 0 }
    Get-Content $ManifestFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and (Test-Path $line)) {
            Remove-Item -Path $line -Recurse -Force
            Write-Dim "removed: $line"
        }
    }
    Remove-Item -Path $ManifestFile -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $ModeFile -Force -ErrorAction SilentlyContinue
    Write-Ok "✓ 卸载完成"; exit 0
}

# ---------- Profile 选择 ----------
if (-not $Profile) {
    Write-Host ""
    Write-Info "Universal Software Studio (USDS) v2 安装"
    Write-Host ""
    Write-Host "请选择安装 Profile:"
    Write-Host "  1) minimal - 仅核心规则和基础技能"
    Write-Host "  2) vibe    - Vibe Mode（探索/原型/个人项目）"
    Write-Host "  3) studio  - Studio Mode（生产/团队/严肃项目）"
    Write-Host "  4) full    - 全装（hybrid，兼容旧行为）"
    $choice = Read-Host "选择 [1-4，默认 3]"
    switch ($choice) {
        '1' { $Profile = 'minimal' }
        '2' { $Profile = 'vibe' }
        '3' { $Profile = 'studio' }
        '4' { $Profile = 'full' }
        ''  { $Profile = 'studio' }
        default { Write-Err "无效选择"; exit 1 }
    }
}

# ---------- 分层文件清单 ----------
$CoreFiles = @(
    "CLAUDE.md",
    ".usds-mode.example",
    # --- Runtime infrastructure (v2 曾漏装 — 修复) ---
    ".claude/settings.json",
    ".claude/statusline.sh",
    ".claude/hooks",
    ".claude/VERSION",
    # --- Rules ---
    ".claude/rules/global-standards.md",
    ".claude/rules/ai-generated-code.md",
    ".claude/rules/doc-standards.md",
    # --- Base skills ---
    ".claude/skills/usds-start",
    ".claude/skills/usds-onboard",
    ".claude/skills/usds-update",
    ".claude/skills/usds-mode-switch",
    ".claude/skills/usds-cost-report",
    ".claude/skills/usds-debt-log",
    ".claude/skills/usds-micro-adr",
    # --- Base agents ---
    ".claude/agents/delivery-manager.md",
    ".claude/agents/cost-accountant.md",
    ".claude/agents/debt-auditor.md",
    # --- Base docs & templates ---
    ".claude/docs/quick-start.md",
    ".claude/docs/directory-structure.md",
    ".claude/docs/templates/cost-ledger.md",
    ".claude/docs/templates/debt-ledger.md",
    ".claude/docs/templates/micro-adr.md"
)

$VibeFiles = @(
    ".claude/rules/vibe-mode.md",
    ".claude/skills/vibe-start",
    ".claude/skills/vibe-prototype",
    ".claude/skills/vibe-check",
    ".claude/skills/vibe-graduate",
    ".claude/skills/vibe-taste-review",
    ".claude/skills/vibe-branch",
    ".claude/skills/vibe-explain-back",
    ".claude/agents/explorer.md",
    ".claude/agents/stylist.md",
    ".claude/agents/prompt-refiner.md",
    ".claude/agents/explainer.md",
    ".claude/docs/templates/lite-spec.md",
    ".claude/docs/templates/intent-log.md",
    "sandbox/README.md"
)

$StudioFiles = @(
    ".claude/rules/backend-api.md",
    ".claude/rules/test-conventions.md",
    ".claude/skills/studio-discovery",
    ".claude/skills/studio-setup-stack",
    ".claude/skills/studio-arch-design",
    ".claude/skills/studio-summarize-arch",
    ".claude/skills/studio-sprint-kickoff",
    ".claude/skills/studio-project-scan",
    ".claude/skills/studio-review",
    ".claude/skills/studio-gate-check",
    ".claude/agents/product-director.md",
    ".claude/agents/technical-architect.md",
    ".claude/agents/lead-developer.md",
    ".claude/agents/qa-lead.md",
    ".claude/agents/frontend-developer.md",
    ".claude/agents/backend-developer.md",
    ".claude/agents/devops-engineer.md",
    ".claude/agents/security-engineer.md",
    ".claude/docs/templates/PRD.md",
    ".claude/docs/templates/ADR.md",
    ".claude/docs/templates/BACKLOG.md",
    ".claude/docs/templates/RELEASE-CHECKLIST.md"
)

$FilesToInstall = @($CoreFiles)
switch ($Profile) {
    'vibe'   { $FilesToInstall += $VibeFiles }
    'studio' { $FilesToInstall += $StudioFiles }
    'full'   { $FilesToInstall += $VibeFiles; $FilesToInstall += $StudioFiles }
}

# 预创建目录清单（TD-007：消除 detect-gaps.sh 的虚假警告）
# 不写入 manifest —— 卸载时不得删除可能已含用户内容的工程目录
$DirsToPrecreate = @("production/session-state", "production/session-logs")
switch ($Profile) {
    'vibe'   { $DirsToPrecreate += "sandbox" }
    'studio' { $DirsToPrecreate += @("docs/specs", "docs/arch", "docs/reviews") }
    'full'   { $DirsToPrecreate += @("sandbox", "docs/specs", "docs/arch", "docs/reviews") }
}

# v2.0 → v2.1 重命名残留清理清单（ADR-002：升级时旧命令目录若存在则删除）
# 这些均为 USDS 保留名，绝不涉及用户自装技能
$RenamedAwaySkills = @(
    "start", "onboard", "mode-switch", "update", "cost-report", "debt-log", "micro-adr",
    "prototype", "taste-review", "branch-vibe", "explain-back", "graduate",
    "discovery", "project-scan", "setup-stack", "arch-design", "summarize-arch",
    "sprint-kickoff", "review", "gate-check"
)

# ---------- 预览 ----------
Write-Host ""
Write-Host "安装计划:" -ForegroundColor White
Write-Host "  Profile:  " -NoNewline; Write-Info $Profile
Write-Host "  Ref:      $Ref"
Write-Host "  Dry-run:  $DryRun"
Write-Host "  Force:    $Force"
Write-Host "  文件数量: $($FilesToInstall.Count)"
Write-Host ""

if ($DryRun) {
    Write-Warn "[DRY-RUN] 以下文件将被安装:"
    $FilesToInstall | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    Write-Warn "[DRY-RUN] 以下目录将被预创建（已存在则跳过）:"
    $DirsToPrecreate | ForEach-Object { Write-Host "  $_/" }
    Write-Host ""
    $StaleFound = $RenamedAwaySkills | Where-Object { Test-Path ".claude/skills/$_" }
    if ($StaleFound) {
        Write-Warn "[DRY-RUN] 检测到 v2.0 旧命令目录，将清理:"
        $StaleFound | ForEach-Object { Write-Host "  .claude/skills/$_/" }
        Write-Host ""
    }
    Write-Dim "未做任何修改。移除 -DryRun 后正式执行。"
    exit 0
}

# ---------- 下载 ----------
$ZipUrl = "$RepoUrl/archive/refs/heads/$Ref.zip"
$TempZip = Join-Path $env:TEMP "usds-$([guid]::NewGuid()).zip"
$TempDir = Join-Path $env:TEMP "usds-$([guid]::NewGuid())"

try {
    Write-Dim "📥 下载中: $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing

    Write-Dim "📦 解压..."
    if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
    Expand-Archive -Path $TempZip -DestinationPath $TempDir

    $SourceRoot = Get-ChildItem -Path $TempDir -Directory |
        Where-Object { $_.Name -like 'Claude-Code-Software-Studios-*' } |
        Select-Object -First 1 -ExpandProperty FullName

    if (-not $SourceRoot) {
        Write-Err "✗ 解压后找不到源目录"; exit 1
    }

    # ---------- 安装 ----------
    $Installed = @()
    $Skipped = @()

    function Install-Item-Local {
        param([string]$Rel)
        $Src = Join-Path $SourceRoot $Rel
        $Dst = $Rel
        if (-not (Test-Path $Src)) {
            Write-Dim "  ⊘ 源不存在，跳过: $Rel"; return
        }
        if (Test-Path $Dst) {
            if (-not $Force) {
                $ans = Read-Host "  已存在 $Rel，覆盖？[y/N]"
                if ($ans -ne 'y' -and $ans -ne 'Y') {
                    $script:Skipped += $Rel
                    Write-Dim "  ⊘ 跳过: $Rel"; return
                }
            }
        }
        $DstDir = Split-Path -Parent $Dst
        if ($DstDir -and -not (Test-Path $DstDir)) {
            New-Item -ItemType Directory -Path $DstDir -Force | Out-Null
        }
        Copy-Item -Path $Src -Destination $Dst -Recurse -Force
        $script:Installed += $Rel
        Write-Ok "  ✓ $Rel"
    }

    Write-Host ""
    Write-Host "开始安装..." -ForegroundColor White
    foreach ($item in $FilesToInstall) { Install-Item-Local -Rel $item }

    # ---------- v2.0 重命名残留清理 (ADR-002) ----------
    # 升级路径：删除已被 v2.1 前缀化取代的旧命令目录，避免斜杠菜单新旧并存
    $StaleRemoved = 0
    foreach ($old in $RenamedAwaySkills) {
        if (Test-Path ".claude/skills/$old") {
            Remove-Item -Path ".claude/skills/$old" -Recurse -Force
            $StaleRemoved++
            Write-Warn "  🧹 已清理 v2.0 旧命令目录: .claude/skills/$old/"
        }
    }
    if ($StaleRemoved -gt 0) {
        Write-Dim "  （共 $StaleRemoved 个，详见 CLAUDE.md 新旧对照表）"
    }

    # ---------- 目录预创建 (TD-007) ----------
    # 已存在（无论是否为空）一律跳过；新建目录补 .gitkeep 供 git 追踪
    Write-Host ""
    Write-Host "目录预创建:" -ForegroundColor White
    foreach ($d in $DirsToPrecreate) {
        if (Test-Path $d) {
            Write-Dim "  ⊘ 目录已存在，跳过: $d/"
        } else {
            New-Item -ItemType Directory -Path $d -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $d '.gitkeep') -Force | Out-Null
            Write-Ok "  ✓ $d/ (+.gitkeep)"
        }
    }

    # ---------- 示范 docs ----------
    if (-not $NoSamples -and (Test-Path (Join-Path $SourceRoot 'docs'))) {
        if (Test-Path 'docs') {
            Write-Warn "⚠ 用户 docs/ 已存在，跳过示范文档（用 -Force 覆盖）"
        } elseif ($IsPipedInstall) {
            Write-Dim "  ⊘ 管道模式跳过示范 docs/（用 -Force 或本地执行触发）"
        } else {
            $ans = Read-Host "是否安装示范 docs/ 目录？[y/N]"
            if ($ans -eq 'y' -or $ans -eq 'Y') {
                Copy-Item -Path (Join-Path $SourceRoot 'docs') -Destination '.' -Recurse -Force
                $Installed += 'docs'
                Write-Ok "  ✓ docs/ (示范)"
            }
        }
    }

    # ---------- README 保护 ----------
    if (-not (Test-Path 'README.md') -and (Test-Path (Join-Path $SourceRoot 'README.md'))) {
        if ($IsPipedInstall) {
            Write-Dim "  ⊘ 管道模式跳过 README.md 询问（保留空 README 状态）"
        } else {
            $ans = Read-Host "当前项目没有 README.md，是否用 USDS 的入门 README？[y/N]"
            if ($ans -eq 'y' -or $ans -eq 'Y') {
                Copy-Item -Path (Join-Path $SourceRoot 'README.md') -Destination '.' -Force
                $Installed += 'README.md'
                Write-Ok "  ✓ README.md"
            }
        }
    } else {
        Write-Dim "  ⊘ 保留用户 README.md"
    }

    # ---------- 初始化 .usds-mode ----------
    if (-not (Test-Path $ModeFile)) {
        $Mode = switch ($Profile) {
            'vibe'    { 'vibe' }
            'studio'  { 'studio' }
            'minimal' { 'studio' }
            'full'    { 'hybrid' }
        }
        $today = Get-Date -Format 'yyyy-MM-dd'
        @"
mode: $Mode
created: $today
last_switched: $today
reason: 由 install-usds.ps1 -Profile $Profile 初始化
locked: false
"@ | Out-File -FilePath $ModeFile -Encoding utf8
        $Installed += $ModeFile
        Write-Ok "  ✓ $ModeFile (mode=$Mode)"
    }

    # ---------- Manifest ----------
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $header = @(
        "# USDS install manifest",
        "# generated: $now",
        "# profile: $Profile",
        "# ref: $Ref"
    )
    ($header + $Installed) | Out-File -FilePath $ManifestFile -Encoding utf8

    # ---------- 结束报告 ----------
    Write-Host ""
    Write-Ok "✨ USDS 已就绪"
    Write-Host "  Profile:  $Profile"
    Write-Host "  已安装:   $($Installed.Count) 项"
    Write-Host "  已跳过:   $($Skipped.Count) 项"
    Write-Host "  Manifest: $ManifestFile"
    Write-Host ""
    Write-Host "下一步:" -ForegroundColor White
    switch ($Profile) {
        'vibe'    { Write-Host "  运行 claude → /vibe-start `"你的想法`"" }
        'studio'  { Write-Host "  运行 claude → /usds-onboard  然后  /studio-discovery `"你的项目`"" }
        'minimal' { Write-Host "  运行 claude → /usds-mode-switch 选择模式" }
        'full'    { Write-Host "  运行 claude → /usds-onboard 了解双模态" }
    }
    Write-Host ""
    Write-Dim "卸载: .\install-usds.ps1 -Uninstall"
}
finally {
    if (Test-Path $TempZip) { Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
}
