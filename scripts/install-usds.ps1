# ============================================================================
# USDS (Universal Software Studio) v2 installer - Windows PowerShell
# Repo: https://github.com/wxxzy/Claude-Code-Software-Studios
#
# Usage:
#   .\install-usds.ps1 -Profile <minimal|vibe|studio|full>
#                      [-DryRun] [-Force] [-NoSamples]
#                      [-Uninstall] [-Ref <branch|tag>]
#
# Remote install:
#   irm <raw-url>/install-usds.ps1 | iex
#   & ([scriptblock]::Create((irm <raw-url>/install-usds.ps1))) -Profile vibe -DryRun
#
# NOTE: This file is intentionally PURE ASCII (no BOM, no CJK, no emoji).
# Windows PowerShell 5.1 needs a UTF-8 BOM to parse CJK source correctly,
# but a leading BOM poisons "irm | iex" (it becomes an invalid token in the
# string passed to Invoke-Expression). ASCII-only is the only encoding that
# satisfies local execution AND the piped one-liner on every PS version.
# Regression guard: tests/hooks/installer-ps1.bats fails on any non-ASCII byte.
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

# --------------------------------------------------------------------------
# Exit semantics: when run as a .ps1 FILE, "exit N" sets the script exit code.
# But in a dynamic scriptblock (irm | iex / [scriptblock]::Create(...)), "exit"
# terminates the USER'S ENTIRE PowerShell session (the window/tab closes).
# So the whole body lives in this function and RETURNS codes; the dispatcher
# at the bottom of the file decides how to terminate.
# --------------------------------------------------------------------------
function Invoke-USDSMain {
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

    # ---------- Detect piped / non-interactive mode (irm | iex, CI, ...) ----------
# When stdin is not a console, Read-Host cannot receive input -> skip prompts
$IsPipedInstall = [Console]::IsInputRedirected -or -not [Environment]::UserInteractive

# ---------- Constants ----------
$RepoUrl = "https://github.com/wxxzy/Claude-Code-Software-Studios"
$ManifestFile = ".usds-manifest"
$ModeFile = ".usds-mode"

function Write-Info($msg)    { Write-Host $msg -ForegroundColor Cyan }
function Write-Dim($msg)     { Write-Host $msg -ForegroundColor DarkGray }
function Write-Ok($msg)      { Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg)    { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)     { Write-Host $msg -ForegroundColor Red }

# ---------- Uninstall branch (before the piped guard: uninstall needs no -Profile) ----------
if ($Uninstall) {
    if (-not (Test-Path $ManifestFile)) {
        Write-Err "[x] $ManifestFile not found, nothing to uninstall"; return 1
    }
    Write-Warn "[!] The following USDS-installed files will be removed:"
    # Write-Host, NOT bare pipeline output: anything the function emits to the
    # output stream joins its return value and corrupts the exit code
    Get-Content $ManifestFile | ForEach-Object { Write-Host "  $_" }
    if ($IsPipedInstall -and -not $Force) {
        # A piped run cannot answer the confirmation prompt; demand explicit intent
        Write-Host ""
        Write-Err "[x] Piped mode: rerun with -Uninstall -Force to confirm the removal listed above"
        return 1
    }
    if (-not $Force) {
        $ans = Read-Host "Proceed? [y/N]"
        if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "Cancelled"; return 0 }
    }
    Get-Content $ManifestFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and (Test-Path $line)) {
            Remove-Item -Path $line -Recurse -Force
            Write-Dim "removed: $line"
        }
    }
    Remove-Item -Path $ManifestFile -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $ModeFile -Force -ErrorAction SilentlyContinue
    Write-Ok "[ok] Uninstall complete"; return 0
}

