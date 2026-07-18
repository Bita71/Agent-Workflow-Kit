#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

TARGET=""
COMPONENTS="core,claude,codex,cursor"
CHECK_COMMAND=""
BASE_REF="auto"
PROFILES="core"
RUNNER_PLAN_COMMAND="none"
RUNNER_EXEC_COMMAND="none"
RUNNER_CLEAN_COMMAND="none"
RUNNER_NETWORK_ALLOWED_DOMAINS="none"
APPLY=false

usage() {
  printf '%s\n' \
    "Usage: scripts/install.sh TARGET [options]" \
    "" \
    "Options:" \
    "  --components LIST     core,claude,codex,cursor,runner or all" \
    "  --check-command CMD    required for --apply; use none only for docs-only repos" \
    "  --base-ref REF         default: auto" \
    "  --profiles LIST        default: core" \
    "  --runner-plan CMD      command that prepares runner plans" \
    "  --runner-exec CMD      command that executes planned briefs" \
    "  --runner-clean CMD     command that cleans runner state" \
    "  --runner-domains LIST  comma-separated sandbox network domains or none" \
    "  --apply                write after a conflict-free dry-run" \
    "  -h, --help             show this help" \
    "" \
    "Without --apply the command is a read-only preview."
}

while (($#)); do
  case "$1" in
    --components)
      COMPONENTS="${2:-}"
      shift 2
      ;;
    --check-command)
      CHECK_COMMAND="${2:-}"
      shift 2
      ;;
    --base-ref)
      BASE_REF="${2:-}"
      shift 2
      ;;
    --profiles)
      PROFILES="${2:-}"
      shift 2
      ;;
    --runner-plan)
      RUNNER_PLAN_COMMAND="${2:-}"
      shift 2
      ;;
    --runner-exec)
      RUNNER_EXEC_COMMAND="${2:-}"
      shift 2
      ;;
    --runner-clean)
      RUNNER_CLEAN_COMMAND="${2:-}"
      shift 2
      ;;
    --runner-domains)
      RUNNER_NETWORK_ALLOWED_DOMAINS="${2:-}"
      shift 2
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$TARGET" ]]; then
        printf 'Only one target directory is allowed.\n' >&2
        exit 2
      fi
      TARGET="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  printf 'Target must be an existing directory: %s\n' "$TARGET" >&2
  exit 2
fi

TARGET="$(cd "$TARGET" && pwd -P)"
if [[ "$TARGET" == "$SOURCE_ROOT" ]]; then
  printf 'Refusing to install the kit over its own source checkout.\n' >&2
  exit 2
fi

for value in "$CHECK_COMMAND" "$BASE_REF" "$PROFILES" "$COMPONENTS" \
  "$RUNNER_PLAN_COMMAND" "$RUNNER_EXEC_COMMAND" "$RUNNER_CLEAN_COMMAND" \
  "$RUNNER_NETWORK_ALLOWED_DOMAINS"; do
  if [[ "$value" == *$'\n'* ]]; then
    printf 'Configuration values must be single-line.\n' >&2
    exit 2
  fi
done

if [[ "$COMPONENTS" == "all" ]]; then
  COMPONENTS="core,claude,codex,cursor,runner"
fi

case ",$COMPONENTS," in
  *,core,*) ;;
  *) COMPONENTS="core,$COMPONENTS" ;;
esac

case ",$PROFILES," in
  *,core,*) ;;
  *) PROFILES="core,$PROFILES" ;;
esac

IFS=',' read -r -a component_list <<< "$COMPONENTS"
for component in "${component_list[@]}"; do
  case "$component" in
    core|claude|codex|cursor|runner) ;;
    *)
      printf 'Unknown component: %s\n' "$component" >&2
      exit 2
      ;;
  esac
done

IFS=',' read -r -a requested_profiles <<< "$PROFILES"
for profile in "${requested_profiles[@]}"; do
  if [[ ! -f "$SOURCE_ROOT/docs/ai/profiles/$profile.md" ]]; then
    printf 'Unknown profile: %s\n' "$profile" >&2
    exit 2
  fi
done

if $APPLY && [[ -z "$CHECK_COMMAND" ]]; then
  printf -- '--check-command is required with --apply.\n' >&2
  exit 2
fi

has_component() {
  case ",$COMPONENTS," in
    *,$1,*) return 0 ;;
    *) return 1 ;;
  esac
}

