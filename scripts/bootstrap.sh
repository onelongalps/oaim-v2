#!/usr/bin/env bash
set -euo pipefail
# ============ 目录骨架 ============
mkdir -p .claude/{agents,commands}
mkdir -p .oaim/{state,tasks,reports}
mkdir -p .oaim/messagebox/{archive}
for a in planner architect designer developer reviewer tester ux-researcher challenger optimizer scribe; do
  mkdir -p ".oaim/messagebox/inbox/$a"
  touch ".oaim/messagebox/inbox/$a/.gitkeep"
done
mkdir -p docs
mkdir -p industry-packs/fnb/{skills,report-templates,fixtures}
mkdir -p apps/{web,agent-runtime,renderer}
mkdir -p packages/{schema,semantic,skills,connectors,ui}
mkdir -p supabase/{migrations,functions,tests/rls}
mkdir -p scripts
# ============ 校验脚本 ============
cat > scripts/verify-bootstrap.sh <<'EOF'
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
EOF
chmod +x scripts/verify-bootstrap.sh
# ============ 新任务脚本 ============
cat > scripts/new-task.sh <<'EOF'
#!/usr/bin/env bash
# usage: ./scripts/new-task.sh T1.4 "Schema Renderer v1"
id="$1"; title="$2"
f=".oaim/tasks/${id}.md"
[ -e "$f" ] && { echo "exists: $f"; exit 1; }
sed -e "s/^id: .*/id: ${id}/" -e "s/^title: .*/title: ${title}/" \
    -e "s/^created: .*/created: $(date +%F)/" .oaim/tasks/_TEMPLATE.md > "$f"
echo "created $f"
EOF
chmod +x scripts/new-task.sh
cat > .gitignore <<'EOF'
node_modules/
dist/
.env
.env.*
*.pem
.DS_Store
.oaim/messagebox/inbox/**/*.md
!.oaim/messagebox/inbox/**/.gitkeep
EOF
touch .oaim/state/{DECISIONS.md,RISKS.md}
echo "✅ 骨架完成，接下来跑 claude 让它按 docs/BOOTSTRAP.md 填内容"