# ---------- Piped-mode guard (install path; uninstall was handled above) ----------
if ($IsPipedInstall) {
    Write-Host ""
    Write-Host "[!] Non-interactive/piped install detected" -ForegroundColor Yellow
    Write-Host "    Read-Host is unavailable, enabling -Force automatically" -ForegroundColor Yellow
    Write-Host "    For the interactive menu: irm <url> -OutFile install-usds.ps1, then run it locally" -ForegroundColor Yellow
    Write-Host ""

    # Force overwrites, otherwise every existing file would be silently skipped
    $Force = $true

    # Piped mode requires an explicit -Profile
    if (-not $Profile) {
        Write-Host "[x] Piped mode requires an explicit -Profile" -ForegroundColor Red
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor White
        Write-Host "  & ([scriptblock]::Create((irm <url>))) -Profile vibe"
        Write-Host "  & ([scriptblock]::Create((irm <url>))) -Profile studio -DryRun"
        return 1
    }
}

# ---------- Profile selection ----------
if (-not $Profile) {
    Write-Host ""
    Write-Info "Universal Software Studio (USDS) v2 installer"
    Write-Host ""
    Write-Host "Select an install profile:"
    Write-Host "  1) minimal - core rules and base skills only"
    Write-Host "  2) vibe    - Vibe Mode (explore / prototype / personal)"
    Write-Host "  3) studio  - Studio Mode (production / team / serious)"
    Write-Host "  4) full    - everything (hybrid, legacy behavior)"
    $choice = Read-Host "Choice [1-4, default 3]"
    switch ($choice) {
        '1' { $Profile = 'minimal' }
        '2' { $Profile = 'vibe' }
        '3' { $Profile = 'studio' }
        '4' { $Profile = 'full' }
        ''  { $Profile = 'studio' }
        default { Write-Err "Invalid choice"; return 1 }
    }
}

