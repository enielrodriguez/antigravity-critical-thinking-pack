<#
.SYNOPSIS
    Deploys antigravity-critical-thinking-pack progressive skills to global AI tools on Windows.
    Compatible with Windows PowerShell 5.1 and PowerShell 7+.

.DESCRIPTION
    Automatically detects installed tools (Antigravity, Claude Code, GitHub Copilot)
    and deploys progressive skills surgically without touching CLAUDE.md or
    copilot-instructions.md, allowing conflict-free coexistence with antigravity-sdlc-pack.
#>

param(
    [switch]$All,
    [switch]$Antigravity,
    [switch]$Claude,
    [switch]$Copilot
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

function Deploy-SkillsSurgically {
    param(
        [Parameter(Mandatory = $true)][string]$SourceSkillsDir,
        [Parameter(Mandatory = $true)][string]$DestSkillsDir
    )

    if (-not (Test-Path -LiteralPath $DestSkillsDir)) {
        New-Item -ItemType Directory -Path $DestSkillsDir -Force | Out-Null
    }

    $Count = 0
    Get-ChildItem -LiteralPath $SourceSkillsDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $TargetSkillPath = Join-Path $DestSkillsDir $SkillName

        if (Test-Path -LiteralPath $TargetSkillPath) {
            Remove-Item -LiteralPath $TargetSkillPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -LiteralPath $_.FullName -Destination $TargetSkillPath -Recurse -Force
        $Count++
    }

    Write-Host "   ✔ Surgically deployed $Count critical-thinking skills (existing skills & rule files untouched)"
}

$TargetAgy = $false
$TargetClaude = $false
$TargetCopilot = $false
$SpecificTarget = $Antigravity.IsPresent -or $Claude.IsPresent -or $Copilot.IsPresent

if (-not $SpecificTarget -and -not $All) {
    $GeminiDir = Join-Path $env:USERPROFILE ".gemini"
    if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $GeminiDir)) {
        $TargetAgy = $true
    }
    $ClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $ClaudeDir)) {
        $TargetClaude = $true
    }
    $CopilotDir = Join-Path $env:USERPROFILE ".copilot"
    if ((Get-Command copilot -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $CopilotDir)) {
        $TargetCopilot = $true
    }
} elseif ($All) {
    $TargetAgy = $true
    $TargetClaude = $true
    $TargetCopilot = $true
} else {
    $TargetAgy = $Antigravity.IsPresent
    $TargetClaude = $Claude.IsPresent
    $TargetCopilot = $Copilot.IsPresent
}

Write-Host "🚀 Deploying critical-thinking suite from: $RepoRoot`n"

if ($TargetAgy) {
    if (Get-Command agy -ErrorAction SilentlyContinue) {
        Write-Host "🔹 [Google Antigravity] Installing/Updating plugin package..."
        & agy plugin install "$RepoRoot"
        if ($LASTEXITCODE -ne 0) {
            throw "agy plugin install failed with exit code $LASTEXITCODE"
        }
    } else {
        Write-Host "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
    }
} else {
    Write-Host "⏭️  [Google Antigravity] Not detected. Skipping (use -All to force)."
}

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
if ($TargetClaude) {
    Write-Host "🔹 [Claude Code] Deploying skills to $ClaudeDir\skills (CLAUDE.md untouched)..."
    Deploy-SkillsSurgically -SourceSkillsDir (Join-Path $RepoRoot "skills") -DestSkillsDir (Join-Path $ClaudeDir "skills")
} else {
    Write-Host "⏭️  [Claude Code] Not detected on this machine. Skipping (use -All or -Claude to force)."
}

$CopilotDir = Join-Path $env:USERPROFILE ".copilot"
if ($TargetCopilot) {
    Write-Host "🔹 [GitHub Copilot] Deploying skills to $CopilotDir\skills (copilot-instructions.md untouched)..."
    Deploy-SkillsSurgically -SourceSkillsDir (Join-Path $RepoRoot "skills") -DestSkillsDir (Join-Path $CopilotDir "skills")
} else {
    Write-Host "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use -All or -Copilot to force)."
}

Write-Host "`n✨ Global deployment finished."
Write-Host "💡 For Web Chats (Gemini Saved Info, Gems, Claude Web, ChatGPT), see: $(Join-Path $RepoRoot 'web-exports')"
