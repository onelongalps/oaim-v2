# OAIM — 智能体驱动的中小企业管理平台

## 一句话
商家用对话搭建专属后台（Builder），再雇一支数字员工团队（Admin/Ops/Analytics/Growth/Sales）经营它。

## 每次会话必读
1. `.oaim/state/PROGRESS.md` — 当前阶段与在途任务
2. `.oaim/state/LESSONS.md` — 已踩过的坑，禁止重犯
3. `docs/ARCHITECTURE.md` — 架构与契约
4. 检查 `.oaim/messagebox/inbox/` 是否有未处理消息

## 六条架构铁律（违反视为严重缺陷）
- D1 搭建产物是 **App Schema (JSON)**，不生成代码仓库
- D2 预览 = Schema Renderer + iframe 热更新，不用真沙箱
- D3 Builder 沉淀的 Entity 元数据 = 管理智能体的数据认知来源
- D4 智能体**永不直接写 SQL**，只能经 `packages/semantic`
- D5 多智能体用 Supervisor + 任务队列，不用自由群聊
- D6 **LLM Gateway 必须先于任何 AI 功能上线**

## 工程红线
1. 双语硬性：新增 UI 文案必须同步 `apps/web/src/i18n/locales/{en,zh}`
2. 新表必须有 `tenant_id` + RLS 策略 + RLS 测试；无 RLS 测试不允许合并
3. 任何密钥不得出现在代码或提交中，一律走 Secrets/Vault
4. 所有 `DELETE` 一律 soft delete
5. 涉及金额/库存的写操作必须返回确认卡片，用户点击才执行
6. 单次对话 tool call 上限 15
7. 阶段 N 的任务不得提前引入阶段 N+1 依赖
8. 改 `packages/schema` 必须同步 `docs/APP_SCHEMA_SPEC.md` 并升版本号

## 工作制度
- 一次只推进一个任务文件 `.oaim/tasks/T*.md`，完成前不开新任务
- 每个任务必须走完流水线（见 `.claude/commands/cycle.md`），不得跳过 challenger 与 tester
- 每完成一个任务：更新 PROGRESS.md，若有新认知写入 LESSONS.md
- 所有跨角色沟通走 `.oaim/messagebox/`，不要在主对话里口头传递

## 首个行业
餐饮（F&B），行业包在 `industry-packs/fnb/`。其他行业一律不做。

## 技术栈
前端 Vite+React+TS / wouter / Tailwind + shadcn / i18next
后端 Supabase(Postgres+Auth+Storage) + Node/Hono agent-runtime
向量 pgvector · 队列 阶段2 用 pg_cron+表，阶段4 换 Redis Stream