# ---------- Layered file lists ----------
$CoreFiles = @(
    "CLAUDE.md",
    ".usds-mode.example",
    # --- Runtime infrastructure (was missing in v2 - fixed) ---
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
    ".claude/docs/skills-reference.md",
    ".claude/docs/coordination-rules.md",
    ".claude/docs/CLAUDE-local-template.md",
    ".claude/docs/settings-local-template.md",
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

# Directories to pre-create (TD-007: silence false warnings from detect-gaps.sh)
# NOT written to the manifest - uninstall must never remove project dirs that may hold user content
$DirsToPrecreate = @("production/session-state", "production/session-logs")
switch ($Profile) {
    'vibe'   { $DirsToPrecreate += "sandbox" }
    'studio' { $DirsToPrecreate += @("docs/specs", "docs/arch", "docs/reviews") }
    'full'   { $DirsToPrecreate += @("sandbox", "docs/specs", "docs/arch", "docs/reviews") }
}

# v2.0 -> v2.1 renamed-away skills (ADR-002: remove old dirs on upgrade if present)
# All are USDS-reserved names; user-installed skills are never touched
$RenamedAwaySkills = @(
    "start", "onboard", "mode-switch", "update", "cost-report", "debt-log", "micro-adr",
    "prototype", "taste-review", "branch-vibe", "explain-back", "graduate",
    "discovery", "project-scan", "setup-stack", "arch-design", "summarize-arch",
    "sprint-kickoff", "review", "gate-check"
)

# ---------- Preview ----------
Write-Host ""
Write-Host "Install plan:" -ForegroundColor White
Write-Host "  Profile:  " -NoNewline; Write-Info $Profile
Write-Host "  Ref:      $Ref"
Write-Host "  Dry-run:  $DryRun"
Write-Host "  Force:    $Force"
Write-Host "  Files:    $($FilesToInstall.Count)"
Write-Host ""

if ($DryRun) {
    Write-Warn "[DRY-RUN] Files to be installed:"
    $FilesToInstall | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    Write-Warn "[DRY-RUN] Directories to be pre-created (skipped if present):"
    $DirsToPrecreate | ForEach-Object { Write-Host "  $_/" }
    Write-Host ""
    $StaleFound = $RenamedAwaySkills | Where-Object { Test-Path ".claude/skills/$_" }
    if ($StaleFound) {
        Write-Warn "[DRY-RUN] Stale v2.0 skill dirs detected, will be cleaned:"
        $StaleFound | ForEach-Object { Write-Host "  .claude/skills/$_/" }
        Write-Host ""
    }
    Write-Dim "No changes made. Remove -DryRun to execute for real."
    return 0
}

# ---------- Download ----------
$ZipUrl = "$RepoUrl/archive/refs/heads/$Ref.zip"
$TempZip = Join-Path $env:TEMP "usds-$([guid]::NewGuid()).zip"
$TempDir = Join-Path $env:TEMP "usds-$([guid]::NewGuid())"

try {
    Write-Dim "Downloading: $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing

    Write-Dim "Extracting..."
    if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
    Expand-Archive -Path $TempZip -DestinationPath $TempDir

    $SourceRoot = Get-ChildItem -Path $TempDir -Directory |
        Where-Object { $_.Name -like 'Claude-Code-Software-Studios-*' } |
        Select-Object -First 1 -ExpandProperty FullName

    if (-not $SourceRoot) {
        Write-Err "[x] Source directory not found after extraction"; return 1
    }

    # ---------- Install ----------
    # List[string] (reference type): mutated in place, so accumulation inside
    # Install-Item-Local works under EVERY invocation form. Plain arrays +
    # $script: += broke in dynamic scriptblocks (irm | iex / [scriptblock]::Create
    # have no distinct script scope), leaving the manifest nearly empty.
    $Installed = [System.Collections.Generic.List[string]]::new()
    $Skipped = [System.Collections.Generic.List[string]]::new()

    # Single batch prompt instead of one question per existing file
    # (an upgrade used to ask 20-30 sequential [y/N] questions)
    $Existing = @($FilesToInstall | Where-Object { Test-Path $_ })
    if ($Existing.Count -gt 0 -and -not $Force) {
        Write-Warn "[!] $($Existing.Count) item(s) already exist:"
        $Existing | Select-Object -First 10 | ForEach-Object { Write-Dim "    $_" }
        if ($Existing.Count -gt 10) { Write-Dim "    ... and $($Existing.Count - 10) more" }
        $ans = Read-Host "Overwrite ALL existing items? [y/N]"
        if ($ans -eq 'y' -or $ans -eq 'Y') { $Force = $true }
    }

    function Install-Item-Local {
        param([string]$Rel)
        $Src = Join-Path $SourceRoot $Rel
        $Dst = $Rel
        if (-not (Test-Path $Src)) {
            Write-Dim "  [skip] source missing: $Rel"; return
        }
        if ((Test-Path $Dst) -and -not $Force) {
            $Skipped.Add($Rel)
            Write-Dim "  [skip] exists, kept: $Rel"; return
        }
        $DstDir = Split-Path -Parent $Dst
        if ($DstDir -and -not (Test-Path $DstDir)) {
            New-Item -ItemType Directory -Path $DstDir -Force | Out-Null
        }
        Copy-Item -Path $Src -Destination $Dst -Recurse -Force
        $Installed.Add($Rel)
        Write-Ok "  [ok] $Rel"
    }

    Write-Host ""
    Write-Host "Installing..." -ForegroundColor White
    foreach ($item in $FilesToInstall) { Install-Item-Local -Rel $item }

    # ---------- v2.0 renamed-away cleanup (ADR-002) ----------
    # Upgrade path: remove old command dirs superseded by v2.1 prefixes,
    # so the slash menu does not show old and new commands side by side
    $StaleRemoved = 0
    foreach ($old in $RenamedAwaySkills) {
        if (Test-Path ".claude/skills/$old") {
            Remove-Item -Path ".claude/skills/$old" -Recurse -Force
            $StaleRemoved++
            Write-Warn "  [clean] removed stale v2.0 skill dir: .claude/skills/$old/"
        }
    }
    if ($StaleRemoved -gt 0) {
        Write-Dim "          ($StaleRemoved total; see the rename table in CLAUDE.md)"
    }

    # ---------- Directory pre-creation (TD-007) ----------
    # Skip if present (empty or not); new dirs get a .gitkeep for git tracking
    Write-Host ""
    Write-Host "Pre-creating directories:" -ForegroundColor White
    foreach ($d in $DirsToPrecreate) {
        if (Test-Path $d) {
            Write-Dim "  [skip] exists: $d/"
        } else {
            New-Item -ItemType Directory -Path $d -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $d '.gitkeep') -Force | Out-Null
            Write-Ok "  [ok] $d/ (+.gitkeep)"
        }
    }

    # ---------- Sample docs ----------
    if (-not $NoSamples -and (Test-Path (Join-Path $SourceRoot 'docs'))) {
        if (Test-Path 'docs') {
            Write-Warn "[!] docs/ already exists, skipping sample docs (use -Force to overwrite)"
        } elseif ($IsPipedInstall) {
            Write-Dim "  [skip] sample docs skipped in piped mode (use -Force or run locally)"
        } else {
            $ans = Read-Host "Install the sample docs/ directory? [y/N]"
            if ($ans -eq 'y' -or $ans -eq 'Y') {
                Copy-Item -Path (Join-Path $SourceRoot 'docs') -Destination '.' -Recurse -Force
                $Installed.Add('docs')
                Write-Ok "  [ok] docs/ (sample)"
            }
        }
    }

    # ---------- README protection ----------
    if (-not (Test-Path 'README.md') -and (Test-Path (Join-Path $SourceRoot 'README.md'))) {
        if ($IsPipedInstall) {
            Write-Dim "  [skip] README.md prompt skipped in piped mode"
        } else {
            $ans = Read-Host "No README.md found; install the USDS starter README? [y/N]"
            if ($ans -eq 'y' -or $ans -eq 'Y') {
                Copy-Item -Path (Join-Path $SourceRoot 'README.md') -Destination '.' -Force
                $Installed.Add('README.md')
                Write-Ok "  [ok] README.md"
            }
        }
    } else {
        Write-Dim "  [skip] user README.md preserved"
    }

    # ---------- Initialize .usds-mode ----------
    # Written as plain ASCII (no BOM): statusline.sh greps '^mode:' and a BOM
    # would hide the first line from grep on PS 5.1 installs
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
reason: initialized by install-usds.ps1 -Profile $Profile
locked: false
"@ | Out-File -FilePath $ModeFile -Encoding ascii
        $Installed.Add($ModeFile)
        Write-Ok "  [ok] $ModeFile (mode=$Mode)"
    }

    # ---------- Manifest ----------
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $header = @(
        "# USDS install manifest",
        "# generated: $now",
        "# profile: $Profile",
        "# ref: $Ref"
    )
    ($header + $Installed.ToArray()) | Out-File -FilePath $ManifestFile -Encoding ascii

    # ---------- Final report ----------
    Write-Host ""
    Write-Ok "[ok] USDS is ready"
    Write-Host "  Profile:  $Profile"
    Write-Host "  Installed: $($Installed.Count) item(s)"
    Write-Host "  Skipped:   $($Skipped.Count) item(s)"
    if ($Skipped.Count -gt 0) {
        Write-Dim "  Tip: rerun with -Force to overwrite the $($Skipped.Count) kept item(s)"
    }
    Write-Host "  Manifest:  $ManifestFile"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    switch ($Profile) {
        'vibe'    { Write-Host "  Run claude, then: /vibe-start `"your idea`"" }
        'studio'  { Write-Host "  Run claude, then: /usds-onboard, then /studio-discovery `"your project`"" }
        'minimal' { Write-Host "  Run claude, then: /usds-mode-switch to pick a mode" }
        'full'    { Write-Host "  Run claude, then: /usds-onboard for the dual-mode overview" }
    }
    Write-Host ""
    Write-Dim "Uninstall: .\install-usds.ps1 -Uninstall"
}
finally {
    if (Test-Path $TempZip) { Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
}

    return 0
}

# ---------- Dispatcher ----------
# File execution: propagate the exit code normally.
# Scriptblock execution (irm | iex): return WITHOUT calling exit, so the
# user's PowerShell session survives; expose the code via $global:LASTEXITCODE.
$__rc = Invoke-USDSMain @PSBoundParameters
if ($PSCommandPath) {
    exit $__rc
} else {
    $global:LASTEXITCODE = $__rc
}
