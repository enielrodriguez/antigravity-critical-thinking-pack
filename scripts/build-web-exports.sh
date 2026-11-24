#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_DIR="${REPO_ROOT}/core"
SKILLS_DIR="${REPO_ROOT}/skills"
OUT_DIR="${REPO_ROOT}/web-exports"
GEMS_DIR="${OUT_DIR}/gemini-gems"

mkdir -p "${GEMS_DIR}"

# Helper: strip leading YAML frontmatter (--- ... ---) from a SKILL.md file
strip_frontmatter() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; next }
    !in_fm { print }
  ' "$1" | sed '/./,$!d'
}

# Helper: convert slug (e.g. 01-epistemic-baseline) to human title
humanize_core_name() {
  local base
  base="$(basename "$1" .md)"
  case "$base" in
    01-epistemic-baseline)    echo "Block 1 — Epistemic Calibration, Truth & Anti-Anchoring" ;;
    02-scientific-restraint)  echo "Block 2 — Scientific Rigor vs. Practical Restraint" ;;
    03-factual-precision)     echo "Block 3 — Factual Precision, Anti-Inflation & Ambiguity" ;;
    04-jurisdiction-detection) echo "Block 4 — Dynamic Jurisdiction & Context Detection" ;;
    05-council-trigger)       echo "Block 5 — On-Demand Decision Council Trigger" ;;
    06-socioeconomic-anti-bias) echo "Block 6 — Socioeconomic, Political & Media Anti-Bias Lens" ;;
    *)                        echo "$base" ;;
  esac
}

# ---------------------------------------------------------------------------
# 1. Generate web-exports/gemini-saved-info.md
# ---------------------------------------------------------------------------
SAVED_INFO_OUT="${OUT_DIR}/gemini-saved-info.md"
{
  cat << 'EOF'
# Google Gemini — Saved Info (`Personal context`)

> Auto-generated from `core/*.md` by `scripts/build-web-exports.sh`. Do not edit manually.

Open **https://gemini.google.com/saved-info**, enable **Your instructions for Gemini**, and add each block below as a separate entry.

> **Optional personal override:** Block 4 lets Gemini infer your country/currency automatically and ask when unclear. If you prefer a fixed regional default, replace Block 4 with a 1-line override such as:
> `Unless I specify otherwise, default to <Your Country/Region> (<Currency>, metric units) for legal, tax, labor, consumer, pricing, product availability, and regulatory context.`

---
EOF

  for core_file in "${CORE_DIR}"/*.md; do
    [ -f "$core_file" ] || continue
    title="$(humanize_core_name "$core_file")"
    echo ""
    echo "## ${title}"
    echo '```text'
    cat "$core_file"
    echo '```'
  done
} > "${SAVED_INFO_OUT}"

# ---------------------------------------------------------------------------
# 2. Generate web-exports/chatgpt-claude-preferences.md
# ---------------------------------------------------------------------------
WEB_PREFS_OUT="${OUT_DIR}/chatgpt-claude-preferences.md"

COMPACT_TEXT='Prioritize truth, clarity, and usefulness over politeness. Be direct, candid, and concise; challenge flawed premises and weak reasoning. Never present guesses as facts—distinguish confirmed facts, strong inference, weak inference, and opinion. Verify time-sensitive claims against primary sources and flag outdated evidence. No filler, flattery, or prompt echoing.
- Simple/factual queries: answer directly immediately.
- Complex/high-stakes decisions: prevent early anchoring—1) Key factors, trade-offs, risks & strongest counter-argument, 2) Verdict & recommendation (with confidence).
- On-demand "council"/"debate": analyze via Strategist, Pragmatist, and Skeptic/Red Team before a Chairman Verdict + verbatim Minority Report.
- Claims/media/behavior analysis: ground in natural, formal, or social sciences with real mechanisms; suppress theory on everyday practical tasks.
- Precision: never expand undefined private acronyms; no buzzword inflation or embellishing CVs/emails.
- Jurisdiction: infer country/currency/units from context; never silently default to U.S. norms—ask if material and unclear.
- Politics/economics/media: explicit anti-systemic, working-class materialist standpoint paired with strict empirical rigor; reject false balance/forced symmetry, neoclassical orthodoxy as neutral, and corporate media as verification; audit evasions, fallacies, and say-vs-do contradictions causing material harm.'

COMPACT_LEN=${#COMPACT_TEXT}
if [ "${COMPACT_LEN}" -gt 1500 ]; then
  echo "❌ Error: Compact ChatGPT profile exceeds 1500 characters (${COMPACT_LEN} chars)." >&2
  exit 1
fi

{
  cat << EOF
# Claude Web Preferences & ChatGPT Custom Instructions

> Auto-generated from \`core/*.md\` by \`scripts/build-web-exports.sh\`. Do not edit manually.

---

## Option A — Full Profile (Claude Web *Profile Preferences* / System Prompt)
Paste into **Claude → Settings → Profile → Personal Preferences**:

\`\`\`text
EOF
  for core_file in "${CORE_DIR}"/*.md; do
    [ -f "$core_file" ] || continue
    cat "$core_file"
    echo ""
  done
  cat << EOF
\`\`\`

---

## Option B — Compact Profile (ChatGPT *Custom Instructions* — ${COMPACT_LEN} / 1,500 chars)
Paste into **ChatGPT → Personalization → Custom Instructions**:

\`\`\`text
${COMPACT_TEXT}
\`\`\`
EOF
} > "${WEB_PREFS_OUT}"

# ---------------------------------------------------------------------------
# 3. Generate web-exports/gemini-gems/<skill>.md (1 per skill)
# ---------------------------------------------------------------------------
rm -f "${GEMS_DIR}"/*.md
gem_count=0
for skill_dir in "${SKILLS_DIR}"/*; do
  [ -d "$skill_dir" ] || continue
  skill_file="${skill_dir}/SKILL.md"
  [ -f "$skill_file" ] || continue

  skill_name="$(basename "$skill_dir")"
  gem_out="${GEMS_DIR}/${skill_name}.md"

  {
    cat << EOF
# Gem / Custom Assistant Prompt — \`${skill_name}\`

> Auto-generated from \`core/\` + \`skills/${skill_name}/SKILL.md\` by \`scripts/build-web-exports.sh\`.
> Paste the block below into a **Google Gemini Gem**, **Claude Project**, or **Custom GPT**.

\`\`\`markdown
## Core Epistemic & Context Baseline
EOF
    cat "${CORE_DIR}/01-epistemic-baseline.md"
    echo ""
    cat "${CORE_DIR}/04-jurisdiction-detection.md"
    echo ""
    strip_frontmatter "${skill_file}"
    echo '```'
  } > "${gem_out}"

  gem_count=$((gem_count + 1))
done

echo "✔ Generated web-exports/gemini-saved-info.md"
echo "✔ Generated web-exports/chatgpt-claude-preferences.md (compact: ${COMPACT_LEN}/1500 chars)"
echo "✔ Generated ${gem_count} Gem prompts in web-exports/gemini-gems/"
