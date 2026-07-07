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
    ".claude/rules/global-standards.md",
    ".claude/rules/ai-generated-code.md",
    ".claude/rules/doc-standards.md",
    ".claude/skills/start",
    ".claude/skills/onboard",
    ".claude/skills/update",
    ".claude/skills/mode-switch",
    ".claude/skills/cost-report",
    ".claude/skills/debt-log",
    ".claude/skills/micro-adr",
    ".claude/agents/delivery-manager.md",
    ".claude/agents/cost-accountant.md",
    ".claude/agents/debt-auditor.md",
    ".claude/docs/quick-start.md",
    ".claude/docs/directory-structure.md",
    ".claude/docs/templates/cost-ledger.md",
    ".claude/docs/templates/debt-ledger.md",
    ".claude/docs/templates/micro-adr.md"
)

$VibeFiles = @(
    ".claude/rules/vibe-mode.md",
    ".claude/skills/vibe-start",
    ".claude/skills/prototype",
    ".claude/skills/vibe-check",
    ".claude/skills/graduate",
    ".claude/skills/taste-review",
    ".claude/skills/branch-vibe",
    ".claude/skills/explain-back",
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
    ".claude/skills/discovery",
    ".claude/skills/setup-stack",
    ".claude/skills/arch-design",
    ".claude/skills/summarize-arch",
    ".claude/skills/sprint-kickoff",
    ".claude/skills/project-scan",
    ".claude/skills/review",
    ".claude/skills/gate-check",
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

    # ---------- 示范 docs ----------
    if (-not $NoSamples -and (Test-Path (Join-Path $SourceRoot 'docs'))) {
        if (Test-Path 'docs') {
            Write-Warn "⚠ 用户 docs/ 已存在，跳过示范文档（用 -Force 覆盖）"
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
        $ans = Read-Host "当前项目没有 README.md，是否用 USDS 的入门 README？[y/N]"
        if ($ans -eq 'y' -or $ans -eq 'Y') {
            Copy-Item -Path (Join-Path $SourceRoot 'README.md') -Destination '.' -Force
            $Installed += 'README.md'
            Write-Ok "  ✓ README.md"
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
        'studio'  { Write-Host "  运行 claude → /onboard  然后  /discovery `"你的项目`"" }
        'minimal' { Write-Host "  运行 claude → /mode-switch 选择模式" }
        'full'    { Write-Host "  运行 claude → /onboard 了解双模态" }
    }
    Write-Host ""
    Write-Dim "卸载: .\install-usds.ps1 -Uninstall"
}
finally {
    if (Test-Path $TempZip) { Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
}
