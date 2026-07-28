# OAIM 架构文档 v2.0

> ⚠️ **占位文件 — 待补全**
> 引导文档（`docs/BOOTSTRAP.md`）将本文件标注为「见附录 A」，但附录 A 的正文未随引导包提供，
> 因此这里没有可照抄的原文。本文件仅作为占位，交叉引用 `CLAUDE.md` 中已经生效、且具权威性的
> 架构约束，使骨架可运行。**收到附录 A 全文后，用其内容整体替换本文件。**

## 权威来源
项目宪法 `CLAUDE.md` 是当前唯一的权威架构契约来源。下述六条铁律在 `CLAUDE.md` 中定义，
本文件不重写、不解释、不扩展，仅指向：

- **D1** 搭建产物是 App Schema (JSON)，不生成代码仓库
- **D2** 预览 = Schema Renderer + iframe 热更新，不用真沙箱
- **D3** Builder 沉淀的 Entity 元数据 = 管理智能体的数据认知来源
- **D4** 智能体永不直接写 SQL，只能经 `packages/semantic`
- **D5** 多智能体用 Supervisor + 任务队列，不用自由群聊
- **D6** LLM Gateway 必须先于任何 AI 功能上线

## 相关契约文档（同样待补全）
引导文档的目录结构中还列出了以下文档，正文均未提供内容，尚未落盘：
- `docs/APP_SCHEMA_SPEC.md` — App Schema 规范与版本号
- `docs/SKILL_SPEC.md` — 技能（skill）定义规范
- `docs/PERMISSION_MODEL.md` — 权限模型

## 待补全清单
- [ ] 用附录 A 全文替换本占位
- [ ] 补 `docs/APP_SCHEMA_SPEC.md`
- [ ] 补 `docs/SKILL_SPEC.md`
- [ ] 补 `docs/PERMISSION_MODEL.md`
