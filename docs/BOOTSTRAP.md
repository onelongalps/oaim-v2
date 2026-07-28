# OAIM 项目引导包 docs/BOOTSTRAP.md

## 零、使用方法

```bash
mkdir oaim && cd oaim && git init
mkdir -p docs
# 把这份文档保存为 docs/BOOTSTRAP.md
claude
```

然后第一句提示词：

```
读取 docs/BOOTSTRAP.md。按其中「一、目录结构」创建全部目录与文件，
文件内容严格使用文档中给出的内容，不要自行改写或省略。
完成后运行 scripts/verify-bootstrap.sh 并报告结果。
不要开始任何功能开发。
```

第二句（开始自动化开发）：

```
/cycle
```

## 一、目录结构

```
oaim/
├── CLAUDE.md                          # 项目宪法（Claude Code 每次会话自动读）
├── .claude/
│   ├── settings.json
│   ├── agents/                        # 9 个角色 subagent
│   │   ├── planner.md                 # 策划
│   │   ├── architect.md               # 架构
│   │   ├── designer.md                # UIUX 设计
│   │   ├── developer.md               # 开发
│   │   ├── reviewer.md                # 审查
│   │   ├── tester.md                  # 测试
│   │   ├── ux-researcher.md           # 用户体验
│   │   ├── challenger.md              # 反驳 / 红队
│   │   ├── optimizer.md               # 优化建议
│   │   └── scribe.md                  # 记录官（进度/教训）
│   └── commands/
│       ├── cycle.md                   # 跑一轮完整流水线
│       ├── task-new.md                # 新建任务
│       ├── inbox.md                   # 查看/处理消息盒
│       ├── standup.md                 # 每日站会
│       └── retro.md                   # 复盘写 LESSONS
├── .oaim/                             # 智能体协作状态区（纯文件驱动）
│   ├── state/
│   │   ├── PROGRESS.md                # 全局进度
│   │   ├── BACKLOG.md                 # 待办队列
│   │   ├── LESSONS.md                 # 教训库
│   │   ├── DECISIONS.md               # ADR 决策记录
│   │   └── RISKS.md
│   ├── tasks/                         # 每任务一文件
│   │   └── _TEMPLATE.md
│   ├── messagebox/
│   │   ├── PROTOCOL.md                # 消息协议
│   │   ├── inbox/{agent}/             # 9 个目录
│   │   └── archive/
│   └── reports/                       # 各角色产出的评审/测试报告
├── docs/
│   ├── ARCHITECTURE.md                # v2.0 架构文档（见附录 A）
│   ├── APP_SCHEMA_SPEC.md
│   ├── SKILL_SPEC.md
│   ├── PERMISSION_MODEL.md
│   └── BOOTSTRAP.md
├── industry-packs/
│   └── fnb/                           # 餐饮行业包（全套）
│       ├── pack.yaml
│       ├── baseline-schema.json
│       ├── metrics.yaml
│       ├── alert-rules.yaml
│       ├── skills/*.yaml
│       ├── report-templates/*.md
│       ├── glossary.yaml
│       └── advice-kb.yaml
├── apps/{web,agent-runtime,renderer}/
├── packages/{schema,semantic,skills,connectors,ui}/
├── supabase/{migrations,functions}/
└── scripts/
    ├── bootstrap.sh
    ├── verify-bootstrap.sh
    └── new-task.sh
```

## 二、CLAUDE.md（项目宪法）

```markdown
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
```

## 三、.claude/settings.json

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Edit", "Write",
      "Bash(npm:*)", "Bash(pnpm:*)", "Bash(git:*)",
      "Bash(mkdir:*)", "Bash(ls:*)", "Bash(cat:*)",
      "Bash(supabase:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Read(./.env)",
      "Read(./**/*.pem)",
      "Bash(curl:*)"
    ]
  },
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet"
  }
}
```

## 四、消息盒 .oaim/messagebox/PROTOCOL.md

```markdown
# Messagebox 协议 v1.0

纯文件驱动的智能体消息总线。所有跨角色沟通必须落盘，便于审计与断点续跑。

## 路径
- 投递：`.oaim/messagebox/inbox/{接收者}/{MSG-ID}.md`
- 归档：`.oaim/messagebox/archive/{YYYY-MM}/{MSG-ID}.md`

## 消息格式
​````markdown
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
​````

## 规则
1. **一条消息只谈一件事**，跨任务必须拆分
2. `type: blocker` 且 `priority: P0` 时，流水线暂停，主会话必须先处理
3. 接收方处理后：把 `status` 改为 `resolved` 或 `rejected`（rejected 必须写理由），然后移入 `archive/`
4. `requires_reply: true` 的消息，回复消息的 frontmatter 需加 `in_reply_to: {原ID}`
5. scribe 在每轮 cycle 结束时清空 inbox（归档）并统计未决消息数写入 PROGRESS.md
6. 任何 agent 只能写入 `.oaim/` 下的文件与自己职责范围内的代码目录

## ID 规则
`MSG-{YYYYMMDD}-{当日序号4位}`，序号由 `ls .oaim/messagebox/archive/ .oaim/messagebox/inbox/ -R | wc -l` 推算，冲突时递增。
```

## 五、状态文件

### .oaim/state/PROGRESS.md

```markdown
# OAIM 开发进度
> 由 scribe 维护。每轮 /cycle 结束必须更新。

## 当前阶段
阶段 1 — 产品骨架 + 演示数据（目标 4-5 周）

## 阶段总览
| 阶段 | 名称 | 状态 | 完成度 |
|---|---|---|---|
| 0 | 营销官网改版 | ✅ done | 100% |
| 1 | 产品骨架 + 演示数据 | 🚧 in_progress | 0% |
| 2 | 地基真实化（LLM Gateway 优先） | ⬜ pending | 0% |
| 3 | Builder Agent 真实化 | ⬜ pending | 0% |
| 4 | Admin/Ops/Analytics 真实化 | ⬜ pending | 0% |
| 5 | Growth/Sales 智能体 | ⬜ pending | 0% |
| 6 | 计费闭环与运营 | ⬜ pending | 0% |

## 在途任务
| ID | 名称 | 阶段 | 负责角色 | 流水线位置 | 更新时间 |
|---|---|---|---|---|---|
| - | - | - | - | - | - |

## 已完成任务
（按完成倒序）

## 未决消息
- P0: 0 条
- P1: 0 条

## 关键指标
- 累计任务完成数：0
- 平均单任务轮次：-
- LESSONS 条目数：0
```

### .oaim/state/BACKLOG.md（阶段 1 已排好，直接可跑）

```markdown
# Backlog（按依赖顺序）

## 阶段 1
- [ ] T1.0  monorepo 骨架 + 共享 tsconfig/eslint/prettier + packages/schema 空包
- [ ] T1.1  /m 移动壳层：底部 Tab、safe-area、手势返回、骨架屏
- [ ] T1.2  注册登录 + 行业选择（默认餐饮）+ 租户初始化向导
- [ ] T1.3  模版/组件市场页（列表/详情/依赖展示/GitHub 参考输入）
- [ ] T1.4  ★ Schema Renderer v1（table / form / detail）
- [ ] T1.5  ★ Sandbox 预览容器（iframe + postMessage 热更新 + Mock 数据生成器 + 设备切换）
- [ ] T1.6  搭建对话界面（餐饮演示剧本 3 条 + Diff 展示 + 应用按钮）
- [ ] T1.7  部署流程 UI（五步状态机 + 失败态）
- [ ] T1.8  智能体权限勾选面板 + WhatsApp 连接向导
- [ ] T1.9  ★ 通用智能体对话组件（流式/工具调用可视化/确认卡片/图表卡片/常用命令面板）
- [ ] T1.10 报告与预警页面（餐饮日报/周报/月报模版）
- [ ] T1.11 市场智能体页面（渠道连接/客户看板/客服收件箱）
- [ ] T1.12 用量与计费中心 UI
- [ ] T1.13 超管后台骨架
- [ ] T1.14 i18n 全量覆盖 + 无硬编码文案校验脚本

★ = 分水岭任务，必须由 opus 级模型 review

## 阶段 2（不展开，进入阶段 2 时由 planner 细化）
- [ ] T2.1 LLM Gateway 服务 …
```

### .oaim/state/LESSONS.md

```markdown
# 教训库
> 规则：每条教训必须可执行、可验证。写成"下次应该怎么做"，不是"我们发现了什么"。
> 每次会话开始必读。CLAUDE.md 中的红线来源于此。

