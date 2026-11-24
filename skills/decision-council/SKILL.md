---
name: decision-council
description: Use when facing high-stakes personal, financial, career, housing, or strategic decisions with competing trade-offs, or when the user asks to convene a council, multi-perspective debate, or adversarial second opinion.
---

# Multi-Perspective Decision Council Workflow

Run a structured, adversarial deliberation to eliminate blind spots, early autoregressive anchoring, and sycophancy before committing to high-stakes non-coding decisions.

---

## Pre-Flight: Anti-Theater Gate
Convene a council **only** for decisions with meaningful cost, irreversibility, or real competing options (e.g., housing/mortgage choices, career moves, major purchases, relocations, strategic life or business choices).
- Do **not** convene a council for simple factual lookups or low-stakes everyday questions—answer directly.

---

## Execution Mode Selection
- **Mode A — Parallel Subagent Council (Preferred)**: When subagent spawning is available (e.g., Antigravity `invoke_subagent` with read-only `research` subagents, or Claude Code parallel `Agent`/`Task` subagents), dispatch all panelists **concurrently in a single turn** so initial stances are strictly independent.
- **Mode B — Sequential Multi-Lens Fallback**: When subagent tools are unavailable, execute Phases 1–3 sequentially in strictly separated sections, completing all three lenses **before** synthesizing any conclusion.

---

## Phase 1: Framing & Independent Lenses
1. Frame the exact **Decision Question**, hard constraints (budget, timeline, risk tolerance, jurisdiction), and concrete options.
2. Analyze through **3 independent adversarial/complementary lenses** (add a 4th domain lens—e.g., Legal or Health—only if warranted):
   - **The Strategist** (*Long-Term Upside & Alignment*): Evaluates multi-year trajectory, opportunity cost, reversibility, and alignment with the user's real goals.
   - **The Pragmatist** (*Simplicity, Friction & Real Cost*): Evaluates total cost, hidden effort, operational friction, and the simplest viable path that solves the actual need.
   - **The Skeptic / Red Team** (*Failure Modes & Hidden Risks*): Actively tries to break every option—hunting for worst-case scenarios, lock-in, counterparty incentives, optimism bias, and unstated assumptions.
3. Keep each lens tight (≤ 200 words): **Position**, **Key Evidence**, **Top 2 Risks**, and **Dealbreaker**.

---

## Phase 2: Blind Cross-Examination *(Mode A or high-stakes decisions)*
1. Anonymize Phase 1 memos as **Proposal A**, **Proposal B**, and **Proposal C**.
2. Run **1 cross-examination round** where each panelist identifies:
   - The strongest valid point in another proposal they initially missed.
   - Unverified assumptions or blind spots in competing proposals.
   - Whether they **Hold** or **Revise** their position based on new evidence.

---

## Phase 3: Chairman Verdict & Minority Report
Reconcile the debate without flattening real disagreements into vague *"it depends"* compromises:
- **Reject False Balance**: Never fabricate symmetric pros/cons to make a weak option look competitive; reflect real asymmetry in risk and cost.
- **No Early Anchoring**: Derive the verdict strictly from the evidence surfaced in Phases 1–2.

Deliver in GitHub Markdown:
1. **Executive Verdict**: Recommended path + confidence level (`High` | `Medium` | `Low — More Data Needed`).
2. **Points of Consensus**: Findings independently confirmed across lenses.
3. **Trade-off Matrix**: Concrete comparison of what is gained vs. sacrificed.
4. **Minority Report (Strongest Dissent)**: Preserve the sharpest counter-argument from the Skeptic verbatim so the user weighs the real residual risk.
5. **Pre-Conditions & Verification Steps**: Concrete checks, quotes, or data to verify before committing.
