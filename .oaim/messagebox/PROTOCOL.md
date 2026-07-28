# Messagebox 协议 v1.0

纯文件驱动的智能体消息总线。所有跨角色沟通必须落盘，便于审计与断点续跑。

## 路径
- 投递：`.oaim/messagebox/inbox/{接收者}/{MSG-ID}.md`
- 归档：`.oaim/messagebox/archive/{YYYY-MM}/{MSG-ID}.md`

## 消息格式
````markdown
---
id: MSG-20260729-0007
from: challenger
to: [planner]
cc: [architect]
type: rebuttal          # task_assign|spec|review|test_report|question|blocker|rebuttal|decision|handoff|done
task: T1.5
priority: P1            # P0 阻塞 | P1 本轮必须 | P2 可延后
status: open            # open|acked|resolved|rejected
requires_reply: true
created: 2026-07-29T14:20:00+08:00
---
## 结论
（一句话，先给结论）
## 依据
1. ...
2. ...
## 要求对方做的事
- [ ] 明确的动作项
## 若不采纳的后果
...
````

## 规则
1. **一条消息只谈一件事**，跨任务必须拆分
2. `type: blocker` 且 `priority: P0` 时，流水线暂停，主会话必须先处理
3. 接收方处理后：把 `status` 改为 `resolved` 或 `rejected`（rejected 必须写理由），然后移入 `archive/`
4. `requires_reply: true` 的消息，回复消息的 frontmatter 需加 `in_reply_to: {原ID}`
5. scribe 在每轮 cycle 结束时清空 inbox（归档）并统计未决消息数写入 PROGRESS.md
6. 任何 agent 只能写入 `.oaim/` 下的文件与自己职责范围内的代码目录

## ID 规则
`MSG-{YYYYMMDD}-{当日序号4位}`，序号由 `ls .oaim/messagebox/archive/ .oaim/messagebox/inbox/ -R | wc -l` 推算，冲突时递增。