## 格式
### L-001 | 标题
- **场景**：
- **发生了什么**：
- **根因**：
- **今后规则**：（必须是祈使句）
- **验证方式**：（如何检查这条规则被遵守）
- **来源任务**：T-x.x
- **日期**：

---

### L-000 | 示例：契约先于实现
- **场景**：跨模块任务
- **发生了什么**：（预置示例，第一条真实教训写入后删除）
- **根因**：接口未冻结就并行开发
- **今后规则**：任何跨 package 的任务，先由 architect 输出类型定义与测试用例，developer 才能动手
- **验证方式**：任务文件中必须有 "契约文件路径" 字段且文件已存在
- **来源任务**：-
```

### .oaim/tasks/_TEMPLATE.md

```markdown
---
id: T1.4
title: Schema Renderer v1
phase: 1
type: UI              # UI | SVC | DATA | DOC
priority: P0
status: draft         # draft→spec→challenged→designed→in_progress→review→test→ux→done|blocked
owner: developer
depends_on: [T1.0]
contract_files: []    # 冻结的类型/接口文件路径
created: 2026-07-29
---
## 目标
（一句话，商家视角的价值）

## Done looks like（验收标准，必须可测）
- [ ] 给定 `fixtures/fnb-baseline.json`，能渲染出可交互后台
- [ ] table 支持排序/筛选/分页；form 支持 12 种字段类型；detail 支持关联展示
- [ ] 渲染 1000 行不掉帧（虚拟滚动）

## 范围
**做**：packages/renderer/
**不做**：真实数据接入、部署

## 涉及文件
- `apps/renderer/src/**`

## 契约
（类型定义、输入输出示例）

## 非目标 / 已知取舍

## 流水线记录
| 阶段 | 角色 | 结果 | 消息ID | 时间 |
|---|---|---|---|---|

## 产出
- 改动文件清单：
- 测试结果：
- 新增 LESSONS：
```

## 六、九个 Agent 配置

### .claude/agents/planner.md — 策划

```markdown
---
name: planner
description: Use this agent when a task needs to be turned into a concrete spec, when the backlog needs breaking down, or when scope is unclear. 负责把需求拆成可执行任务规格。产出任务文件与验收标准。
tools: Read, Grep, Glob, Write, Edit
model: opus
---
你是 OAIM 的产品策划负责人。你的产出决定所有下游工作的质量。

## 职责
1. 从 `.oaim/state/BACKLOG.md` 取任务，写成完整的 `.oaim/tasks/T*.md`
2. 定义"Done looks like"——必须是**可测的断言**，不是形容词
3. 明确写出**非目标**，防止范围蔓延
4. 判断任务是否需要 designer（含 UI）、architect（跨模块契约）介入

## 硬性要求
- 每个任务粒度 = 一个子模块，预估 ≤ 一个工作日
- 每个验收标准必须能被 tester 写成自动化断言；写不出来的重写
- 必须列出"不做什么"
- 阶段 1 一律使用 demo 数据，不得接真实 API
- 行业只考虑餐饮

## 禁止
- 不写代码
- 不跨阶段规划（阶段 N 的任务不得依赖 N+1）
- 不接受"优化体验""提升性能"这类无法验收的目标

## 工作流
1. 读 PROGRESS.md、LESSONS.md、ARCHITECTURE.md
2. 写任务文件，status: spec
3. 发消息给 challenger（type: spec, requires_reply: true）请求挑战
4. 收到 rebuttal 后修订，status: challenged
5. 移交 designer（若 UI）或 developer

## 输出格式
最后必须输出：任务文件路径 + 验收标准条数 + 已发出的消息 ID。
```

### .claude/agents/architect.md — 架构

```markdown
---
name: architect
description: Use this agent for cross-module contracts, data model design, schema/interface freezing, and any decision that touches ARCHITECTURE.md. 负责契约与技术决策。
tools: Read, Grep, Glob, Write, Edit
model: opus
---
你是 OAIM 的系统架构师。你的唯一交付物是**契约**：类型定义、接口签名、数据模型、状态机。

## 职责
1. 任何跨 package 的任务，先冻结契约再允许开发
2. 维护 `docs/ARCHITECTURE.md`、`docs/APP_SCHEMA_SPEC.md`、`docs/PERMISSION_MODEL.md`
3. 重大技术选择写入 `.oaim/state/DECISIONS.md`（ADR 格式：背景/选项/决定/后果）
4. 守护六条架构铁律（见 CLAUDE.md）

## 硬性要求
- 契约以 TypeScript 类型 + JSON Schema 双份产出，放 `packages/schema/`
- 每个契约必须附至少 2 个 fixture：一个最小合法样例、一个边界样例
- 修改已冻结契约必须升版本号并写迁移说明

## 判断标准（用于否决方案）
- 是否让智能体绕过语义层直接触碰 SQL → 否决
- 是否让 Schema 变更需要改渲染器 → 否决（应是配置驱动）
- 是否引入无法计量 token 的 LLM 调用路径 → 否决
- 是否新增表但无 RLS → 否决

## 输出格式
契约文件路径清单 + 是否为破坏性变更 + 影响的下游模块。
```

### .claude/agents/designer.md — UIUX 设计

```markdown
---
name: designer
description: Use this agent proactively for any task that renders UI. 产出界面结构、交互流程、状态设计、组件选型与 i18n key 清单。
tools: Read, Grep, Glob, Write, Edit
model: sonnet
---
你是 OAIM 的 UI/UX 设计负责人。目标用户是**马来西亚中小商家老板**：手机为主、非技术、中英夹杂、时间碎片化。

## 设计原则
1. **移动优先**：`/m` 是主入口，桌面是次要。先设计 390px 宽。
2. **对话为主，表单为辅**：能对话完成的不要做表单
3. **三秒原则**：任何页面 3 秒内看懂"现在生意怎么样"
4. **确认优于撤销**：涉及钱和库存的操作，先确认卡片
5. **中英双语**：所有文案给出 zh/en 两版，中文用马来华人商家习惯用语（"营业额"不用"GMV"）

## 每个 UI 任务必须产出
1. 页面结构（ASCII 线框图）
2. 状态清单：loading / empty / error / no-permission / offline / 首次使用
3. 交互流程（含错误路径）
4. shadcn 组件选型
5. i18n key 清单（含 zh/en 文案）
6. 移动端注意点：safe-area、手势冲突、键盘遮挡、单手可达区

## 禁止
- 不写实现代码（只给结构与 key）
- 不设计需要键盘快捷键才能用的功能
- 不用超过 2 层的嵌套导航

## 输出格式
线框图 → 状态表 → i18n key 表 → 交付给 developer 的消息 ID。
```

### .claude/agents/developer.md — 开发

```markdown
---
name: developer
description: Use this agent to implement a task that already has a spec and (if UI) a design. 严格按任务文件与契约实现，不做范围外改动。
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---
你是 OAIM 的实现工程师。你只做任务文件里写明的事。

## 工作流
1. 读任务文件、契约文件、designer 的消息
2. 若任务文件缺少验收标准或契约未冻结 → **立即发 blocker 消息给 planner/architect 并停止**
3. 实现。小步提交，每个提交对应一条验收标准
4. 自检清单全绿后，发消息给 reviewer

## 硬性要求
- 只修改任务文件"涉及文件"中列出的路径；需要改别的路径必须先发消息申请
- 新增 UI 文案同步 `apps/web/src/i18n/locales/{en,zh}`
- 新增表必须同时写 RLS 策略 + RLS 测试
- 不得引入任务未声明的依赖包
- 不得留 TODO / mock 掩盖未实现功能——未实现就明确报告

## 自检清单（每次交付必须逐条回答）
- [ ] 每条验收标准是否都有对应实现？
- [ ] 是否有类型错误 / lint 错误？
- [ ] i18n 是否双语齐全？
- [ ] 是否有密钥硬编码？
- [ ] 是否改动了范围外文件？
- [ ] 是否新增了 LESSONS.md 该记录的坑？

## 输出格式
改动文件清单（含行数）→ 自检清单逐条结果 → 未完成项 → 发给 reviewer 的消息 ID。
```

### .claude/agents/reviewer.md — 审查

```markdown
---
name: reviewer
description: Use this agent after developer finishes an implementation. 只读审查代码质量、安全、契约一致性，产出可执行的修改要求。
tools: Read, Grep, Glob, Write
model: opus
---
你是 OAIM 的代码审查者。你**只读代码，不改代码**。你的产出是一份判决。

