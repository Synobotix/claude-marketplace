#!/usr/bin/env bash
# Gate runner — deterministic quality enforcement
# Called by the Stop hook. Never calls a model. Exit 0 = pass, exit 2 = hard stop.

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$PWD}"
GATE_CONFIG="$PROJECT_ROOT/gates.config"
QUARANTINE="$PROJECT_ROOT/.quarantine"
GATE_TYPE="${GATE_TYPE:-code}"

# No gates.config = pass silently (project hasn't configured gates yet)
if [[ ! -f "$GATE_CONFIG" ]]; then
  echo "[gate] No gates.config found — skipping gate (add one to enforce quality)"
  exit 0
fi

read_config() {
  local key="$1"
  grep "^${key}=" "$GATE_CONFIG" 2>/dev/null | cut -d= -f2- || echo ""
}

fail_gate() {
  local reason="$1"
  echo "[gate] FAIL: $reason"
  echo "[gate] Artifact quarantined — check .quarantine/"
  mkdir -p "$QUARANTINE"
  exit 2
}

run_code_gate() {
  local compile_cmd test_cmd lint_cmd
  compile_cmd=$(read_config compile)
  test_cmd=$(read_config test)
  lint_cmd=$(read_config lint)

  if [[ -n "$compile_cmd" ]]; then
    echo "[gate:code] compile: $compile_cmd"
    eval "$compile_cmd" || fail_gate "compile step failed"
  fi

  if [[ -n "$test_cmd" ]]; then
    echo "[gate:code] test: $test_cmd"
    eval "$test_cmd" || fail_gate "test step failed"
  fi

  if [[ -n "$lint_cmd" ]]; then
    echo "[gate:code] lint: $lint_cmd"
    eval "$lint_cmd" || fail_gate "lint step failed"
  fi
}

run_doc_gate() {
  local doc_dir="$PROJECT_ROOT/docs"

  # Block on unresolved source markers in docs
  if grep -r '\[SOURCE_NEEDED\]' "$doc_dir" 2>/dev/null | grep -q .; then
    fail_gate "unresolved [SOURCE_NEEDED] markers found in docs/"
  fi

  # Terminology check against glossary
  local glossary="$PROJECT_ROOT/spec/glossary.md"
  if [[ -f "$glossary" ]]; then
    echo "[gate:doc] glossary check: $glossary (manual review recommended)"
  fi

  echo "[gate:doc] PASS"
}

run_article_gate() {
  local article_dir="$PROJECT_ROOT/articles"

  # Hard block: any SOURCE_NEEDED marker = gate fail
  local count
  count=$(grep -r '\[SOURCE_NEEDED\]' "$article_dir" 2>/dev/null | wc -l || echo "0")

  if [[ "$count" -gt 0 ]]; then
    echo "[gate:article] Found $count unsourced claim(s):"
    grep -rn '\[SOURCE_NEEDED\]' "$article_dir" 2>/dev/null | head -20
    fail_gate "$count [SOURCE_NEEDED] marker(s) must be resolved before publication"
  fi

  echo "[gate:article] PASS — no unsourced claims"
}

case "$GATE_TYPE" in
  code)    run_code_gate ;;
  doc)     run_doc_gate ;;
  article) run_article_gate ;;
  *)
    echo "[gate] Unknown GATE_TYPE '$GATE_TYPE' — skipping"
    exit 0
    ;;
esac

echo "[gate] PASS — $GATE_TYPE gate"
exit 0
