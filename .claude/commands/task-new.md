---
description: 从模板新建一个任务文件
argument-hint: <任务ID> <标题>  例如 T1.4 "Schema Renderer v1"
---
从 `.oaim/tasks/_TEMPLATE.md` 创建一个新任务文件。任务：$ARGUMENTS

## 步骤
1. 解析参数：第一个 token 为任务 ID（形如 `T1.4`），其余为标题
2. 若 `.oaim/tasks/{ID}.md` 已存在 → 停止并报告，不覆盖
3. 优先运行脚本创建：`bash scripts/new-task.sh {ID} "{标题}"`
   - 脚本会复制模板并回填 `id` / `title` / `created`
4. 打开生成的任务文件，按 planner 的职责补全「目标 / Done looks like / 范围 / 非目标」
5. 输出：新任务文件路径 + 建议的 depends_on + 下一步（通常交给 /cycle）

## 规则
- 只创建任务文件，不开始实现
- ID 必须符合 `T{阶段}.{序号}` 规范，且属于当前或已解锁阶段
- 新任务默认 status: draft，验收标准留待 planner 在 /cycle 中冻结
