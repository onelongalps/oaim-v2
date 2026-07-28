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
