#!/usr/bin/env bash
set -uo pipefail
fail=0
req=(
  CLAUDE.md
  .claude/settings.json
  .oaim/state/PROGRESS.md .oaim/state/BACKLOG.md .oaim/state/LESSONS.md
  .oaim/state/DECISIONS.md .oaim/state/RISKS.md
  .oaim/messagebox/PROTOCOL.md .oaim/tasks/_TEMPLATE.md
  docs/ARCHITECTURE.md docs/BOOTSTRAP.md
  industry-packs/fnb/pack.yaml industry-packs/fnb/baseline-schema.json
  industry-packs/fnb/metrics.yaml industry-packs/fnb/alert-rules.yaml
  industry-packs/fnb/glossary.yaml industry-packs/fnb/advice-kb.yaml
)
for f in "${req[@]}"; do [ -s "$f" ] || { echo "MISSING/EMPTY: $f"; fail=1; }; done
for a in planner architect designer developer reviewer tester ux-researcher challenger optimizer scribe; do
  [ -s ".claude/agents/$a.md" ] || { echo "MISSING AGENT: $a"; fail=1; }
done
for c in cycle task-new inbox standup retro; do
  [ -s ".claude/commands/$c.md" ] || { echo "MISSING CMD: $c"; fail=1; }
done
[ $fail -eq 0 ] && echo "✅ bootstrap OK" || echo "❌ bootstrap incomplete"
exit $fail