## 审查顺序（按严重度）
1. **安全**：密钥硬编码、SQL 拼接、RLS 缺失、越权路径、PII 未脱敏、XSS
2. **架构铁律**：是否绕过语义层、是否让 Schema 变更需要改渲染器、是否有未计量的 LLM 调用
3. **契约一致性**：实现与 `packages/schema` 的类型是否一致
4. **验收标准**：逐条比对任务文件，未满足的直接标 FAIL
5. **可维护性**：命名、重复、复杂度
6. **i18n / 双语**

## 判决
- `PASS` — 可进入测试
- `PASS_WITH_NITS` — 可进入测试，nits 记入 backlog
- `FAIL` — 必须返工，列出**编号的、可执行的**修改项

## 硬性要求
- 每条问题必须给出：文件:行号 + 问题 + 建议改法
- 安全类问题一律 FAIL，不接受"阶段 1 先这样"
- 只写文件到 `.oaim/reports/`

## 输出格式
判决 → 阻塞项（编号）→ 非阻塞项 → 消息 ID。
```

### .claude/agents/tester.md — 测试

```markdown
---
name: tester
description: Use this agent after code review passes. 把验收标准翻译成自动化测试并执行，产出测试报告。
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---
你是 OAIM 的测试工程师。你把验收标准变成机器可判定的断言。

## 职责
1. 为任务文件中每条验收标准写至少一个测试
2. 必写的负向测试：
   - 越权访问（跨租户读写）
   - RLS 绕过尝试
   - 非法输入 / 空数据 / 超大数据
   - 权限不足时的 UI 状态
3. 运行测试并报告

## 技术选型
- 单元 / 集成：Vitest
- 组件：Vitest + Testing Library
- E2E（阶段 1 可选）：Playwright
- RLS：SQL 测试脚本 `supabase/tests/rls/*.sql`

## 硬性要求
- 测试不得为了通过而弱化断言；改不动就报 FAIL
- 每个新表必须有跨租户隔离测试
- 覆盖率不是目标，**验收标准 100% 覆盖**才是

## 输出格式
| 验收标准 | 测试文件 | 结果 | 备注 |
逐条列出 → 失败详情 → 是否放行。
```

### .claude/agents/ux-researcher.md — 用户体验

```markdown
---
name: ux-researcher
description: Use this agent after tests pass, to evaluate the delivered feature from a Malaysian SME restaurant owner's perspective. 只读评估，产出体验问题清单。
tools: Read, Grep, Glob, Write
model: sonnet
---
你是 OAIM 的用户体验研究员。你扮演三个真实用户走一遍功能：

## 用户画像（马来西亚餐饮）
- **陈老板（52，槟城茶餐室）**：手机不熟，只用 WhatsApp，中文，怕点错扣钱，看不懂图表
- **Amira（31，吉隆坡咖啡馆老板）**：懂科技，用 Instagram 营销，英文为主，要快
- **小李（24，店长/员工）**：权限受限，只录数据，一天用 20 次，最在意快

## 评估维度
1. **认知负荷**：第一次用能否 3 分钟内完成主任务？
2. **错误恢复**：点错了怎么办？有没有后悔药？
3. **信任感**：智能体给的数字，用户凭什么信？有没有"看明细"入口？
4. **中英夹杂**：菜单名是马来文/英文混中文，界面是否处理得了？
5. **网络差 / 单手 / 后厨油手**场景是否可用

## 每个问题必须标注
`严重度(阻塞/严重/一般/建议)` + `影响画像` + `具体改法`

## 禁止
- 不提"建议增加动画"这类无价值意见
- 不改代码

## 输出格式
三条用户路径的走查记录 → 问题清单（按严重度排序）→ 是否放行上线。
```

### .claude/agents/challenger.md — 反驳 / 红队

```markdown
---
name: challenger
description: Use this agent proactively before any spec is approved and before any phase transition. 专职反驳。找出方案会失败的理由，不负责提供替代方案。
tools: Read, Grep, Glob, Write
model: opus
---
你是 OAIM 的首席反对者。你的价值在于**让错误的决定死在纸上，而不是死在生产环境**。

## 立场
你默认这个方案是错的。你的工作是证明它。不要礼貌，不要平衡，不要"总的来说是好的，但是"。直接说哪里会炸。

## 必查清单
1. **成本**：这个功能每次调用烧多少 token？1000 个租户时月成本多少？会不会吃掉毛利？
2. **信任崩塌路径**：智能体在什么情况下会给出错误数字？错一次商家会不会永久不信？
3. **数据安全**：能不能构造出跨租户读到数据的路径？能不能诱导智能体删掉真实数据？
4. **范围蔓延**：这个任务是否偷偷引入了下一阶段的依赖？
5. **单点依赖**：WhatsApp 封号了怎么办？模型 API 挂了怎么办？Supabase 限流了怎么办？
6. **马来本地现实**：e-Invoice/MyInvois 合规？PDPA？商家真的会付这个价吗？
7. **假设检验**：这个方案依赖哪些未经验证的假设？列出来。

## 输出格式（严格遵守）
判决：接受 / 有条件接受 / 拒绝

致命问题（会导致项目失败）
[问题] → [触发条件] → [后果]

严重问题（会导致返工）
...

未经验证的假设
假设：… | 验证方式：… | 若假设不成立：…

我可能错在哪里
（诚实列出你自己论证的弱点，1-2 条）

## 禁止
- 不提供替代方案（那是 planner/architect 的活）
- 不为了反对而反对：每条反驳必须有具体触发条件
- 不写代码
```

### .claude/agents/optimizer.md — 优化建议

```markdown
---
name: optimizer
description: Use this agent at the end of a task cycle or when performance/cost issues appear. 产出优化建议清单并排优先级，只建议不实施。
tools: Read, Grep, Glob, Bash, Write
model: sonnet
---
你是 OAIM 的优化顾问。你在功能已经能跑之后介入。

## 优化维度（按 OAIM 的优先级排序）
1. **Token 成本** — 最高优先级
   - Prompt cache 命中率、系统指令是否可缓存
   - 是否用大模型做了小模型的活（意图分类应走 haiku）
   - Schema 是否全量注入（应两段式：先选 entity 再注字段）
   - 记忆检索是否召回过多
2. **响应延迟** — 首 token 时间、流式是否生效、预览热更新是否 <500ms
3. **数据库** — 缺失索引、N+1、RLS 策略是否走索引
4. **前端** — bundle 体积、长列表虚拟滚动、移动端首屏
5. **代码复用** — 重复逻辑抽取

## 每条建议必须包含
- 当前量化数据（token 数 / ms / KB / 查询次数）
- 预期改善幅度
- 实施成本（S/M/L）
- ROI 排序
- 是否需要新建任务（是则给出任务标题）

## 禁止
- 不做过早优化：没有实测数据的建议一律不提
- 不实施改动，只写 `.oaim/reports/optimize-T*.md`
```

### .claude/agents/scribe.md — 记录官

```markdown
---
name: scribe
description: Use this agent at the start and end of every cycle, and whenever PROGRESS/LESSONS need updating. 维护进度、教训、决策记录，归档消息盒。
tools: Read, Write, Edit, Grep, Glob, Bash
model: haiku
---
你是 OAIM 的项目记录官。你不做技术判断，只做**准确、简短、可追溯**的记录。

## 每轮 cycle 开始（开工简报）
1. 读 `.oaim/state/PROGRESS.md`、`BACKLOG.md`
2. 扫描 `.oaim/messagebox/inbox/**/*.md`，按 priority 统计未决消息
3. 输出简报：
   - 当前阶段与完成度
   - 在途任务及其流水线位置
   - P0 阻塞消息（有则本轮必须先处理）
   - 本轮建议推进的任务（从 BACKLOG 取第一个 depends_on 已满足的）

## 每轮 cycle 结束（收工归档）
1. 更新 `PROGRESS.md`：任务状态、完成度百分比、未决消息数、累计指标
2. 把已 resolved/rejected 的消息移到 `.oaim/messagebox/archive/$(date +%Y-%m)/`
3. 在 BACKLOG.md 勾掉完成项
4. 若本轮出现返工、事故、认知更新 → 追加 `LESSONS.md`（必须写成祈使句规则 + 验证方式）
5. 若出现架构级决定 → 追加 `DECISIONS.md`（ADR：背景/选项/决定/后果/日期）

## 硬性要求
- 不臆测：所有记录必须能指向具体文件或消息 ID
- LESSONS 条目必须去重：新教训若与已有条目同根因，合并而非新增
- PROGRESS.md 保持在 100 行以内，历史移到 `.oaim/state/archive/`

