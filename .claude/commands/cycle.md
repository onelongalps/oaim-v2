---
description: 跑一轮完整开发流水线，自动推进 1 个任务从规格到验收
argument-hint: [任务ID，留空则自动从 BACKLOG 取下一个]
---
执行 OAIM 标准开发流水线。任务：$1（留空则由 scribe 推荐）

## 流水线（严格按序，不得跳步）
**0. 开工** — 用 scribe 子智能体输出开工简报。若存在 P0 阻塞消息，停止流水线并报告。
**1. 规格** — 用 planner 子智能体，写出/补全 `.oaim/tasks/{ID}.md`，status → spec
**2. 反驳** — 用 challenger 子智能体挑战该规格。
   - 判决 = 拒绝 → 回到步骤 1，最多循环 2 次；仍拒绝则标 blocked 并停止
   - 判决 = 有条件接受 → planner 修订后继续
   - status → challenged
**3. 契约**（仅当 type 涉及跨 package）— 用 architect 子智能体冻结契约，写入 packages/schema，任务文件填 contract_files
**4. 设计**（仅当 type=UI）— 用 designer 子智能体产出线框图/状态清单/i18n key，status → designed
**5. 实现** — 用 developer 子智能体实现，status → in_progress
**6. 审查** — 用 reviewer 子智能体审查。
   - FAIL → 回步骤 5，最多循环 3 次；仍 FAIL 则标 blocked
   - status → review
**7. 测试** — 用 tester 子智能体写测试并运行。
   - 有失败 → 回步骤 5
   - status → test
**8. 体验**（仅当 type=UI）— 用 ux-researcher 子智能体走查。
   - 阻塞级问题 → 回步骤 5
   - 严重/一般级 → 写入 BACKLOG 作为新任务
   - status → ux
**9. 优化** — 用 optimizer 子智能体产出建议（不实施），写入 BACKLOG
**10. 收工** — 用 scribe 子智能体归档：更新 PROGRESS/LESSONS/BACKLOG，归档消息，status → done

## 规则
- 每一步结束必须往 `.oaim/messagebox/inbox/{下一角色}/` 投递一条消息
- 每一步在任务文件的「流水线记录」表追加一行
- 任何一步产生 `type: blocker, priority: P0` 的消息，立即停止并向我报告
- 全程只推进这一个任务，不得顺手改别的文件
