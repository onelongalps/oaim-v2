---
description: 每日站会：昨天做了什么、今天做什么、有什么阻塞
---
用 scribe 子智能体生成站会纪要：
1. **已完成**：过去 24h 内 status 变为 done 的任务
2. **进行中**：在途任务及流水线位置，卡住超过 2 轮的标红
3. **阻塞**：所有 P0/P1 未决消息
4. **今日建议**：从 BACKLOG 取 depends_on 已满足的前 3 个任务
5. **风险**：LESSONS 中本周新增条目 + RISKS.md 中未缓解项
输出控制在 30 行内。写入 `.oaim/reports/standup-$(date +%F).md`