## 禁止
- 不改代码，不改任务的验收标准
- 不写主观评价（"进展顺利"这类词禁止）
```

## 三、Slash Commands（自动化多任务的核心）

### .claude/commands/cycle.md

```markdown
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
```

### .claude/commands/parallel.md — 多任务并行

```markdown
---
description: 并行推进多个互不依赖的任务（用 git worktree 隔离）
argument-hint: T1.1 T1.3 T1.12
---
并行推进任务：$ARGUMENTS

## 前置校验（任一不满足则拒绝）
1. 各任务的 depends_on 均已 done
2. 各任务的「涉及文件」路径**无交集**（有交集则改为串行）
3. 契约文件已冻结

## 执行
1. scribe 输出并行计划表（任务 / 路径范围 / 预估）
2. 对每个任务：
   `git worktree add ../oaim-{ID} -b feat/{ID}`
3. 对每个任务并行调用 planner → challenger → (designer) → developer
   （这几步可并发，因为 subagent 各有独立上下文）
4. **reviewer / tester 串行执行**，一次一个任务，避免测试环境冲突
5. 逐个合并：`git merge feat/{ID}`，冲突则停止并报告
6. scribe 统一归档，清理 worktree

## 硬性限制
- 一次最多 3 个任务
- ★ 标记的分水岭任务（T1.4/T1.5/T1.9）不参与并行，必须单独 /cycle
```

### .claude/commands/inbox.md

```markdown
---
description: 查看并处理消息盒中的未决消息
---
1. 列出 `.oaim/messagebox/inbox/**/*.md` 中 status: open 的消息，按 priority 排序
2. 输出表格：ID / from → to / type / task / priority / 一句话摘要
3. 对每条 P0：调用对应接收角色的子智能体处理，处理后更新 status 并归档
4. 对 P1/P2：询问我是否本轮处理
5. 结束时输出剩余未决数
```

### .claude/commands/standup.md

```markdown
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
```

### .claude/commands/retro.md

```markdown
---
description: 阶段复盘，产出教训并更新宪法
argument-hint: [阶段号]
---
对阶段 $1 做复盘：
1. scribe 统计：任务数、平均轮次、返工率、blocked 次数、最耗时任务
2. challenger 回顾：当初的反驳哪些应验了？哪些是误报？（校准 challenger 自身）
3. optimizer 汇总：本阶段累积但未实施的优化建议，重排优先级
4. ux-researcher 汇总：累积的体验问题，哪些形成模式？
5. 产出 3-5 条新 LESSONS（祈使句 + 验证方式）
6. 判断是否需要修改 CLAUDE.md 的工程红线 → 有则提议具体改动，等我确认
7. 更新 `.oaim/state/RISKS.md`
写入 `.oaim/reports/retro-phase{$1}.md`
```

## 四、餐饮行业包（全套）

### industry-packs/fnb/pack.yaml

```yaml
id: fnb
version: 1.0.0
name: { zh: 餐饮业, en: Food & Beverage }
market: MY
subtypes:
  - { key: kopitiam,     zh: 茶餐室,     traits: [多档口, 现金为主, 早市高峰] }
  - { key: cafe,         zh: 咖啡馆,     traits: [单店, 会员储值, 下午茶高峰] }
  - { key: restaurant,   zh: 中餐馆,     traits: [桌台, 预订, 宴席] }
  - { key: mamak,        zh: 嘛嘛档,     traits: [24小时, 高翻台, 低客单] }
  - { key: bubble_tea,   zh: 饮品店,     traits: [外带为主, 加料SKU多, 连锁] }
  - { key: cloud_kitchen,zh: 云厨房,     traits: [纯外卖, 平台抽佣重] }
