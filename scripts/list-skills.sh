#!/usr/bin/env bash
# Lists all registered skills with their categories.
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

find "$SKILLS_DIR/skills" -name "SKILL.md" -not -path "*/node_modules/*" | sort | while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  category="$(basename "$(dirname "$skill_dir")")"
  skill_name="$(basename "$skill_dir")"
  echo "[$category] $skill_name"
done
