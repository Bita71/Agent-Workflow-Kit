#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
CONFIG="$ROOT/.agent-workflow-kit/config.conf"
RELEASE=false
ACK_GIT_IDENTITY=false

for argument in "$@"; do
  case "$argument" in
    --release) RELEASE=true ;;
    --acknowledge-git-identity) ACK_GIT_IDENTITY=true ;;
    -h|--help)
      printf '%s\n' \
        'Usage: scripts/agent-workflow-kit-validate.sh [--release] [--acknowledge-git-identity]' \
        'Source checkout: scripts/validate.sh [options]'
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$argument" >&2
      exit 2
      ;;
  esac
done

failures=0
warnings=0

pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; ((warnings+=1)); }
fail() { printf 'FAIL  %s\n' "$1" >&2; ((failures+=1)); }

config_value() {
  local key="$1"
  sed -n "s/^${key}=//p" "$CONFIG" | sed -n '1p'
}

require_file() {
  if [[ -f "$ROOT/$1" ]]; then
    pass "$1 exists"
  else
    fail "$1 is missing"
  fi
}

if [[ ! -f "$CONFIG" ]]; then
  printf 'FAIL  .agent-workflow-kit/config.conf is missing\n' >&2
  exit 1
fi

MODE="$(config_value MODE)"
CHECK_COMMAND="$(config_value CHECK_COMMAND)"
BASE_REF="$(config_value BASE_REF)"
PROFILES="$(config_value PROFILES)"
TOOLS="$(config_value TOOLS)"
SHELL_FAMILY="$(config_value SHELL_FAMILY)"
DEPENDENCY_ECOSYSTEM="$(config_value DEPENDENCY_ECOSYSTEM)"
RUNNER_PLAN_COMMAND="$(config_value RUNNER_PLAN_COMMAND)"
RUNNER_EXEC_COMMAND="$(config_value RUNNER_EXEC_COMMAND)"
RUNNER_CLEAN_COMMAND="$(config_value RUNNER_CLEAN_COMMAND)"
RUNNER_NETWORK_ALLOWED_DOMAINS="$(config_value RUNNER_NETWORK_ALLOWED_DOMAINS)"

[[ "$(config_value CONFIG_VERSION)" == "1" ]] || fail 'CONFIG_VERSION must be 1'
[[ "$MODE" == "template" || "$MODE" == "project" ]] || fail 'MODE must be template or project'

if [[ "$MODE" == "project" && ( -z "$CHECK_COMMAND" || "$CHECK_COMMAND" == "none" || "$CHECK_COMMAND" == "CHANGE_ME" ) ]]; then
  fail 'CHECK_COMMAND must be configured for a project install'
else
  pass 'CHECK_COMMAND is resolved for the selected mode'
fi

if [[ "$SHELL_FAMILY" == "bash-posix" ]]; then
  pass 'SHELL_FAMILY declares Bash with a POSIX userland'
else
  fail 'Only SHELL_FAMILY=bash-posix is currently supported'
fi

[[ -n "$DEPENDENCY_ECOSYSTEM" ]] || fail 'DEPENDENCY_ECOSYSTEM must be configured'
[[ -n "$RUNNER_NETWORK_ALLOWED_DOMAINS" ]] || fail 'RUNNER_NETWORK_ALLOWED_DOMAINS must be configured'

model_config_failed=false
for model_key in PLANNER_MODEL BUILDER_MODEL CORRECTNESS_MODEL SECURITY_MODEL \
  DESIGN_MODEL BALANCED_MODEL LONG_RUN_MODEL MECHANICAL_MODEL; do
  if [[ -z "$(config_value "$model_key")" ]]; then
    fail "$model_key must be configured or set to auto"
    model_config_failed=true
  fi
done
if ! $model_config_failed; then
  pass 'model preferences are centralized and complete'
fi

if [[ "$MODE" == "project" && -d "$ROOT/night-runner" ]]; then
  for runner_key in RUNNER_PLAN_COMMAND RUNNER_EXEC_COMMAND RUNNER_CLEAN_COMMAND; do
    runner_value="$(config_value "$runner_key")"
    if [[ -z "$runner_value" || "$runner_value" == "none" || "$runner_value" == "CHANGE_ME" ]]; then
      fail "$runner_key must be configured when the runner component is installed"
    fi
  done
  require_file 'night-runner/sandbox.settings.json'
fi

case ",$PROFILES," in
  *,core,*) pass 'core profile is active' ;;
  *) fail 'PROFILES must include core' ;;
esac

IFS=',' read -r -a profile_list <<< "$PROFILES"
for profile in "${profile_list[@]}"; do
  [[ -n "$profile" ]] || continue
  require_file "docs/ai/profiles/$profile.md"
done

require_file 'docs/ai/setup.md'
require_file 'docs/ai/rules/project.md'
require_file 'docs/ai/rules/coding-rules.md'

case ",$TOOLS," in
  *,claude,*)
    require_file 'CLAUDE.md'
    require_file '.claude/agents/review-design.md'
    ;;
esac
case ",$TOOLS," in
  *,codex,*)
    require_file 'AGENTS.md'
    require_file '.agents/skills/skill-build/SKILL.md'
    require_file '.codex/agents/codex-plan.toml'
    require_file '.codex/agents/review-correctness.toml'
    require_file '.codex/agents/review-design.toml'
    require_file '.codex/agents/review-security.toml'
    ;;
esac
case ",$TOOLS," in
  *,cursor,*)
    require_file '.cursor/rules/main.mdc'
    require_file '.cursor/agents/build.md'
    require_file '.cursor/agents/review-design.md'
    ;;
esac