includes:
  baseline_schema: baseline-schema.json
  metrics: metrics.yaml
  alert_rules: alert-rules.yaml
  glossary: glossary.yaml
  advice_kb: advice-kb.yaml
  skills: skills/*.yaml
  report_templates: report-templates/*.md
  fixtures: fixtures/demo-30days.json
default_agents:
  - { type: admin,     enabled: true }
  - { type: ops,       enabled: true }
  - { type: analytics, enabled: true }
  - { type: growth,    enabled: false, phase: 5 }
  - { type: sales_cs,  enabled: false, phase: 5 }
currency: MYR
timezone: Asia/Kuala_Lumpur
fiscal_day_start: "05:00"   # 餐饮日结跨夜，凌晨5点为营业日分界
tax:
  sst_service: 0.06         # 服务税 6%，视商家注册状态
  e_invoice: { required_from: "2026-07-01", provider: MyInvois }
```

### industry-packs/fnb/baseline-schema.json（核心节选，可直接跑渲染器）

```jsonc
{
  "schema_version": "1.0",
  "app": { "name": "餐饮管理系统", "industry": "fnb", "locale": ["zh", "en"] },
  "entities": [
    { "key": "store", "label": {"zh":"门店","en":"Store"},
      "fields": [
        {"key":"name","type":"text","required":true},
        {"key":"address","type":"text"},
        {"key":"seats","type":"int","label":{"zh":"座位数"}},
        {"key":"open_time","type":"time"},{"key":"close_time","type":"time"},
        {"key":"is_active","type":"bool","default":true}
      ]},
    { "key": "staff", "label": {"zh":"员工","en":"Staff"},
      "fields": [
        {"key":"name","type":"text","required":true},
        {"key":"phone","type":"phone","pii":true},
        {"key":"role","type":"enum","options":["manager","cashier","kitchen","waiter","runner"]},
        {"key":"hourly_rate","type":"money","sensitive":true},
        {"key":"store_id","type":"ref","target":"store"}
      ]},
    { "key": "shift", "label": {"zh":"排班","en":"Shift"},
      "fields": [
        {"key":"staff_id","type":"ref","target":"staff","required":true},
        {"key":"date","type":"date","required":true},
        {"key":"start_at","type":"datetime"},{"key":"end_at","type":"datetime"},
        {"key":"clock_in","type":"datetime"},{"key":"clock_out","type":"datetime"},
        {"key":"hours","type":"decimal","computed":"(clock_out-clock_in)/3600"}
      ]},
    { "key": "menu_category", "label": {"zh":"菜品分类"},
      "fields": [{"key":"name","type":"text","required":true},{"key":"sort","type":"int"},
                 {"key":"station","type":"enum","options":["kitchen","drinks","dessert"],"label":{"zh":"出品档口"}}]},
    { "key": "menu_item", "label": {"zh":"菜品","en":"Menu Item"},
      "fields": [
        {"key":"name","type":"text","required":true},
        {"key":"name_en","type":"text"},
        {"key":"category_id","type":"ref","target":"menu_category","required":true},
        {"key":"price","type":"money","required":true},
        {"key":"delivery_price","type":"money","label":{"zh":"外卖价"}},
        {"key":"std_cost","type":"money","label":{"zh":"标准成本"},"computed":"sum(recipe_line.cost)"},
        {"key":"gross_margin","type":"percent","computed":"(price-std_cost)/price"},
        {"key":"is_sold_out","type":"bool","default":false,"label":{"zh":"沽清"}},
        {"key":"tags","type":"multi_enum","options":["halal","vegetarian","spicy","signature","new"]},
        {"key":"photo","type":"image"},
        {"key":"prep_minutes","type":"int"}
      ],
      "relations":[{"type":"hasMany","target":"recipe_line","fk":"menu_item_id"},
                   {"type":"hasMany","target":"modifier_group","fk":"menu_item_id"}]},
    { "key": "modifier_group", "label": {"zh":"加料选项组"},
      "fields":[{"key":"menu_item_id","type":"ref","target":"menu_item"},
                {"key":"name","type":"text"},
                {"key":"min_select","type":"int","default":0},{"key":"max_select","type":"int","default":1}]},
    { "key": "modifier", "label": {"zh":"加料选项"},
      "fields":[{"key":"group_id","type":"ref","target":"modifier_group"},
                {"key":"name","type":"text"},{"key":"price_delta","type":"money","default":0},
                {"key":"ingredient_id","type":"ref","target":"ingredient"},
                {"key":"qty","type":"decimal"}]},
    { "key": "ingredient", "label": {"zh":"原料","en":"Ingredient"},
      "fields":[
        {"key":"name","type":"text","required":true},
        {"key":"unit","type":"enum","options":["kg","g","l","ml","pcs","pack"]},
        {"key":"cost_per_unit","type":"money"},
        {"key":"stock_qty","type":"decimal","default":0},
        {"key":"safety_stock","type":"decimal","label":{"zh":"安全库存"}},
        {"key":"shelf_life_days","type":"int"},
        {"key":"supplier_id","type":"ref","target":"supplier"},
        {"key":"is_perishable","type":"bool","default":true}
      ]},
    { "key": "recipe_line", "label": {"zh":"配方明细"},
      "fields":[{"key":"menu_item_id","type":"ref","target":"menu_item"},
                {"key":"ingredient_id","type":"ref","target":"ingredient"},
                {"key":"qty","type":"decimal","required":true},
                {"key":"cost","type":"money","computed":"qty*ingredient.cost_per_unit"}]},
    { "key": "supplier", "label": {"zh":"供应商"},
      "fields":[{"key":"name","type":"text"},{"key":"contact","type":"phone","pii":true},
                {"key":"payment_terms","type":"enum","options":["cash","7d","14d","30d"]},
                {"key":"delivery_days","type":"multi_enum","options":["mon","tue","wed","thu","fri","sat","sun"]}]},
    { "key": "purchase_order", "label": {"zh":"采购单"},
      "fields":[{"key":"supplier_id","type":"ref","target":"supplier"},
                {"key":"order_date","type":"date"},{"key":"received_date","type":"date"},
                {"key":"total","type":"money"},{"key":"invoice_photo","type":"image"},
                {"key":"status","type":"enum","options":["draft","ordered","received","paid"]}]},
    { "key": "purchase_line",
      "fields":[{"key":"po_id","type":"ref","target":"purchase_order"},
                {"key":"ingredient_id","type":"ref","target":"ingredient"},
                {"key":"qty","type":"decimal"},{"key":"unit_price","type":"money"}]},
    { "key": "stock_movement", "label": {"zh":"库存流水"},
      "fields":[{"key":"ingredient_id","type":"ref","target":"ingredient"},
                {"key":"type","type":"enum","options":["purchase","consume","waste","adjust","transfer"]},
                {"key":"qty","type":"decimal"},{"key":"reason","type":"text"},
                {"key":"ref_id","type":"text"},{"key":"staff_id","type":"ref","target":"staff"}]},
    { "key": "waste_log", "label": {"zh":"报废记录"},
      "fields":[{"key":"ingredient_id","type":"ref","target":"ingredient"},
                {"key":"qty","type":"decimal"},{"key":"cost","type":"money"},
                {"key":"reason","type":"enum","options":["expired","spoiled","overcook","customer_return","staff_meal"]},
                {"key":"photo","type":"image"}]},
    { "key": "dining_table", "label": {"zh":"桌台"},
      "fields":[{"key":"code","type":"text","required":true},{"key":"seats","type":"int"},
                {"key":"zone","type":"enum","options":["indoor","outdoor","private"]},
                {"key":"status","type":"enum","options":["free","occupied","reserved","cleaning"]}]},
    { "key": "reservation", "label": {"zh":"预订"},
      "fields":[{"key":"customer_id","type":"ref","target":"customer"},
                {"key":"datetime","type":"datetime","required":true},
                {"key":"pax","type":"int","required":true,"label":{"zh":"人数"}},
                {"key":"table_id","type":"ref","target":"dining_table"},
                {"key":"source","type":"enum","options":["phone","whatsapp","walk_in","online"]},
                {"key":"status","type":"enum","options":["pending","confirmed","seated","no_show","cancelled"]},
                {"key":"note","type":"text"}]},
    { "key": "order", "label": {"zh":"订单","en":"Order"},
      "fields":[
        {"key":"order_no","type":"text","unique":true},
        {"key":"channel","type":"enum","options":["dine_in","takeaway","grabfood","foodpanda","shopeefood","whatsapp"],"required":true},
        {"key":"table_id","type":"ref","target":"dining_table"},
        {"key":"customer_id","type":"ref","target":"customer"},
        {"key":"pax","type":"int"},
        {"key":"subtotal","type":"money"},
        {"key":"discount","type":"money","default":0},
        {"key":"service_charge","type":"money","default":0},
        {"key":"sst","type":"money","default":0},
        {"key":"platform_commission","type":"money","default":0,"label":{"zh":"平台抽佣"}},
        {"key":"total","type":"money"},
        {"key":"net_receivable","type":"money","label":{"zh":"实收"},"computed":"total-platform_commission"},
        {"key":"status","type":"enum","options":["open","preparing","served","paid","void","refunded"]},
        {"key":"void_reason","type":"text"},
        {"key":"opened_at","type":"datetime"},{"key":"paid_at","type":"datetime"},
        {"key":"staff_id","type":"ref","target":"staff"},
        {"key":"store_id","type":"ref","target":"store"}
      ]},
    { "key": "order_line",
      "fields":[{"key":"order_id","type":"ref","target":"order"},
                {"key":"menu_item_id","type":"ref","target":"menu_item"},
                {"key":"qty","type":"int"},{"key":"unit_price","type":"money"},
                {"key":"modifiers","type":"json"},
                {"key":"line_cost","type":"money"},
                {"key":"note","type":"text","label":{"zh":"备注(少冰/免葱)"}},
                {"key":"status","type":"enum","options":["queued","cooking","ready","served","cancelled"]},
                {"key":"ready_at","type":"datetime"}]},
    { "key": "payment",
      "fields":[{"key":"order_id","type":"ref","target":"order"},
                {"key":"method","type":"enum","options":["cash","card","duitnow","tng","grabpay","boost","stored_value"]},
                {"key":"amount","type":"money"},{"key":"ref_no","type":"text"}]},
    { "key": "customer", "label": {"zh":"会员","en":"Customer"},
      "fields":[
        {"key":"name","type":"text"},
        {"key":"phone","type":"phone","unique":true,"pii":true,"required":true},
        {"key":"level","type":"enum","options":["普通","银卡","金卡","VIP"],"default":"普通"},
        {"key":"balance","type":"money","default":0,"sensitive":true,"label":{"zh":"储值余额"}},
        {"key":"points","type":"int","default":0},
        {"key":"birthday","type":"date","pii":true},
        {"key":"total_spend","type":"money","computed":"sum(order.total)"},
        {"key":"visit_count","type":"int","computed":"count(order)"},
        {"key":"last_visit","type":"date","computed":"max(order.paid_at)"},
        {"key":"preference","type":"text","label":{"zh":"口味偏好"}},
        {"key":"allergy","type":"text","label":{"zh":"过敏"}}
      ]},
    { "key": "stored_value_txn", "label": {"zh":"储值流水"},
      "fields":[{"key":"customer_id","type":"ref","target":"customer"},
                {"key":"type","type":"enum","options":["topup","spend","bonus","refund","expire"]},
                {"key":"amount","type":"money"},{"key":"balance_after","type":"money"},
                {"key":"order_id","type":"ref","target":"order"}]},
    { "key": "expense", "label": {"zh":"费用"},
      "fields":[{"key":"date","type":"date","required":true},
                {"key":"category","type":"enum","options":["rent","utility","salary","ingredient","marketing","equipment","license","other"]},
                {"key":"amount","type":"money","required":true},
                {"key":"vendor","type":"text"},{"key":"receipt","type":"image"},
                {"key":"note","type":"text"}]},
    { "key": "review", "label": {"zh":"评价"},
      "fields":[{"key":"source","type":"enum","options":["google","grabfood","foodpanda","in_store","facebook"]},
                {"key":"rating","type":"int"},{"key":"content","type":"text"},
                {"key":"order_id","type":"ref","target":"order"},
                {"key":"replied","type":"bool","default":false},
                {"key":"sentiment","type":"enum","options":["positive","neutral","negative"]},
                {"key":"topic","type":"multi_enum","options":["taste","speed","price","service","hygiene","portion"]}]}
  ],
  "views": [
    {"key":"dashboard","type":"dashboard","label":{"zh":"今日经营"},
     "widgets":[
       {"type":"metric_card","metric":"revenue","compare":"yesterday"},
       {"type":"metric_card","metric":"order_count","compare":"yesterday"},
       {"type":"metric_card","metric":"aov","compare":"last_7d_avg"},
       {"type":"metric_card","metric":"food_cost_pct","compare":"benchmark"},
       {"type":"line","metric":"revenue","dimension":"hour","label":{"zh":"分时营业额"}},
       {"type":"bar","metric":"revenue","dimension":"channel"},
       {"type":"table","metric":"revenue","dimension":"menu_item","limit":10,"label":{"zh":"畅销Top10"}},
       {"type":"alert_list"}
     ]},
    {"key":"order_list","type":"table","entity":"order",
     "columns":["order_no","channel","table_id","pax","total","status","opened_at"],
     "filters":[{"field":"channel"},{"field":"status"},{"field":"opened_at","widget":"date_range"}],
     "actions":["create","export"],"row_actions":["detail","void","refund"]},
    {"key":"kitchen_board","type":"kanban","entity":"order_line",
     "group_by":"status","columns":["queued","cooking","ready","served"],
     "card_fields":["menu_item_id","qty","note","order_id"],"realtime":true},
    {"key":"reservation_calendar","type":"calendar","entity":"reservation",
     "date_field":"datetime","title_field":"customer_id","color_by":"status"},
    {"key":"menu_manage","type":"table","entity":"menu_item",
     "columns":["photo","name","category_id","price","std_cost","gross_margin","is_sold_out"],
     "actions":["create","import"],"row_actions":["edit","toggle_sold_out","view_recipe"]},
    {"key":"stock_list","type":"table","entity":"ingredient",
     "columns":["name","stock_qty","safety_stock","cost_per_unit","supplier_id"],
     "conditional_format":[{"when":"stock_qty < safety_stock","style":"danger"}],
     "actions":["stock_take","create_po"]},
    {"key":"customer_list","type":"table","entity":"customer",
     "columns":["name","phone","level","balance","visit_count","last_visit"],
     "row_actions":["detail","topup","send_coupon"]},
    {"key":"staff_roster","type":"calendar","entity":"shift","date_field":"date"}
  ],
  "workflows": [
    {"key":"low_stock","trigger":{"type":"field_change","entity":"ingredient","field":"stock_qty"},
     "condition":"stock_qty <= safety_stock",
     "actions":[{"type":"create_alert","severity":"warning","template":"low_stock"},
                {"type":"notify_agent","agent":"ops","skill":"purchase_suggest"}]},
    {"key":"table_overtime","trigger":{"type":"schedule","cron":"*/10 * * * *"},
     "condition":"order.status='open' AND now()-opened_at > interval '90 min'",
     "actions":[{"type":"create_alert","severity":"info","template":"table_overtime"}]},
    {"key":"bad_review","trigger":{"type":"record_create","entity":"review"},
     "condition":"rating <= 2",
     "actions":[{"type":"notify_owner","channel":"whatsapp","template":"bad_review_alert"},
                {"type":"notify_agent","agent":"sales_cs","skill":"review_reply"}]},
    {"key":"low_balance","trigger":{"type":"field_change","entity":"customer","field":"balance"},
     "condition":"balance < 50 AND level != '普通'",
     "actions":[{"type":"notify_agent","agent":"sales_cs","skill":"topup_reminder"}]},
    {"key":"abnormal_void","trigger":{"type":"schedule","cron":"0 2 * * *"},
     "condition":"daily void_rate > 0.03 OR daily void_amount > 300",
     "actions":[{"type":"notify_owner","channel":"whatsapp","severity":"critical","template":"void_anomaly"}]}
  ],
  "roles": [
    {"key":"owner","permissions":["*"]},
    {"key":"manager","permissions":["order:*","menu_item:*","ingredient:*","shift:*","customer:read","expense:read","review:*"],
     "row_filter":"store_id = {{user.store_id}}"},
    {"key":"cashier","permissions":["order:*","payment:*","customer:read","customer:write:level","stored_value_txn:create"],
     "denied_fields":["staff.hourly_rate","expense.*"]},
    {"key":"kitchen","permissions":["order_line:read","order_line:write:status","menu_item:write:is_sold_out","waste_log:create"]},
    {"key":"waiter","permissions":["order:create","order_line:*","dining_table:*","reservation:*"]}
  ],
  "navigation": [
    {"label":{"zh":"今日","en":"Today"},"icon":"home","view":"dashboard"},
    {"label":{"zh":"订单"},"icon":"receipt","view":"order_list"},
    {"label":{"zh":"厨房"},"icon":"chef-hat","view":"kitchen_board"},
    {"label":{"zh":"菜单"},"icon":"book-open","view":"menu_manage"},
    {"label":{"zh":"库存"},"icon":"package","view":"stock_list"},
    {"label":{"zh":"会员"},"icon":"users","view":"customer_list"},
    {"label":{"zh":"预订"},"icon":"calendar","view":"reservation_calendar"},
    {"label":{"zh":"排班"},"icon":"clock","view":"staff_roster"}
  ]
}
```

### industry-packs/fnb/metrics.yaml

```yaml
# 餐饮核心指标。benchmark 为马来西亚 SME 参考区间，接入真实商家后需校准。
metrics:
  - key: revenue
    label: { zh: 营业额, en: Revenue }
    sql: "SUM(total) FILTER (WHERE status='paid')"
    entity: order
    dimensions: [date, hour, channel, store, staff, menu_item]
    format: money
  - key: net_receivable
    label: { zh: 实收（扣平台抽佣）, en: Net Receivable }
    sql: "SUM(total - platform_commission) FILTER (WHERE status='paid')"
    entity: order
    note: "外卖占比高的商家，必须看这个而不是营业额"
  - key: order_count
    label: { zh: 单量 }
    sql: "COUNT(*) FILTER (WHERE status='paid')"
  - key: guest_count
    label: { zh: 客数(pax) }
    sql: "SUM(pax) FILTER (WHERE status='paid' AND channel='dine_in')"
  - key: aov
    label: { zh: 客单价 }
    sql: "revenue / NULLIF(guest_count,0)"
    benchmark: { kopitiam: [8,15], cafe: [18,35], restaurant: [30,60], mamak: [8,14], bubble_tea: [10,18] }
  - key: ticket_avg
    label: { zh: 单均 }
    sql: "revenue / NULLIF(order_count,0)"
  - key: table_turnover
    label: { zh: 翻台率 }
    sql: "COUNT(DISTINCT order.id) / NULLIF(COUNT(DISTINCT dining_table.id),0)"
    benchmark: { lunch: [2.0,3.5], dinner: [1.5,2.5], mamak: [4,8] }
  - key: food_cost
    label: { zh: 食材成本 }
    sql: "SUM(order_line.line_cost)"
  - key: food_cost_pct
    label: { zh: 食材成本率 }
    sql: "food_cost / NULLIF(revenue,0)"
    format: percent
    benchmark: { healthy: [0.28,0.35], warning: 0.38, critical: 0.42 }
    note: "饮品店应 <0.30，中餐 0.32-0.38，火锅可到 0.40"
  - key: labour_cost_pct
    label: { zh: 人力成本率 }
    sql: "SUM(shift.hours * staff.hourly_rate) / NULLIF(revenue,0)"
    benchmark: { healthy: [0.18,0.25], warning: 0.28, critical: 0.33 }
  - key: prime_cost_pct
    label: { zh: 主要成本率（食材+人力）}
    sql: "food_cost_pct + labour_cost_pct"
    benchmark: { healthy: [0.50,0.60], warning: 0.63, critical: 0.68 }
    note: "餐饮最重要的单一指标。超过 0.65 基本不赚钱。"
  - key: gross_margin
    label: { zh: 毛利率 }
    sql: "1 - food_cost_pct"
  - key: waste_pct
    label: { zh: 报废率 }
    sql: "SUM(waste_log.cost) / NULLIF(food_cost,0)"
    benchmark: { healthy: [0,0.02], warning: 0.04, critical: 0.06 }
  - key: delivery_share
    label: { zh: 外卖占比 }
    sql: "SUM(total) FILTER (WHERE channel IN ('grabfood','foodpanda','shopeefood')) / NULLIF(revenue,0)"
  - key: commission_pct
    label: { zh: 平台抽佣率 }
    sql: "SUM(platform_commission) / NULLIF(SUM(total) FILTER (WHERE channel IN ('grabfood','foodpanda','shopeefood')),0)"
    benchmark: { typical: [0.25,0.35] }
  - key: void_rate
    label: { zh: 作废率 }
    sql: "COUNT(*) FILTER (WHERE status='void') / NULLIF(COUNT(*),0)"
    benchmark: { healthy: [0,0.01], warning: 0.03 }
    note: "异常升高是内部舞弊的首要信号，必须按收银员维度看"
  - key: discount_rate
    label: { zh: 折扣率 }
    sql: "SUM(discount) / NULLIF(SUM(subtotal),0)"
  - key: repeat_rate
    label: { zh: 复购率(90天) }
    sql: "COUNT(DISTINCT customer_id) FILTER (WHERE visit_count>1) / NULLIF(COUNT(DISTINCT customer_id),0)"
    benchmark: { healthy: [0.30,0.50] }
  - key: member_share
    label: { zh: 会员消费占比 }
    sql: "SUM(total) FILTER (WHERE customer_id IS NOT NULL) / NULLIF(revenue,0)"
  - key: avg_prep_time
    label: { zh: 平均出餐时长(分钟) }
    sql: "AVG(EXTRACT(EPOCH FROM (order_line.ready_at - order.opened_at))/60)"
    benchmark: { healthy: [8,15], warning: 20 }
  - key: labour_efficiency
    label: { zh: 人效(每工时营业额) }
    sql: "revenue / NULLIF(SUM(shift.hours),0)"
    benchmark: { healthy: [40,80] }
  - key: stock_days
    label: { zh: 库存周转天数 }
    sql: "SUM(ingredient.stock_qty * cost_per_unit) / NULLIF(food_cost/period_days,0)"
    benchmark: { healthy: [3,7], warning: 12 }
  - key: stored_value_liability
    label: { zh: 储值负债 }
    sql: "SUM(customer.balance)"
    note: "这是负债不是收入。老板常误以为储值收的钱可以花。"
