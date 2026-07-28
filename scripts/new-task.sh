#!/usr/bin/env bash
# usage: ./scripts/new-task.sh T1.4 "Schema Renderer v1"
id="$1"; title="$2"
f=".oaim/tasks/${id}.md"
[ -e "$f" ] && { echo "exists: $f"; exit 1; }
sed -e "s/^id: .*/id: ${id}/" -e "s/^title: .*/title: ${title}/" \
    -e "s/^created: .*/created: $(date +%F)/" .oaim/tasks/_TEMPLATE.md > "$f"
echo "created $f"
