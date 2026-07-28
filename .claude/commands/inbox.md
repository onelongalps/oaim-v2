---
description: 查看并处理消息盒中的未决消息
---
1. 列出 `.oaim/messagebox/inbox/**/*.md` 中 status: open 的消息，按 priority 排序
2. 输出表格：ID / from → to / type / task / priority / 一句话摘要
3. 对每条 P0：调用对应接收角色的子智能体处理，处理后更新 status 并归档
4. 对 P1/P2：询问我是否本轮处理
5. 结束时输出剩余未决数