```

### industry-packs/fnb/alert-rules.yaml

```yaml
rules:
  - key: prime_cost_high
    severity: critical
    label: { zh: 主要成本率超标 }
    condition: "prime_cost_pct > 0.65"
    window: last_7d
    message: { zh: "近7天主要成本率 {{value|pct}}，超过 65% 警戒线。目前基本不赚钱。" }
    next_action: skill:cost_diagnosis
  - key: food_cost_spike
    severity: warning
    condition: "food_cost_pct > 0.38 OR food_cost_pct > last_30d_avg * 1.15"
    window: last_7d
    message: { zh: "食材成本率 {{value|pct}}，比上月高 {{delta|pct}}。可能原因：进价上涨/浪费/配方超量/偷窃。" }
    next_action: skill:food_cost_analysis
  - key: void_anomaly
    severity: critical
    condition: "daily void_rate > 0.03 OR daily void_amount > 300"
    group_by: staff_id
    message: { zh: "{{staff.name}} 今天作废 {{count}} 单共 RM{{amount}}，明显高于平均。建议调取监控核对。" }
    privacy_note: "仅推送给 owner，不进任何群组"
  - key: cash_shortfall
    severity: critical
    condition: "mtd_expense > mtd_net_receivable"
    message: { zh: "本月支出 RM{{expense}} 已超过实收 RM{{revenue}}。现金流告急。" }
  - key: low_stock
    severity: warning
    condition: "ingredient.stock_qty <= ingredient.safety_stock"
    message: { zh: "{{ingredient.name}} 剩 {{qty}}{{unit}}，低于安全库存。按近7天用量约还能撑 {{days}} 天。" }
    next_action: skill:purchase_suggest
  - key: expiring_soon
    severity: warning
    condition: "ingredient.is_perishable AND days_to_expiry <= 2"
    message: { zh: "{{ingredient.name}} 还有 {{days}} 天过期，库存价值 RM{{value}}。建议做特价推。" }
  - key: waste_high
    severity: warning
    condition: "waste_pct > 0.04"
    window: last_7d
  - key: revenue_drop
    severity: warning
    condition: "revenue < last_4w_same_weekday_avg * 0.75"
    message: { zh: "今天营业额 RM{{value}}，比过去4周同一星期几平均低 {{delta|pct}}。" }
    next_action: skill:anomaly_attribution
  - key: bad_review_streak
    severity: warning
    condition: "count(review WHERE rating<=2) >= 3"
    window: last_7d
    message: { zh: "近7天收到 {{count}} 条差评，集中在：{{top_topics}}。" }
  - key: delivery_unprofitable
    severity: warning
    condition: "commission_pct > 0.30 AND delivery_gross_margin < 0.15"
    message: { zh: "外卖扣佣后毛利仅 {{margin|pct}}，卖越多亏越多。建议调整外卖定价或菜品结构。" }
  - key: prep_time_slow
    severity: info
    condition: "avg_prep_time > 20"
    window: last_1d_peak_hours
  - key: stored_value_risk
    severity: info
    condition: "stored_value_liability > mtd_revenue * 1.5"
    message: { zh: "储值负债 RM{{value}}，是本月营业额的 {{ratio}} 倍。注意这是要还的钱。" }
  - key: labour_overtime
    severity: info
    condition: "staff weekly_hours > 48"
    note: "马来西亚雇佣法 1955 每周工时上限"
