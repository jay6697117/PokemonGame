# Rematch/Layout/HitStop 修复收尾与警告清理工作计划

## TL;DR

> **Quick Summary**: 采用“两阶段硬隔离”收尾：先把已验证通过的 1+2+3 修复原子提交并推送，再单独处理 QA 脚本的 `ObjectDB instances leaked at exit` 警告，最后回归验证。
>
> **Deliverables**:
> - Phase A：已通过修复提交并推送（不夹带 warning 清理）
> - Phase B：`qa_hit_stop_scale_stability.gd` 与 `qa_layout_metrics_scaling.gd` 的泄漏警告清理
> - 最终回归：`./start-demo.sh --verify-only` 全链路通过
>
> **Estimated Effort**: Short
> **Parallel Execution**: YES - 4 waves
> **Critical Path**: Task 1 -> Task 2 -> (Task 3 + Task 4) -> Task 5

---

## Context

### Original Request
用户要求继续推进当前批次工作，并已明确选择顺序：先提交已验证修复，再单独清理 warning。

### Interview Summary
**Key Discussions**:
- 已完成并验证三类问题修复：
  - KO/TIME UP 后 rematch stale continuation 竞态
  - 1280x720 硬编码布局/边界
  - hit-stop 连击累计 scale 漂移
- 用户确认执行顺序：`先提交再清warning`。

**Research Findings**:
- `bg_1227784b`：确认 sequence ticket/epoch guard 是最小且安全方案。
- `bg_1f8f36a0`：确认硬编码核心集中在 `scripts/flow/battle_screen.gd` 与 `scripts/visuals/arena_atmosphere.gd`。
- `bg_f6ada023`：确认三项 QA token 设计与脚本入口可稳定机读。
- `bg_d4bbc72f`：官方文档支持 `resized/NOTIFICATION_RESIZED`、`pivot_offset_ratio` 与 `create_timer` 时序实践。
- `bg_9b39dcdd`：OSS 模式支持“集中 reset + await 后状态/epoch 复检”。

### Metis Review
**Identified Gaps (addressed in this plan)**:
- 需明确“Phase A 与 Phase B 不混提”。
- 需限制 warning 清理触达范围，防止扩展到玩法层。
- 需把“清理成功”定义为可机读的 `无 ObjectDB leaked` 标准，而不是主观判断。
- 需加入 push 同步证明与重复运行稳定性门槛。

---

## Work Objectives

### Core Objective
在不新增玩法改动的前提下，完成本批 1+2+3 修复的可交付收尾：先稳定交付功能修复，再消除 QA 生命周期警告并保持回归绿色。

### Concrete Deliverables
- 一次只包含“已验证修复”的提交与推送。
- 一次只包含“warning 清理”的提交与推送（如有文件变更）。
- `./start-demo.sh --verify-only` 最终通过，且不出现 token 缺失。

### Definition of Done
- [x] `./start-demo.sh --verify-only` 输出 `DEMO_CHECKLIST_PASS` 且无 `TOKEN_MISSING:`。
- [ ] Phase A 推送后 `git status -sb` 不再显示 `[ahead N]`。
- [ ] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_hit_stop_scale_stability.gd"` 输出 `QA_HIT_STOP_SCALE_STABILITY_OK` 且不含 `ObjectDB instances leaked at exit`。
- [ ] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_layout_metrics_scaling.gd"` 输出 `QA_LAYOUT_METRICS_SCALING_OK` 且不含 `ObjectDB instances leaked at exit`。

### Must Have
- 保持当前 1+2+3 修复行为不回退。
- 先交付功能修复，再做警告清理。
- 每个阶段都必须有可机读验收命令。

### Must NOT Have (Guardrails)
- 不新增玩法特性、不改伤害/回合结算规则。
- 不把 warning 清理混入 Phase A 提交。
- 不把 warning 清理扩展成 QA 框架重构。
- 不提交无关文件（尤其 `.sisyphus/ralph-loop.local.md` 除非用户明确要求）。
- 若仅改 QA 脚本无法消除 warning，必须先暂停并回报，不得默认扩展到运行时脚本。

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> 所有验收必须由 Agent 直接执行命令并机读结果；禁止人工点击/目测作为完成标准。

### Test Decision
- **Infrastructure exists**: YES
- **Automated tests**: YES（tests-after，当前以 headless QA + token gates 为主）
- **Framework**: Godot headless scripts + `start-demo.sh` token parser

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