if has_component runner; then
  for runner_value in "$RUNNER_PLAN_COMMAND" "$RUNNER_EXEC_COMMAND" "$RUNNER_CLEAN_COMMAND"; do
    if [[ -z "$runner_value" || "$runner_value" == "none" ]]; then
      printf -- '--runner-plan, --runner-exec, and --runner-clean are required with the runner component.\n' >&2
      exit 2
    fi
  done
  if [[ "$RUNNER_NETWORK_ALLOWED_DOMAINS" != "none" ]]; then
    IFS=',' read -r -a runner_domains <<< "$RUNNER_NETWORK_ALLOWED_DOMAINS"
    for domain in "${runner_domains[@]}"; do
      if [[ ! "$domain" =~ ^[A-Za-z0-9.*_-]+(:[0-9]+)?$ ]]; then
        printf 'Invalid runner domain: %s\n' "$domain" >&2
        exit 2
      fi
    done
  fi
fi

if [[ -z "$CHECK_COMMAND" ]]; then
  CHECK_COMMAND="CHANGE_ME"
fi

TOOLS=""
for tool in claude codex cursor; do
  if has_component "$tool"; then
    if [[ -n "$TOOLS" ]]; then
      TOOLS="$TOOLS,$tool"
    else
      TOOLS="$tool"
    fi
  fi
done
[[ -n "$TOOLS" ]] || TOOLS="none"

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/agent-workflow-kit-install.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT
CONFIG_SOURCE="$TEMP_DIR/config.conf"
SANDBOX_SOURCE="$TEMP_DIR/sandbox.settings.json"

{
  printf '%s\n' \
    '# Agent Workflow Kit configuration. Keep this file free of secrets.' \
    'CONFIG_VERSION=1' \
    'MODE=project' \
    "CHECK_COMMAND=$CHECK_COMMAND" \
    "BASE_REF=$BASE_REF" \
    "PROFILES=$PROFILES" \
    "TOOLS=$TOOLS" \
    'ARTIFACT_LANGUAGE=english' \
    'COMMIT_CONVENTION=conventional-commits' \
    'SHELL_FAMILY=bash-posix' \
    'DEPENDENCY_ECOSYSTEM=auto' \
    "RUNNER_PLAN_COMMAND=$RUNNER_PLAN_COMMAND" \
    "RUNNER_EXEC_COMMAND=$RUNNER_EXEC_COMMAND" \
    "RUNNER_CLEAN_COMMAND=$RUNNER_CLEAN_COMMAND" \
    "RUNNER_NETWORK_ALLOWED_DOMAINS=$RUNNER_NETWORK_ALLOWED_DOMAINS" \
    'PLANNER_MODEL=auto' \
    'BUILDER_MODEL=auto' \
    'CORRECTNESS_MODEL=auto' \
    'SECURITY_MODEL=auto' \
    'DESIGN_MODEL=auto' \
    'DEFAULT_EFFORT=high' \
    'CODEX_MAX_EFFORT=xhigh'
} > "$CONFIG_SOURCE"
chmod 0644 "$CONFIG_SOURCE"

if has_component runner; then
  {
    printf '%s\n' \
      '{' \
      '  "sandbox": {' \
      '    "enabled": true,' \
      '    "failIfUnavailable": true,' \
      '    "allowUnsandboxedCommands": false,' \
      '    "filesystem": {' \
      '      "allowWrite": ["./"],' \
      '      "denyRead": ["~/.ssh", "~/.aws", "~/.gnupg", "~/.config/gh"]' \
      '    },' \
      '    "network": {' \
      '      "allowedDomains": ['
    if [[ "$RUNNER_NETWORK_ALLOWED_DOMAINS" != "none" ]]; then
      IFS=',' read -r -a runner_domains <<< "$RUNNER_NETWORK_ALLOWED_DOMAINS"
      for ((domain_index=0; domain_index<${#runner_domains[@]}; domain_index++)); do
        suffix=','
        if ((domain_index == ${#runner_domains[@]} - 1)); then
          suffix=''
        fi
        printf '        "%s"%s\n' "${runner_domains[$domain_index]}" "$suffix"
      done
    fi
    printf '%s\n' \
      '      ]' \
      '    }' \
      '  }' \
      '}'
  } > "$SANDBOX_SOURCE"
  chmod 0644 "$SANDBOX_SOURCE"
fi

SOURCES=()
DESTINATIONS=()

add_file() {
  SOURCES+=("$1")
  DESTINATIONS+=("$2")
}

add_tree() {
  local source_dir="$1"
  local destination_dir="$2"
  local file relative
  while IFS= read -r file; do
    relative="${file#"$source_dir"/}"
    case "$file" in
      */.DS_Store) continue ;;
      */night-runner/sandbox.settings.json) continue ;;
      */docs/ai/plans/*) [[ "$relative" == */README.md ]] || continue ;;
      */docs/ai/reviews/*) [[ "$relative" == */README.md ]] || continue ;;
      */docs/ai/runs/*) [[ "$relative" == */README.md ]] || continue ;;
    esac
    add_file "$file" "$destination_dir/$relative"
  done < <(find "$source_dir" -type f | LC_ALL=C sort)
}