if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ "$BASE_REF" == "auto" ]]; then
    resolved_ref="$(git -C "$ROOT" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
    if [[ -z "$resolved_ref" ]]; then
      resolved_ref="$(git -C "$ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    fi
    if [[ -n "$resolved_ref" ]]; then
      pass "BASE_REF=auto resolves to $resolved_ref"
    else
      fail 'BASE_REF=auto could not resolve a branch'
    fi
  elif git -C "$ROOT" rev-parse --verify "$BASE_REF^{commit}" >/dev/null 2>&1; then
    pass "BASE_REF resolves to $BASE_REF"
  else
    fail "BASE_REF does not resolve: $BASE_REF"
  fi
else
  warn 'Git repository checks skipped'
fi

for required_command in bash awk sed grep find cmp cp mkdir mktemp; do
  if command -v "$required_command" >/dev/null 2>&1; then
    pass "command available: $required_command"
  else
    fail "required Bash/POSIX command is missing: $required_command"
  fi
done

if bash -n "${BASH_SOURCE[0]}"; then
  pass 'validator shell syntax'
else
  fail 'validator shell syntax'
fi
if [[ -f "$ROOT/scripts/install.sh" ]]; then
  if bash -n "$ROOT/scripts/install.sh"; then
    pass 'installer shell syntax'
  else
    fail 'installer shell syntax'
  fi
fi

left_marker='<<<<''<<<'
middle_marker='====''==='
right_marker='>>>>''>>>'
conflict_file=""
identity_file=""
secret_file=""
model_file=""
reference_file=""

while IFS= read -r file; do
  relative="${file#"$ROOT"/}"
  generated_artifact=false
  case "$relative" in
    .git/*)
      continue
      ;;
    docs/ai/plans/*.plan.md|docs/ai/reviews/*.review.md|docs/ai/runs/*.symphony.md)
      generated_artifact=true
      ;;
  esac
  if ! grep -Iq . "$file" 2>/dev/null; then
    continue
  fi
  if grep -Eq "^($left_marker|$middle_marker|$right_marker)" "$file"; then
    conflict_file="$relative"
  fi
  if grep -Eiq '(/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})' "$file"; then
    identity_file="$relative"
  fi
  if grep -Eq '(BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})' "$file"; then
    secret_file="$relative"
  fi
  if [[ "$relative" != '.agent-workflow-kit/config.conf' ]] && grep -Eiq '(gpt-[0-9]|claude-[a-z0-9-]*[0-9])' "$file"; then
    model_file="$relative"
  fi
  if ! $generated_artifact; then
    while IFS= read -r reference; do
      case "$reference" in
        docs/ai/plans/YYYY-MM-DD-*|docs/ai/reviews/YYYY-MM-DD-*|docs/ai/runs/YYYY-MM-DD-*)
          continue
          ;;
      esac
      if [[ ! -e "$ROOT/$reference" ]]; then
        reference_file="$relative -> $reference"
      fi
    done < <(grep -Eo 'docs/ai/[A-Za-z0-9._/-]+\.md' "$file" | LC_ALL=C sort -u || true)
  fi
done < <(find "$ROOT" -type f ! -path "$ROOT/.git/*" | LC_ALL=C sort)

[[ -z "$conflict_file" ]] && pass 'no merge-conflict markers' || fail "merge-conflict marker in $conflict_file"
[[ -z "$identity_file" ]] && pass 'no personal path/email patterns in kit files' || fail "personal path/email pattern in $identity_file"
[[ -z "$secret_file" ]] && pass 'no high-confidence credential patterns' || fail "credential-like pattern in $secret_file"
[[ -z "$model_file" ]] && pass 'model IDs are centralized in config' || fail "hardcoded model ID outside config in $model_file"
[[ -z "$reference_file" ]] && pass 'rooted docs/ai references resolve' || fail "broken docs/ai reference: $reference_file"

codex_contract_failed=false
for agent_file in codex-plan.toml review-correctness.toml review-design.toml review-security.toml; do
  if [[ -f "$ROOT/.codex/agents/$agent_file" ]] && \
     ! grep -Eq '^sandbox_mode = "read-only"$' "$ROOT/.codex/agents/$agent_file"; then
    fail ".codex/agents/$agent_file must declare sandbox_mode=read-only"
    codex_contract_failed=true
  fi
done

if grep -REn 'write (it|the (plan|review|artifact)).*docs/ai/(plans|reviews)' "$ROOT/.codex/agents" >/dev/null 2>&1; then
  fail 'read-only Codex agent is instructed to write a repository artifact'
  codex_contract_failed=true
elif ! $codex_contract_failed; then
  pass 'Codex agents are read-only and return output to the caller'
else
  warn 'Codex caller contract has failures above'
fi

if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$ROOT" diff --check -- .agent-workflow-kit docs/ai AGENTS.md CLAUDE.md .agents .claude .codex .cursor MODEL_PRESETS.md README.md scripts >/dev/null; then
    pass 'git diff whitespace check'
  else
    fail 'git diff whitespace check'
  fi
fi

if $RELEASE; then
  printf '\nGit identity review:\n'
  if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$ROOT" log --format='%an <%ae>' --all | LC_ALL=C sort -u
    git -C "$ROOT" remote -v || true
    if $ACK_GIT_IDENTITY; then
      pass 'Git authors/remotes explicitly reviewed'
    else
      fail 'rerun --release with --acknowledge-git-identity after reviewing the output'
    fi
  else
    warn 'release Git identity review skipped outside a Git repository'
  fi
fi

printf '\nValidation summary: failures=%d warnings=%d\n' "$failures" "$warnings"
((failures == 0))