Scenario: Lock-in baseline before commit
  Tool: Bash
  Preconditions: Working tree has intended 1+2+3 changes
  Steps:
    1. Run: `./start-demo.sh --verify-only`
    2. Assert output contains `KO_STALE_BLOCKED:true`, `TIMEUP_STALE_BLOCKED:true`
    3. Assert output contains `QA_HIT_STOP_SCALE_STABILITY_OK`, `QA_LAYOUT_METRICS_SCALING_OK`
    4. Assert output contains `DEMO_CHECKLIST_PASS`
    5. Assert output does NOT contain `TOKEN_MISSING:`
  Expected Result: 全链路 token 验证通过
  Failure Indicators: 任一 token 缺失或脚本非 0 退出
  Evidence: `.sisyphus/evidence/postfix-phase-a-verify.txt`

Scenario: Warning cleanup target check (single script)
  Tool: Bash
  Preconditions: warning cleanup patch applied to target QA script
  Steps:
    1. Run target script headless (`qa_hit_stop_scale_stability.gd` or `qa_layout_metrics_scaling.gd`)
    2. Assert output contains对应 `QA_*_OK`
    3. Assert output does NOT contain `ObjectDB instances leaked at exit`
  Expected Result: 脚本通过且无泄漏警告
  Failure Indicators: 出现 leaked 警告或 token 缺失
  Evidence: `.sisyphus/evidence/postfix-warning-check-{script}.txt`

Scenario: Stability check after warning cleanup
  Tool: Bash
  Preconditions: both warning-target scripts pass single-run check
  Steps:
    1. Loop run `qa_hit_stop_scale_stability.gd` 5 times
    2. Loop run `qa_layout_metrics_scaling.gd` 5 times
    3. Every run asserts `QA_*_OK` present and leaked warning absent
  Expected Result: 10 次连续稳定无泄漏
  Failure Indicators: 任一轮出现 leaked 或 token 缺失
  Evidence: `.sisyphus/evidence/postfix-warning-stability.txt`

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
└── Task 1: Phase A 基线验证与证据锁定

Wave 2 (After Wave 1):
└── Task 2: Phase A 原子提交与推送

Wave 3 (After Wave 2):
├── Task 3: 清理 qa_hit_stop_scale_stability.gd 泄漏警告
└── Task 4: 清理 qa_layout_metrics_scaling.gd 泄漏警告

Wave 4 (After Wave 3):
└── Task 5: 最终回归、二次提交（如有）与推送同步

Critical Path: 1 -> 2 -> 5
Parallel Speedup: ~20% (Task 3 + Task 4)
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|---|---|---|---|
| 1 | None | 2 | None |
| 2 | 1 | 3, 4, 5 | None |
| 3 | 2 | 5 | 4 |
| 4 | 2 | 5 | 3 |
| 5 | 3, 4 | None | None |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|---|---|---|
| 1 | 1 | `task(category="quick", load_skills=["verification-before-completion"], run_in_background=false)` |
| 2 | 2 | `task(category="quick", load_skills=["git-master","verification-before-completion"], run_in_background=false)` |
| 3 | 3, 4 | 两个并行 agent，均使用 `systematic-debugging` + `verification-before-completion` |
| 4 | 5 | `task(category="quick", load_skills=["git-master","verification-before-completion"], run_in_background=false)` |

---

## TODOs

- [x] 1. Phase A 基线验证与证据锁定

  **What to do**:
  - 运行 `./start-demo.sh --verify-only` 并保存完整输出到证据文件。
  - 记录当前 warning 基线（仅观察，不在本任务清理）。

  **Must NOT do**:
  - 不修改任何源文件。
  - 不做提交/推送。

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 纯验证与证据采集，低复杂度。
  - **Skills**: `verification-before-completion`
    - `verification-before-completion`: 保证先跑命令再声称通过。
  - **Skills Evaluated but Omitted**:
    - `git-master`: 本任务无提交动作，可省略。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 2
  - **Blocked By**: None

  **References**:
  - `start-demo.sh` - 主验收入口与 token gate 逻辑。
  - `start-demo.sh:87` - rematch race guard QA 接入点。
  - `start-demo.sh:91` - hit-stop stability QA 接入点。
  - `start-demo.sh:95` - layout metrics QA 接入点。
  - `start-demo.sh:103` - `DEMO_CHECKLIST_PASS` 终态 token。

  **Acceptance Criteria**:
  - [x] `./start-demo.sh --verify-only` 返回 0。
  - [x] 输出包含 `KO_STALE_BLOCKED:true` 与 `TIMEUP_STALE_BLOCKED:true`。
  - [x] 输出包含 `QA_HIT_STOP_SCALE_STABILITY_OK` 与 `QA_LAYOUT_METRICS_SCALING_OK`。
  - [x] 输出包含 `DEMO_CHECKLIST_PASS` 且不含 `TOKEN_MISSING:`。

  **Commit**: NO