add_tree "$SOURCE_ROOT/docs/ai" "docs/ai"
add_file "$SOURCE_ROOT/MODEL_PRESETS.md" "MODEL_PRESETS.md"
add_file "$SOURCE_ROOT/LICENSE" ".agent-workflow-kit/LICENSE"
add_file "$SOURCE_ROOT/scripts/validate.sh" "scripts/agent-workflow-kit-validate.sh"
add_file "$CONFIG_SOURCE" ".agent-workflow-kit/config.conf"

if has_component claude; then
  add_file "$SOURCE_ROOT/CLAUDE.md" "CLAUDE.md"
  add_tree "$SOURCE_ROOT/.claude" ".claude"
fi

if has_component codex; then
  add_file "$SOURCE_ROOT/AGENTS.md" "AGENTS.md"
  add_tree "$SOURCE_ROOT/.agents" ".agents"
  add_tree "$SOURCE_ROOT/.codex" ".codex"
fi

if has_component cursor; then
  add_tree "$SOURCE_ROOT/.cursor" ".cursor"
fi

if has_component runner; then
  add_tree "$SOURCE_ROOT/night-runner" "night-runner"
  add_file "$SANDBOX_SOURCE" "night-runner/sandbox.settings.json"
fi

conflicts=0
creates=0
skips=0

for ((index=0; index<${#SOURCES[@]}; index++)); do
  source_file="${SOURCES[$index]}"
  destination_relative="${DESTINATIONS[$index]}"
  destination_file="$TARGET/$destination_relative"

  if [[ "$destination_relative" == ".agent-workflow-kit/config.conf" && -e "$destination_file" ]]; then
    printf 'SKIP_CONFIG %s (existing project values are preserved)\n' "$destination_relative"
    ((skips+=1))
  elif [[ -e "$destination_file" ]]; then
    if cmp -s "$source_file" "$destination_file"; then
      printf 'SKIP        %s\n' "$destination_relative"
      ((skips+=1))
    else
      printf 'CONFLICT    %s\n' "$destination_relative"
      ((conflicts+=1))
    fi
  else
    printf 'CREATE      %s\n' "$destination_relative"
    ((creates+=1))
  fi
done

GITIGNORE_ENTRIES=(
  'night-runner/briefs/new/'
  'night-runner/briefs/planned/'
  'night-runner/briefs/in-progress/'
  'night-runner/briefs/done/'
  'night-runner/briefs/manual-review/'
  'night-runner/logs/'
  '.claude/settings.local.json'
)

missing_gitignore=0
for entry in "${GITIGNORE_ENTRIES[@]}"; do
  if [[ ! -f "$TARGET/.gitignore" ]] || ! grep -Fqx "$entry" "$TARGET/.gitignore"; then
    ((missing_gitignore+=1))
  fi
done
if ((missing_gitignore > 0)); then
  printf 'APPEND      .gitignore (%d missing entries)\n' "$missing_gitignore"
fi

printf '\nSummary: create=%d skip=%d conflict=%d\n' "$creates" "$skips" "$conflicts"

if ((conflicts > 0)); then
  printf 'No files were written. Merge or remove conflicts, then rerun.\n' >&2
  exit 1
fi

if ! $APPLY; then
  printf 'Dry-run only. Re-run with --apply after reviewing the list.\n'
  exit 0
fi

for ((index=0; index<${#SOURCES[@]}; index++)); do
  source_file="${SOURCES[$index]}"
  destination_relative="${DESTINATIONS[$index]}"
  destination_file="$TARGET/$destination_relative"
  if [[ -e "$destination_file" ]]; then
    continue
  fi
  mkdir -p "$(dirname "$destination_file")"
  cp -p "$source_file" "$destination_file"
done

if ((missing_gitignore > 0)); then
  {
    printf '\n# Agent Workflow Kit local state\n'
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
      if [[ ! -f "$TARGET/.gitignore" ]] || ! grep -Fqx "$entry" "$TARGET/.gitignore"; then
        printf '%s\n' "$entry"
      fi
    done
  } >> "$TARGET/.gitignore"
fi

printf 'Installation applied. Next: %s\n' "$TARGET/scripts/agent-workflow-kit-validate.sh"