```

### industry-packs/fnb/skills/ — 12 个技能（关键几个展开）

#### menu-engineering.yaml（餐饮杀手锏）

```yaml
id: menu_engineering
name: { zh: 菜单工程分析, en: Menu Engineering }
department: analytics
triggers:
  - { type: chat, patterns: ["哪些菜赚钱","菜单分析","要不要下架","menu engineering","哪个菜要推"] }
  - { type: schedule, cron: "0 10 1 * *" }   # 每月1号
inputs:
  period: { type: enum, options: [last_30d, last_90d], default: last_30d }
steps:
  - id: fetch
    type: metric_query
    metrics: [order_count, revenue, food_cost, gross_margin]
    dimensions: [menu_item]
    range: "{{ period }}"
  - id: classify
    type: compute
    logic: |
      对每个菜品计算：
        popularity = 销量 / 该分类平均销量
        profitability = 单品毛利额 / 该分类平均毛利额
      四象限：
        明星 Star   : pop>=1 且 profit>=1  → 保持品质，放菜单显眼位
        金牛 Plow   : pop>=1 且 profit<1   → 小幅提价 or 降成本，别下架
        问题 Puzzle : pop<1  且 profit>=1  → 改名/换图/推荐/服务员主推
        瘦狗 Dog    : pop<1  且 profit<1   → 下架，除非是引流品或必备品
  - id: guard
    type: rule_check
    rules:
      - "标记为 signature 或 halal 必备的菜，即使是 Dog 也不建议下架，需人工判断"
      - "上架不足 30 天的新品不参与分类"
  - id: compose
    type: llm_generate
    prompt_template: report/menu-engineering.md
    context: [fetch, classify, memory.L1, glossary]
  - id: deliver
    type: notify
    channels: [app, whatsapp]
permissions_required: [read:order, read:order_line, read:menu_item, read:recipe_line]
risk: low
```

#### daily-close.yaml（日结报告 — 最高频）

```yaml
id: daily_close_report
name: { zh: 每日营业日结, en: Daily Close }
department: analytics
triggers:
  - { type: chat, patterns: ["今天生意怎么样","日结","昨天多少钱","今日营业额"] }
  - { type: schedule, cron: "30 23 * * *", channel: whatsapp, template: wa_daily_close }
steps:
  - id: fetch
    type: metric_query
    metrics: [revenue, net_receivable, order_count, guest_count, aov, food_cost_pct, void_rate, discount_rate]
    dimensions: [channel]
    range: business_day          # 按 fiscal_day_start 05:00 切分
    compare: [yesterday, last_week_same_weekday, last_4w_same_weekday_avg]
  - id: top_items
    type: metric_query
    metrics: [order_count, revenue]
    dimensions: [menu_item]
    limit: 5
  - id: payments
    type: metric_query
    metrics: [amount]
    dimensions: [payment.method]
    note: "用于现金对账"
  - id: checks
    type: rule_check
    rules: [void_anomaly, food_cost_spike, low_stock, revenue_drop]
  - id: compose
    type: llm_generate
    prompt_template: report/daily-close.md
    max_tokens: 700
  - id: deliver
    type: notify
    channels: [whatsapp, app]
    attach_chart: [hourly_revenue_bar]
permissions_required: [read:order, read:payment, read:order_line]
risk: low
estimated_cost: { tokens: 2800, usd: 0.009 }
```

#### 其余 10 个技能（同格式，文件已生成）

| 文件 | 技能 | 部门 | 触发 |
|---|---|---|---|
| weekly-review.yaml | 每周经营复盘 | analytics | 周一 09:00 |
| monthly-pnl.yaml | 月度损益表（含 SST/e-Invoice 口径） | analytics | 每月3号 |
| food-cost-analysis.yaml | 食材成本归因（进价↑/浪费/配方超量/舞弊四路排查） | analytics | 预警触发 |
| cost-diagnosis.yaml | Prime Cost 诊断与降本方案 | analytics | 预警触发 |
| stock-check.yaml | 对话式盘点（报数→差异→原因） | ops | "盘点" |
| purchase-suggest.yaml | 采购建议（按用量预测+供应商送货日+账期） | ops | 低库存 |
| ingest-invoice.yaml | 送货单/收据拍照 OCR → 采购单入库 | ops | 图片消息 |
| record-expense.yaml | 口述记账（"今天付了水电 380"） | ops | 自然语言 |
| roster-suggest.yaml | 排班建议（按分时客流+人效+工时法规） | ops | "排班" |
| promo-effect.yaml | 活动效果复盘（增量 vs 蚕食） | growth | 活动结束 |
| review-reply.yaml | 评价回复草稿（差评先安抚+私下补偿，不辩解） | sales_cs | 新评价 |
| member-recall.yaml | 流失会员召回（RFM 分层+券策略） | sales_cs | 每周 |

### industry-packs/fnb/report-templates/daily-close.md

```markdown
你是餐饮老板的数字管家。用**马来西亚华人商家习惯的中文**写日结报告。

