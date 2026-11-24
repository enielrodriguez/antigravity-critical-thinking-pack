#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FORCE_ALL=false
TARGET_AGY=false
TARGET_CLAUDE=false
TARGET_COPILOT=false
SPECIFIC_TARGET=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Deploys antigravity-critical-thinking-pack progressive skills to global AI tools.
Features:
  - Coexistence-safe: NEVER overwrites CLAUDE.md or copilot-instructions.md
    (coexists cleanly alongside antigravity-sdlc-pack)
  - Zero coding-session overhead: ships progressive skills only (no global rules)
  - Surgical: only updates pack-owned skills; preserves your other skills

Options:
  -a, --all          Force deployment to all platforms regardless of detection
      --antigravity  Deploy to Google Antigravity only
      --claude       Deploy skills to Anthropic Claude Code only
      --copilot      Deploy skills to GitHub Copilot only
  -h, --help         Show this help message
EOF
}

deploy_skills_surgically() {
  local src_dir="$1"
  local dest_dir="$2"

  if [ -L "$dest_dir" ]; then
    rm -f "$dest_dir"
  fi
  mkdir -p "$dest_dir"

  local count=0
  for skill_path in "${src_dir}"/*; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name=$(basename "$skill_path")
    rm -rf "${dest_dir}/${skill_name}"
    cp -rf "$skill_path" "${dest_dir}/"
    count=$((count + 1))
  done
  echo "   ✔ Surgically deployed ${count} critical-thinking skills (existing skills & rule files untouched)"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--all)
      FORCE_ALL=true
      shift
      ;;
    --antigravity)
      TARGET_AGY=true
      SPECIFIC_TARGET=true
      shift
      ;;
    --claude)
      TARGET_CLAUDE=true
      SPECIFIC_TARGET=true
      shift
      ;;
    --copilot)
      TARGET_COPILOT=true
      SPECIFIC_TARGET=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [ "$SPECIFIC_TARGET" = false ] && [ "$FORCE_ALL" = false ]; then
  if command -v agy &>/dev/null || [ -d "${HOME}/.gemini" ]; then
    TARGET_AGY=true
  fi
  if command -v claude &>/dev/null || [ -d "${HOME}/.claude" ]; then
    TARGET_CLAUDE=true
  fi
  if [ -d "${HOME}/.copilot" ] || command -v copilot &>/dev/null; then
    TARGET_COPILOT=true
  fi
elif [ "$FORCE_ALL" = true ]; then
  TARGET_AGY=true
  TARGET_CLAUDE=true
  TARGET_COPILOT=true
fi

echo "🚀 Deploying critical-thinking suite from: ${REPO_ROOT}"
echo ""

# 1. Google Antigravity
if [ "$TARGET_AGY" = true ]; then
  if command -v agy &>/dev/null; then
    echo "🔹 [Google Antigravity] Installing/Updating plugin package..."
    agy plugin install "${REPO_ROOT}"
  else
    echo "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
  fi
else
  echo "⏭️  [Google Antigravity] Not detected. Skipping (use --all to force)."
fi

# 2. Anthropic Claude Code (skills only — preserves CLAUDE.md)
if [ "$TARGET_CLAUDE" = true ]; then
  echo "🔹 [Claude Code] Deploying skills to ~/.claude/skills (CLAUDE.md untouched)..."
  deploy_skills_surgically "${REPO_ROOT}/skills" "${HOME}/.claude/skills"
else
  echo "⏭️  [Claude Code] Not detected on this machine. Skipping (use --all or --claude to force)."
fi

# 3. GitHub Copilot (skills only — preserves copilot-instructions.md)
if [ "$TARGET_COPILOT" = true ]; then
  echo "🔹 [GitHub Copilot] Deploying skills to ~/.copilot/skills (copilot-instructions.md untouched)..."
  deploy_skills_surgically "${REPO_ROOT}/skills" "${HOME}/.copilot/skills"
else
  echo "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use --all or --copilot to force)."
fi

echo ""
echo "✨ Global deployment finished."
echo "💡 For Web Chats (Gemini Saved Info, Gems, Claude Web, ChatGPT), see: ${REPO_ROOT}/web-exports/"
