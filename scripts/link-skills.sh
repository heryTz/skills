#!/usr/bin/env bash
# Links all skills into ~/.claude/skills for local CLI use.
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$HOME/.claude/skills"

mkdir -p "$TARGET_DIR"

while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"

  # Skip deprecated and in-progress
  case "$skill_dir" in
    */deprecated/*|*/in-progress/*) continue ;;
  esac

  target="$TARGET_DIR/$skill_name"

  # Remove existing non-symlink
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi

  # Skip if already a symlink to the correct target
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill_dir" ]; then
    continue
  fi

  ln -sfn "$skill_dir" "$target"
  echo "Linked: $skill_name"
done < <(find "$SKILLS_DIR/skills" -name "SKILL.md" -not -path "*/node_modules/*")