- [ ] 2. Phase A 原子提交与推送（仅功能修复）

  **What to do**:
  - 仅暂存本批功能修复相关文件。
  - 创建 Phase A 提交并推送。
  - 用 `git status -sb` 证明已同步（不 ahead）。

  **Must NOT do**:
  - 不把 warning 清理混入本提交。
  - 不提交无关文件（例如 `.sisyphus/ralph-loop.local.md`）。

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 标准 git 原子收尾。
  - **Skills**: `git-master`, `verification-before-completion`
    - `git-master`: 提交拆分、原子信息、push 同步检查。
    - `verification-before-completion`: 推送后必须验证状态。
  - **Skills Evaluated but Omitted**:
    - `systematic-debugging`: 本任务不做故障定位。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 3, Task 4, Task 5
  - **Blocked By**: Task 1

  **References**:
  - `scripts/flow/battle_screen.gd` - sequence ticket 与动态 layout 关键修复文件。
  - `scripts/visuals/arena_atmosphere.gd` - 动态 layout metrics 应用。
  - `scripts/visuals/fighter_visual.gd` - `hit_stop()` 基于 `_rest_scale` 修复点。
  - `qa/qa_rematch_transition_race_guard.gd` - 新增竞态防回写 QA。
  - `qa/qa_hit_stop_scale_stability.gd` - 新增连击 scale 稳定 QA。
  - `qa/qa_layout_metrics_scaling.gd` - 新增动态布局 QA。
  - `start-demo.sh` - 新 QA token gate 接入。

  **Acceptance Criteria**:
  - [ ] 提交仅包含上述目标文件，无额外噪音。
  - [ ] 推送成功后 `git status -sb` 不包含 `[ahead `。
  - [ ] 提交前后可追溯到 Task 1 的验证证据。

  **Commit**: YES
  - Message: `fix(battle): lock in rematch/layout/hit-stop fixes with QA gates`

- [ ] 3. 清理 `qa_hit_stop_scale_stability.gd` 的 ObjectDB 泄漏警告

  **What to do**:
  - 仅在该 QA 脚本内调整生命周期收尾（释放时序、退出前 frame settle、引用清理）。
  - 单脚本验证 + 5 次稳定性验证。

  **Must NOT do**:
  - 不修改 `scripts/combat/*`、`scripts/flow/*` 玩法逻辑。
  - 不重构整个 QA harness。

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 单文件/小范围修复。
  - **Skills**: `systematic-debugging`, `verification-before-completion`
    - `systematic-debugging`: 针对 leaked warning 做因果定位。
    - `verification-before-completion`: 每次改动后立即复验。
  - **Skills Evaluated but Omitted**:
    - `git-master`: 本任务先修复，提交在 Task 5 统一处理。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 4)
  - **Blocks**: Task 5
  - **Blocked By**: Task 2

  **References**:
  - `qa/qa_hit_stop_scale_stability.gd` - 警告发生脚本与清理目标。
  - `scripts/visuals/fighter_visual.gd:98` - `hit_stop()` 行为基线，避免清理误伤逻辑。
  - `scripts/visuals/hit_feedback_pipeline.gd` - hit feedback 计数/时序参考。
  - `start-demo.sh:91` - 该脚本在总验收链路中的入口。
  - `https://docs.godotengine.org/en/stable/classes/class_scenetreetimer.html` - timer 生命周期与引用规则。

  **Acceptance Criteria**:
  - [ ] 单次运行输出 `QA_HIT_STOP_SCALE_STABILITY_OK`。
  - [ ] 单次运行输出不含 `ObjectDB instances leaked at exit`。
  - [ ] 连续 5 次运行均满足上述两条。

  **Commit**: NO

