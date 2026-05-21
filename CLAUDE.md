# Skills Repository

Skills are organized into bucket folders under `skills/`:

- `engineering/` — code-related work (form patterns, testing, tooling)
- `productivity/` — workflow optimization
- `misc/` — rarely-used or demo skills
- `in-progress/` — draft skills, not shared
- `deprecated/` — obsolete skills, not shared

Every skill in `engineering/`, `productivity/`, or `misc/` must appear in the root `README.md` and have an entry in `.claude-plugin/plugin.json`. Skills in `in-progress/` and `deprecated/` must not appear in either.

Each skill directory must contain a `SKILL.md` with `name` and `description` frontmatter.

Each bucket folder has a `README.md` listing its skills with one-line descriptions, with each skill name linked to its `SKILL.md`.

Additional reference files (e.g., `setup.md`, `patterns.md`) are placed alongside `SKILL.md` in the skill directory.