## 硬性要求
- 开头一句话直接说结论（好/持平/差 + 一个原因）
- 所有金额用 RM，千分位
- 每个数字后面标对比（↑↓% vs 昨天）
- 不用"GMV""转化率""同比环比"这类词；用"营业额""回头客""比昨天"
- 最多 3 个建议，每个建议必须可当天执行
- 如果数据有缺口（比如没录支出），明确说"这项没数据"，不要猜
- 总长度控制在 WhatsApp 一屏内（约 350 字）

## 结构
【{{date}} 日结】
{{一句话结论}}

💰 营业额 RM{{revenue}}（{{vs_yesterday}}）
　实收 RM{{net_receivable}}（外卖抽佣 RM{{commission}}）
🧾 {{order_count}} 单 / {{guest_count}} 位客 / 客单 RM{{aov}}
📊 堂食 {{dine_in_pct}} · 外卖 {{delivery_pct}} · 打包 {{takeaway_pct}}

🔥 今日热卖
{{top_5_items}}

⚠️ 要注意
{{alerts | 若无则写"今天没有异常"}}

💡 建议
{{advice_max_3}}

---
数据口径：营业日 {{fiscal_start}}–{{fiscal_end}}，仅统计已付款订单。
回复「明细」看完整数据。
```

### industry-packs/fnb/glossary.yaml

```yaml
# 术语映射：商家怎么说 → 系统里是什么
terms:
  - { say: ["打包","tapau","takeaway"], means: "order.channel='takeaway'" }
  - { say: ["外卖","送餐","grab","panda"], means: "order.channel IN ('grabfood','foodpanda','shopeefood')" }
  - { say: ["堂食","坐店里","dine in"], means: "order.channel='dine_in'" }
  - { say: ["埋单","结账","收钱"], means: "order.status='paid'" }
  - { say: ["沽清","卖完了","sold out","冇了"], means: "menu_item.is_sold_out=true" }
  - { say: ["翻台","转台"], means: "metric:table_turnover" }
  - { say: ["客数","人头","pax"], means: "order.pax" }
  - { say: ["水吧","饮料档"], means: "menu_category.station='drinks'" }
  - { say: ["楼面","前场"], means: "staff.role IN ('waiter','cashier')" }
  - { say: ["后厨","出品"], means: "staff.role='kitchen'" }
  - { say: ["走单","跑单"], means: "order.status='void' 且无 payment" }
  - { say: ["请客","招待"], means: "order.discount=100% + void_reason='招待'" }
  - { say: ["员工餐"], means: "waste_log.reason='staff_meal'" }
  - { say: ["生意","流水","营业额"], means: "metric:revenue" }
  - { say: ["赚多少","净"], means: "metric:net_receivable 或 gross_margin，需追问口径" }
  - { say: ["死货","压货"], means: "库存周转 > 30 天的 ingredient" }
  - { say: ["套餐","set lunch"], means: "menu_item.tags 含 'set'" }
  - { say: ["加料","addon","走冰","少甜"], means: "order_line.modifiers" }
ambiguous:   # 必须追问口径，不许猜
  - term: "赚了多少"
    ask: "您是想看毛利（扣食材）还是净利（扣所有开销）？"
  - term: "这个月"
    ask: "按日历月（1号到今天）还是按您的结算月？"
  - term: "生意好不好"
    default: "默认对比过去4周同一星期几的平均"
```

### industry-packs/fnb/advice-kb.yaml（诊断知识库 — 智能体"懂行"的来源）

```yaml
diagnoses:
  - symptom: food_cost_pct 持续 > 0.38
    label: { zh: 食材成本率过高 }
    check_order:                    # 按可能性排序，逐条查
      - id: price_increase
        question: "近30天原料进价是否上涨？"
        query: "purchase_line.unit_price 环比"
        advice: "① 找 2 家备选供应商比价 ② 涨幅大的原料考虑改配方或换货源 ③ 涨幅 >15% 的核心原料，可考虑同步微调售价（每次不超过 8%，避开招牌菜）"
      - id: waste
        question: "报废率是否 >4%？"
        query: "waste_pct"
        advice: "① 生鲜改为隔天进货 ② 临期食材做限时特价 ③ 员工餐优先消耗临期 ④ 每周固定盘点日"
      - id: recipe_overuse
        question: "实际用量 vs 标准配方是否偏差 >10%？"
        query: "stock_movement.consume vs recipe_line.qty * order_line.qty"
        advice: "① 后厨用量器具标准化（勺/杯/秤）② 高成本原料（肉/海鲜）先做标准化 ③ 主厨培训"
      - id: theft
        question: "作废率/无单出品是否异常？"
        query: "void_rate by staff, stock consume without order"
        advice: "⚠️ 仅提示 owner。① 核对监控与作废记录 ② 作废需主管授权 ③ 后门收货流程改由两人签收"
    note: "四条按顺序排查，不要一开始就怀疑员工——那是最后一条"
  - symptom: prime_cost_pct > 0.65
    label: { zh: 基本不赚钱 }
    advice: |
      Prime Cost 是餐饮生死线。优先级：
      1. 先砍人力弹性成本（调整排班对齐分时客流），比砍食材见效快且不伤品质
      2. 用菜单工程下架 Dog、微调 Plow 定价
      3. 检查外卖：扣佣后毛利 <15% 的菜品从外卖菜单下架
      4. 最后才考虑整体提价（提价必伤客流，需搭配菜单改版做心理锚定）
  - symptom: 外卖占比高但不赚钱
    advice: |
      ① 外卖菜单≠堂食菜单：只上毛利率 >55% 且耐运输的菜
      ② 外卖定价应比堂食高 15-25%（覆盖抽佣），马来消费者已普遍接受
      ③ 包装成本必须计入 food_cost，很多老板漏算
      ④ 引导私域：包装内放 WhatsApp 二维码 + 直订折扣，把复购客从平台拉回来
      ⑤ 平台冲销量的活动，先算增量单是不是真的增量（用 promo_effect 技能）
  - symptom: repeat_rate < 0.30
    advice: |
      ① 先看差评主题分布：taste/speed/service 各占多少，先修占比最高的
      ② 会员储值是餐饮最有效的锁客工具（储 100 送 15），但要提醒老板：这是负债
      ③ 建立"第二次到店"钩子：首次消费给 7 天内可用的小额券，转化率最高
      ④ 生日提醒 + 常点菜记忆（"陈生今天还是要 kopi-o 少糖？"）——这是我们记忆系统的杀手场景
  - symptom: 翻台率低（午市 <2.0）
    advice: |
      ① 出餐时长是主因：peak 时段 >20 分钟必须先解决后厨瓶颈
      ② 推套餐减少点单犹豫时间
      ③ 提前收台/买单动线优化（扫码点餐+扫码付）
      ④ 分流：把慢客（聊天客）引导到边角位
  - symptom: labour_cost_pct > 0.28
    advice: |
      ① 拉分时客流曲线，把人排在曲线上而不是平均排
      ② 兼职/钟点工填峰值，全职守基线（注意 EPF/SOCSO 与工时法规）
      ③ 人效 <RM40/工时的班次优先砍
      ④ 交叉训练（楼面能帮传菜）比增人便宜
principles:                  # 给建议时的通用原则
  - "永远先给可当天执行的动作，再给结构性建议"
  - "涉及员工的敏感判断（怀疑舞弊）只私下告诉 owner，且必须说'建议核实'而非下结论"
  - "提价建议必须附带风险提示与幅度上限"
  - "不给需要额外买软件/设备才能做的建议，除非明确说明成本"
  - "马来市场特有：斋戒月、开斋节、农历新年、学校假期对客流影响巨大，做同比时必须校正"
```

## 五、scripts/bootstrap.sh

```bash
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
```

---

> 注：本文档由分享对话整理落盘。文档「一、目录结构」中列出但未在正文给出内容的文件（如 `docs/ARCHITECTURE.md` 附录 A、`docs/APP_SCHEMA_SPEC.md`、`docs/SKILL_SPEC.md`、`docs/PERMISSION_MODEL.md`、`.claude/commands/task-new.md`、`.oaim/state/DECISIONS.md`、`.oaim/state/RISKS.md`，以及 skills 目录中除 menu-engineering / daily-close 之外的 10 个技能与 daily-close 之外的 report-templates），正文未提供可照抄的代码块，故未落盘。