- [ ] 4. 清理 `qa_layout_metrics_scaling.gd` 的 ObjectDB 泄漏警告

  **What to do**:
  - 仅在该 QA 脚本内修正 SubViewport/节点释放与退出时序。
  - 单脚本验证 + 5 次稳定性验证。

  **Must NOT do**:
  - 不修改 battle 运行时布局策略。
  - 不把临时调试输出带入正式脚本。

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 单文件生命周期修复。
  - **Skills**: `systematic-debugging`, `verification-before-completion`
    - `systematic-debugging`: 面向 leaked warning 精确定位。
    - `verification-before-completion`: 防止“看似修复”但未复验。
  - **Skills Evaluated but Omitted**:
    - `git-master`: 提交在 Task 5 统一执行。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 3)
  - **Blocks**: Task 5
  - **Blocked By**: Task 2

  **References**:
  - `qa/qa_layout_metrics_scaling.gd` - 警告发生脚本与清理目标。
  - `scripts/flow/battle_screen.gd:496` - layout metrics 计算基线。
  - `scripts/visuals/arena_atmosphere.gd:61` - layout metrics 应用路径。
  - `start-demo.sh:95` - 该脚本在总验收链路中的入口。
  - `https://docs.godotengine.org/en/stable/classes/class_control.html` - `resized/NOTIFICATION_RESIZED` 与尺寸更新生命周期。

  **Acceptance Criteria**:
  - [ ] 单次运行输出 `QA_LAYOUT_METRICS_SCALING_OK`。
  - [ ] 单次运行输出不含 `ObjectDB instances leaked at exit`。
  - [ ] 连续 5 次运行均满足上述两条。

  **Commit**: NO

- [ ] 5. 最终回归、warning 清理提交（如有）与推送同步

  **What to do**:
  - 运行全链路回归 `./start-demo.sh --verify-only`。
  - 若 Task 3/4 产生改动，单独提交 warning 清理并推送。
  - 最终确认分支不 ahead。

  **Must NOT do**:
  - 不混入与 warning 无关的改动。
  - 不跳过回归直接推送。

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 收尾验证 + 轻量 git 操作。
  - **Skills**: `git-master`, `verification-before-completion`
    - `git-master`: 干净提交与推送状态验证。
    - `verification-before-completion`: 最终门禁命令先于完成声明。
  - **Skills Evaluated but Omitted**:
    - `systematic-debugging`: 该任务应基于已修复结果做验收，不再扩展调试。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: None
  - **Blocked By**: Task 3, Task 4

  **References**:
  - `start-demo.sh` - 最终总门禁命令。
  - `qa/qa_hit_stop_scale_stability.gd` - warning 清理结果验证。
  - `qa/qa_layout_metrics_scaling.gd` - warning 清理结果验证。

  **Acceptance Criteria**:
  - [ ] `./start-demo.sh --verify-only` 输出 `DEMO_CHECKLIST_PASS`。
  - [ ] 输出不含 `TOKEN_MISSING:`。
  - [ ] 若存在 warning 清理改动：完成独立提交与推送，`git status -sb` 不 ahead。

  **Commit**: YES (if files changed)
  - Message: `chore(qa): eliminate ObjectDB leak warnings in headless scripts`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|---|---|---|---|
| 2 | `fix(battle): lock in rematch/layout/hit-stop fixes with QA gates` | `scripts/flow/battle_screen.gd`, `scripts/visuals/arena_atmosphere.gd`, `scripts/visuals/fighter_visual.gd`, `start-demo.sh`, `qa/qa_rematch_transition_race_guard.gd`, `qa/qa_hit_stop_scale_stability.gd`, `qa/qa_layout_metrics_scaling.gd` | `./start-demo.sh --verify-only` |
| 5 | `chore(qa): eliminate ObjectDB leak warnings in headless scripts` | `qa/qa_hit_stop_scale_stability.gd`, `qa/qa_layout_metrics_scaling.gd` (if changed) | targeted 5x loops + `./start-demo.sh --verify-only` |

---

## Success Criteria

### Verification Commands
```bash
./start-demo.sh --verify-only

status=$(git status -sb); printf '%s\n' "$status"; [[ "$status" != *"[ahead "* ]]

for i in 1 2 3 4 5; do
  out=$(PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_hit_stop_scale_stability.gd" 2>&1)
  [[ "$out" == *"QA_HIT_STOP_SCALE_STABILITY_OK"* ]] && [[ "$out" != *"ObjectDB instances leaked at exit"* ]] || exit 1
done

for i in 1 2 3 4 5; do
  out=$(PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_layout_metrics_scaling.gd" 2>&1)
  [[ "$out" == *"QA_LAYOUT_METRICS_SCALING_OK"* ]] && [[ "$out" != *"ObjectDB instances leaked at exit"* ]] || exit 1
done
```

### Final Checklist
- [ ] 所有 Must Have 满足
- [ ] 所有 Must NOT Have 未触发
- [ ] Phase A 与 Phase B 分离提交已执行
- [ ] 最终回归与分支同步状态均通过
