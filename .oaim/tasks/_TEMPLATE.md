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
