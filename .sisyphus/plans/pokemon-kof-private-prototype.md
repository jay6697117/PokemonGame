# Pokemon KOF 私有原型（Godot 4）工作计划

## TL;DR

> **Quick Summary**: 基于 Godot 4 从零搭建一个“宝可梦题材、拳皇风格”的本地双人 2D 对战私有学习原型。先做可完整打完一局的 MVP 闭环，再补自动化测试。
>
> **Deliverables**:
> - Godot 4 项目骨架（可 headless 运行）
> - 本地 1v1 对战核心（状态机、输入缓冲、判定、回合）
> - 2 个可选角色（占位素材 + 宝可梦数据参考）
> - 自动化 QA 脚本与回归测试脚本（全 Agent 可执行）
>
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 -> Task 2 -> Task 4 -> Task 5 -> Task 7 -> Task 8

---

## Context

### Original Request
调研宝可梦宠物小精灵角色，制作一款类似拳皇的宠物小精灵对战游戏。

### Interview Summary
**Key Discussions**:
- 交付目标确认：`私有学习原型`，不以公开分发为目标。
- 引擎确认：`Godot 4`。
- 玩法范围确认：`MVP核心包`（本地双人 1v1、2 角色、移动/跳跃/蹲防/轻重攻击、受击硬直、HP/回合/KO、角色选择）。
- 素材策略确认：`占位素材 + 宝可梦数据参考`。
- 测试策略确认：`先实现后补自动化测试`，且每个任务都必须有 Agent 执行 QA 场景。

**Research Findings**:
- 本地仓库是绿地空项目（只有空 `README.md`），无现成架构可复用。
- 官方资料可用：PokeAPI 文档、Pokemon 法务条款、Godot 官方输入/动画/碰撞文档。
- 参考实现：Ikemen-GO、Sakuga-Engine、Castagne、OpenOMF、Backdash。

### Metis Review
**Identified Gaps (addressed)**:
- 需要把法务、工程、验证边界显式锁死 -> 已加入全局 Guardrails。
- 需要防止 scope creep（联网、AI、超必杀等）-> 已列入 Must NOT Have。
- 需要统一可执行验收模板 -> 每任务附 `godot4 --headless` QA 命令与断言 token。
- 需补全边界场景 -> 已加入双 KO、时间到平局、输入竞争、角落推退等场景验证。

---

## Work Objectives

### Core Objective
构建一个可完整对战的 Godot 4 私有原型：从角色选择进入战斗，支持本地双人对战并完成 KO/回合结算与再来一局流程，且全流程可由 Agent 自动验证。

### Concrete Deliverables
- `project.godot` 及核心目录：`scenes/`, `scripts/`, `data/`, `qa/`, `tests/`。
- 战斗核心模块：输入映射、状态机、判定系统、伤害系统、回合系统。
- 角色/招式数据：2 个角色（占位素材）+ 外部数据驱动配置。
- 自动化验证：QA 脚本、回归脚本、测试报告输出。

### Definition of Done
- [x] 执行 `godot4 --headless --path . --script res://qa/qa_full_match_flow.gd` 输出 `QA_FULL_MATCH_FLOW_OK`。
- [x] 执行 `godot4 --headless --path . --script res://qa/qa_regression_suite.gd` 输出 `QA_REGRESSION_OK`。
- [x] 执行 `godot4 --headless --path . --script res://tests/run_all_tests.gd` 输出 `TESTS_ALL_PASS`。

### Must Have
- 60 FPS 固定步长模拟（战斗逻辑一致性优先）。
- 本地双人同机可完整打完一场（选角 -> 对战 -> KO/回合 -> 结算）。
- 2 个角色可选（允许同角色镜像对战）。
- 全任务 Agent 自动执行 QA，不要求人工点击验证。

### Must NOT Have (Guardrails)
- 不做联网/rollback/匹配/观战。
- 不做 AI 对手、剧情模式、训练模式。
- 不做超必杀、复杂取消系统、能量槽系统。
- 不使用官方宝可梦图像/音频/Logo 资源（仅占位素材 + 数据参考）。
- 不做公开分发流程（不作为本计划验收目标）。

### 法律边界（强约束）
- 仅用于本地私有学习原型。
- 不将官方素材打包到可发布构建中。
- 不在计划内包含公开仓库发布与商用步骤。

### 工程边界（强约束）
- 仅 Godot 4 单机本地对战。
- 架构采用 data-driven hybrid，不提前做通用编辑器平台化。

### 验证边界（强约束）
- 所有验收必须可命令行执行并可机器断言（token/退出码/状态值）。

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> 所有任务验收必须由 Agent 执行完成，不允许“用户手动点点看”。

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: YES（先实现后补测试）
- **Framework**: Godot headless script harness（自定义测试运行器）

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

**Verification Tool by Deliverable Type**:

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| Godot gameplay logic | Bash (`godot4 --headless`) | 执行 QA 脚本，断言 token 与退出码 |
| Input/state transitions | Bash (`godot4 --headless`) | 回放输入序列，检查状态与帧结果 |
| Data validation | Bash (`godot4 --headless`) | 加载角色/招式数据，断言 schema 与错误处理 |

**Scenario Format**:

```
Scenario: [场景名称]
  Tool: Bash (godot4 --headless)
  Preconditions: [运行前置条件]
  Steps:
    1. [执行具体命令]
    2. [检查输出 token]
    3. [检查退出码/状态]
  Expected Result: [明确可观测结果]
  Failure Indicators: [失败指示]
  Evidence: [.sisyphus/evidence/...]
```

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: 项目骨架与运行基线
└── Task 6: 角色/招式数据 schema 与选角数据结构

Wave 2 (After Wave 1):
├── Task 2: 战斗状态机与固定步长
├── Task 3: 输入映射与输入缓冲
└── Task 4: 判定框与命中结算

Wave 3 (After Wave 2):
├── Task 5: 回合系统与 HUD
├── Task 7: 全流程整合（选角->对战->结算）
└── Task 8: 自动化测试与回归

Critical Path: 1 -> 2 -> 4 -> 5 -> 7 -> 8
Parallel Speedup: ~35% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|----------------------|
| 1 | None | 2, 3, 4, 5, 7, 8 | 6 |
| 2 | 1 | 4, 5, 7 | 3 |
| 3 | 1 | 4, 7 | 2 |
| 4 | 1, 2, 3 | 5, 7 | None |
| 5 | 2, 4 | 7 | None |
| 6 | 1 | 7 | None |
| 7 | 3, 4, 5, 6 | 8 | None |
| 8 | 7 | None | None |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|--------------------|
| 1 | 1, 6 | `task(category="unspecified-high", load_skills=["verification-before-completion"], run_in_background=false)` |
| 2 | 2, 3, 4 | `task(category="unspecified-high", load_skills=["systematic-debugging"], run_in_background=false)` |
| 3 | 5, 7, 8 | `task(category="unspecified-high", load_skills=["verification-before-completion"], run_in_background=false)` |

---

## TODOs

- [x] 1. 初始化 Godot 4 项目骨架与运行基线

  **What to do**:
  - 创建目录：`scenes/`, `scripts/`, `data/`, `qa/`, `tests/`, `.sisyphus/evidence/`。
  - 建立 `project.godot` 与基础入口场景（空菜单 + 可进入选角场景）。
  - 配置基础 InputMap（P1/P2 上下左右、轻攻、重攻、防御）。
  - 建立全局配置脚本（帧率、默认血量、回合时长、BO3）。

  **Must NOT do**:
  - 不加入联网代码。
  - 不引入官方宝可梦素材文件。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 需要一次性搭建可持续扩展的项目基线。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: 确保每一步都可命令验证。
    - `systematic-debugging`: 快速定位初始化失败问题。
  - **Skills Evaluated but Omitted**:
    - `frontend-design`: 非核心需求，当前不是网页 UI 设计任务。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 6)
  - **Blocks**: 2, 3, 4, 5, 7, 8
  - **Blocked By**: None

  **References**:
  - `README.md` - 当前仓库为空，说明需完整 bootstrap。
  - `https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html` - InputMap 动作映射参考。
  - `https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html` - 后续状态机动画连接基础。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --quit` 退出码为 0。
  - [x] `godot4 --headless --path . --script res://qa/qa_project_bootstrap.gd` 输出 `QA_PROJECT_BOOTSTRAP_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Project boots in headless mode
    Tool: Bash (godot4 --headless)
    Preconditions: Godot 4 installed, repo at project root
    Steps:
      1. Run: godot4 --headless --path . --quit
      2. Assert: exit code == 0
      3. Run: godot4 --headless --path . --script res://qa/qa_project_bootstrap.gd
      4. Assert: stdout contains "QA_PROJECT_BOOTSTRAP_OK"
    Expected Result: Project starts and baseline config exists
    Failure Indicators: non-zero exit, missing token, parser error
    Evidence: .sisyphus/evidence/task-1-bootstrap.log

  Scenario: Missing autoload fails gracefully
    Tool: Bash (godot4 --headless)
    Preconditions: qa_missing_autoload.gd simulates missing singleton
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_missing_autoload.gd
      2. Assert: stdout contains "QA_MISSING_AUTOLOAD_HANDLED"
      3. Assert: exit code == 0
    Expected Result: Engine reports controlled failure path
    Failure Indicators: crash, stack trace without handled token
    Evidence: .sisyphus/evidence/task-1-missing-autoload.log
  ```

  **Commit**: YES
  - Message: `chore(godot): bootstrap project skeleton and baseline config`
  - Files: `project.godot`, `scenes/*`, `scripts/*`, `qa/qa_project_bootstrap.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_project_bootstrap.gd`

- [x] 2. 实现战斗状态机与固定步长主循环

  **What to do**:
  - 建立 Fighter 状态机：`idle`, `move`, `jump`, `crouch`, `attack`, `hitstun`, `ko`。
  - 统一 60 FPS 固定步长模拟（战斗逻辑与渲染解耦）。
  - 编写状态迁移规则表与非法迁移拦截。

  **Must NOT do**:
  - 不引入复杂取消系统（仅保留基础过渡）。
  - 不加入 AI 行为树。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 核心战斗逻辑，错误代价高。
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]
    - `systematic-debugging`: 处理状态抖动/非法迁移。
    - `verification-before-completion`: 验证帧步一致性。
  - **Skills Evaluated but Omitted**:
    - `brainstorming`: 需求已冻结，此阶段是执行型任务。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 3)
  - **Blocks**: 4, 5, 7
  - **Blocked By**: 1

  **References**:
  - `https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html` - Godot 状态机参数与迁移。
  - `https://github.com/NoisyChain/Sakuga-Engine` - 格斗状态结构参考（Godot4/C#）。
  - `https://github.com/ikemen-engine/Ikemen-GO` - 状态定义与帧驱动思路参考。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_state_machine_transitions.gd` 输出 `QA_STATE_MACHINE_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_fixed_tick_determinism.gd` 输出 `QA_FIXED_TICK_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Legal transitions produce expected states
    Tool: Bash (godot4 --headless)
    Preconditions: fighter state machine module loaded
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_state_machine_transitions.gd
      2. Assert: stdout contains "QA_STATE_MACHINE_OK"
      3. Assert: stdout contains "IDLE->MOVE->ATTACK->HITSTUN->IDLE"
    Expected Result: transitions match ruleset
    Failure Indicators: missing transition trace or panic
    Evidence: .sisyphus/evidence/task-2-state-machine.log

  Scenario: Illegal transition is blocked
    Tool: Bash (godot4 --headless)
    Preconditions: invalid transition test enabled
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_invalid_transition_guard.gd
      2. Assert: stdout contains "QA_INVALID_TRANSITION_GUARD_OK"
      3. Assert: stdout contains "BLOCKED: KO->ATTACK"
    Expected Result: illegal transition does not mutate state
    Failure Indicators: state changed to invalid target
    Evidence: .sisyphus/evidence/task-2-invalid-transition.log
  ```

  **Commit**: YES
  - Message: `feat(combat): add fighter state machine and fixed-tick loop`
  - Files: `scripts/combat/*`, `qa/qa_state_machine_transitions.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_fixed_tick_determinism.gd`

- [x] 3. 实现输入映射与输入缓冲（基础连段前置能力）

  **What to do**:
  - 实现 P1/P2 独立输入通道（本地双人）。
  - 建立输入缓冲窗口（默认 6 帧）与方向序列识别（仅基础）。
  - 处理窗口失焦后的输入清理，避免“按键粘连”。

  **Must NOT do**:
  - 不实现复杂招式指令库（如 236236P）。
  - 不做手柄适配扩展（V1 仅键盘+键盘）。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 输入系统直接决定手感与可玩性。
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]
    - `systematic-debugging`: 输入竞态与边界帧 bug 常见。
    - `verification-before-completion`: 保障输入脚本可回放验证。
  - **Skills Evaluated but Omitted**:
    - `agent-browser`: 无浏览器交互需求。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 2)
  - **Blocks**: 4, 7
  - **Blocked By**: 1

  **References**:
  - `https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html` - 输入轮询与事件处理。
  - `https://github.com/NoisyChain/Sakuga-Engine` - 输入历史与缓冲消费思路。
  - `https://github.com/panthavma/castagne` - 输入窗口与动作触发分层思路。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_input_buffer.gd` 输出 `QA_INPUT_BUFFER_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_focus_loss_input_reset.gd` 输出 `QA_INPUT_RESET_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Buffered input executes on first valid frame
    Tool: Bash (godot4 --headless)
    Preconditions: state machine in recovery state then returns to idle
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_input_buffer.gd
      2. Assert: stdout contains "QA_INPUT_BUFFER_OK"
      3. Assert: stdout contains "BUFFERED_ATTACK_TRIGGERED_AT_FRAME:"
    Expected Result: buffered action triggers exactly once at legal frame
    Failure Indicators: dropped input or repeated trigger
    Evidence: .sisyphus/evidence/task-3-input-buffer.log

  Scenario: Focus loss clears stuck keys
    Tool: Bash (godot4 --headless)
    Preconditions: test simulates focus lost + key held
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_focus_loss_input_reset.gd
      2. Assert: stdout contains "QA_INPUT_RESET_OK"
      3. Assert: stdout contains "STUCK_KEYS:0"
    Expected Result: no persistent pressed state after focus restore
    Failure Indicators: non-zero stuck key count
    Evidence: .sisyphus/evidence/task-3-focus-reset.log
  ```

  **Commit**: YES
  - Message: `feat(input): add dual-player input mapping and buffer logic`
  - Files: `scripts/input/*`, `qa/qa_input_buffer.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_input_buffer.gd`

- [x] 4. 实现判定框与命中结算（Hitbox/Hurtbox + Damage/Hitstun）

  **What to do**:
  - 建立 hitbox/hurtbox 数据结构与碰撞检测流程。
  - 实现命中后伤害、受击硬直、击退基础规则。
  - 防止同帧重复命中（同攻击实例只结算一次）。

  **Must NOT do**:
  - 不实现投技、抓投解、护甲系统。
  - 不做复杂受身/空中追击系统。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 判定系统是格斗游戏核心风险点。
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]
    - `systematic-debugging`: 处理碰撞时序与重复结算。
    - `verification-before-completion`: 要求 deterministic 输出。
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: 非 UI 美术任务。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: 5, 7
  - **Blocked By**: 1, 2, 3

  **References**:
  - `https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html` - Area2D 碰撞与层掩码。
  - `https://github.com/ikemen-engine/Ikemen-GO` - HitDef 与判定思路。
  - `https://github.com/NoisyChain/Sakuga-Engine` - hitbox/hurtbox 世界检测范式。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_hitbox_hurtbox_resolution.gd` 输出 `QA_HITBOX_RESOLUTION_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_single_hit_per_attack_instance.gd` 输出 `QA_SINGLE_HIT_GUARD_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Attack hit resolves damage and hitstun
    Tool: Bash (godot4 --headless)
    Preconditions: fighter A and B spawned at hittable distance
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_hitbox_hurtbox_resolution.gd
      2. Assert: stdout contains "QA_HITBOX_RESOLUTION_OK"
      3. Assert: stdout contains "HP_AFTER_HIT:"
      4. Assert: stdout contains "HITSTUN_FRAMES:"
    Expected Result: hit applies exactly configured damage and stun
    Failure Indicators: no collision or mismatched damage
    Evidence: .sisyphus/evidence/task-4-hit-resolution.log

  Scenario: Same attack frame cannot multi-hit unexpectedly
    Tool: Bash (godot4 --headless)
    Preconditions: multi-frame overlap forced by test setup
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_single_hit_per_attack_instance.gd
      2. Assert: stdout contains "QA_SINGLE_HIT_GUARD_OK"
      3. Assert: stdout contains "DAMAGE_APPLIED_COUNT:1"
    Expected Result: one attack instance applies one hit only
    Failure Indicators: count > 1 for same instance
    Evidence: .sisyphus/evidence/task-4-single-hit.log
  ```

  **Commit**: YES
  - Message: `feat(combat): implement hitbox hurtbox and hit resolution`
  - Files: `scripts/combat/collision/*`, `scripts/combat/damage/*`, `qa/qa_hitbox_hurtbox_resolution.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_hitbox_hurtbox_resolution.gd`

- [x] 5. 实现回合系统与 HUD（HP/Timer/KO/BO3）

  **What to do**:
  - 实现 BO3（先赢 2 回合）回合流程。
  - 默认参数：回合 60 秒、初始 HP 1000。
  - 时间到判定：HP 高者胜；HP 相同则该回合平局并重开。
  - HUD 显示：P1/P2 HP、回合数、倒计时。

  **Must NOT do**:
  - 不增加能量槽、超必杀 UI。
  - 不加入复杂镜头演出。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 涉及规则一致性与界面状态同步。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: 保证回合结算可自动断言。
    - `systematic-debugging`: 处理双 KO 与时间到边界。
  - **Skills Evaluated but Omitted**:
    - `ui-ux-pro-max`: 当前 HUD 以功能正确为优先。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: 7
  - **Blocked By**: 2, 4

  **References**:
  - `.sisyphus/drafts/pokemon-kof-fighting-game.md` - 已确认 MVP 边界与目标。
  - `https://github.com/omf2097/openomf` - 经典 2D 对战状态与回合处理参考。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_round_ko_flow.gd` 输出 `QA_ROUND_KO_FLOW_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_timeout_tie_rules.gd` 输出 `QA_TIMEOUT_TIE_RULE_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: KO increments round score and triggers next round
    Tool: Bash (godot4 --headless)
    Preconditions: deterministic damage script available
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_round_ko_flow.gd
      2. Assert: stdout contains "QA_ROUND_KO_FLOW_OK"
      3. Assert: stdout contains "ROUND_SCORE_P1:" or "ROUND_SCORE_P2:"
      4. Assert: stdout contains "NEXT_ROUND_STARTED"
    Expected Result: KO transitions to round-end and round-start correctly
    Failure Indicators: stuck state or wrong round counter
    Evidence: .sisyphus/evidence/task-5-round-ko.log

  Scenario: Timeout tie handled deterministically
    Tool: Bash (godot4 --headless)
    Preconditions: HP both equal at timeout frame
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_timeout_tie_rules.gd
      2. Assert: stdout contains "QA_TIMEOUT_TIE_RULE_OK"
      3. Assert: stdout contains "ROUND_RESTARTED_ON_TIE"
    Expected Result: tied timeout follows defined tie rule (restart round)
    Failure Indicators: random winner chosen or freeze
    Evidence: .sisyphus/evidence/task-5-timeout-tie.log
  ```

  **Commit**: YES
  - Message: `feat(match): add round manager and hud scoreboard`
  - Files: `scripts/match/*`, `scenes/ui/*`, `qa/qa_round_ko_flow.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_round_ko_flow.gd`

- [x] 6. 实现角色/招式数据 schema 与选角数据流程

  **What to do**:
  - 定义角色数据结构：名称、基础属性、动作集、判定参数。
  - 定义招式数据结构：startup/active/recovery、伤害、硬直、命中效果。
  - 实现角色选择数据流（支持镜像：P1/P2 可选同角色）。
  - 提供 2 个可玩角色数据（占位角色，宝可梦属性参考）。

  **Must NOT do**:
  - 不引入超过 2 个角色。
  - 不引入宝可梦官方素材文件。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 数据契约将影响后续扩展成本。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: schema 验证必须自动化。
    - `systematic-debugging`: 避免加载异常导致流程崩溃。
  - **Skills Evaluated but Omitted**:
    - `writing-skills`: 当前不是编写 Skill 文件任务。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: 7
  - **Blocked By**: 1

  **References**:
  - `https://pokeapi.co/docs/v2` - 角色属性参考来源（原型数据层）。
  - `https://github.com/ikemen-engine/Ikemen-GO` - 角色与选择数据组织方式参考。
  - `https://github.com/NoisyChain/Sakuga-Engine` - roster/fighter list 结构参考。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_roster_and_schema.gd` 输出 `QA_ROSTER_SCHEMA_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_invalid_character_data.gd` 输出 `QA_INVALID_CHARACTER_DATA_HANDLED`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Valid roster loads and allows mirror selection
    Tool: Bash (godot4 --headless)
    Preconditions: roster file has exactly 2 characters
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_roster_and_schema.gd
      2. Assert: stdout contains "QA_ROSTER_SCHEMA_OK"
      3. Assert: stdout contains "ROSTER_COUNT:2"
      4. Assert: stdout contains "MIRROR_SELECTION_ALLOWED:true"
    Expected Result: roster valid and selection flow accepts mirror
    Failure Indicators: parse error, count mismatch, mirror blocked
    Evidence: .sisyphus/evidence/task-6-roster.log

  Scenario: Invalid data fails with explicit error token
    Tool: Bash (godot4 --headless)
    Preconditions: test injects malformed fighter schema
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_invalid_character_data.gd
      2. Assert: stdout contains "QA_INVALID_CHARACTER_DATA_HANDLED"
      3. Assert: stdout contains "ERR_SCHEMA_FIELD_MISSING"
    Expected Result: invalid data rejected, app stays stable
    Failure Indicators: crash or silent fallback
    Evidence: .sisyphus/evidence/task-6-invalid-data.log
  ```

  **Commit**: YES
  - Message: `feat(data): add fighter move schema and roster selection`
  - Files: `data/*`, `scripts/roster/*`, `qa/qa_roster_and_schema.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_roster_and_schema.gd`

- [x] 7. 集成完整对战流程（选角 -> 对战 -> 结算 -> 再来一局）

  **What to do**:
  - 连接选角场景与战斗场景，传递角色配置。
  - 实现一局结束后的结果页与 rematch 入口。
  - 确保状态清理：重开局时 HP、计时、状态机、输入缓冲重置。

  **Must NOT do**:
  - 不新增剧情/训练/联网菜单。
  - 不加入超出 MVP 的角色成长系统。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 这是 MVP 闭环交付关键。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: 全链路可执行验收。
    - `systematic-debugging`: 集成期跨模块问题多。
  - **Skills Evaluated but Omitted**:
    - `dispatching-parallel-agents`: 本任务依赖强，不适合并行拆分。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: 8
  - **Blocked By**: 3, 4, 5, 6

  **References**:
  - `.sisyphus/drafts/pokemon-kof-fighting-game.md` - 需求冻结记录。
  - `https://github.com/ikemen-engine/Ikemen-GO` - 选角到对战流程组织参考。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_full_match_flow.gd` 输出 `QA_FULL_MATCH_FLOW_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_rematch_state_reset.gd` 输出 `QA_REMATCH_RESET_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: End-to-end match flow runs to completion
    Tool: Bash (godot4 --headless)
    Preconditions: all prior modules integrated
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_full_match_flow.gd
      2. Assert: stdout contains "QA_FULL_MATCH_FLOW_OK"
      3. Assert: stdout contains "FLOW:SELECT->FIGHT->RESULT->REMATCH"
    Expected Result: full loop executes without manual interaction
    Failure Indicators: scene dead-end, missing transition token
    Evidence: .sisyphus/evidence/task-7-full-flow.log

  Scenario: Rematch resets transient combat state
    Tool: Bash (godot4 --headless)
    Preconditions: previous round ended with non-default state
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_rematch_state_reset.gd
      2. Assert: stdout contains "QA_REMATCH_RESET_OK"
      3. Assert: stdout contains "HP_RESET:true"
      4. Assert: stdout contains "INPUT_BUFFER_CLEARED:true"
    Expected Result: rematch starts from clean state
    Failure Indicators: stale state contamination
    Evidence: .sisyphus/evidence/task-7-rematch-reset.log
  ```

  **Commit**: YES
  - Message: `feat(flow): integrate character select fight result rematch`
  - Files: `scenes/*`, `scripts/flow/*`, `qa/qa_full_match_flow.gd`
  - Pre-commit: `godot4 --headless --path . --script res://qa/qa_full_match_flow.gd`

- [x] 8. 补齐自动化测试与回归套件（Tests-after）

  **What to do**:
  - 建立 `res://tests/run_all_tests.gd` 作为统一测试入口。
  - 为核心模块补测试：状态机、输入缓冲、命中结算、回合规则。
  - 增加回归脚本：双 KO、时间到平局、非法数据、窗口失焦恢复。
  - 产出统一 token：`TESTS_ALL_PASS` 与 `QA_REGRESSION_OK`。

  **Must NOT do**:
  - 不引入与项目无关的第三方测试框架复杂依赖。
  - 不将“人工目测”写入任何验收项。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 需要系统化覆盖边界并固化回归入口。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: 保证测试输出可机器读取。
    - `systematic-debugging`: 处理 flaky/时序不稳测试。
  - **Skills Evaluated but Omitted**:
    - `test-driven-development`: 本项目已选择 tests-after。

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Final Sequential
  - **Blocks**: None
  - **Blocked By**: 7

  **References**:
  - `.sisyphus/plans/pokemon-kof-private-prototype.md` - 本计划所有验收标准。
  - `https://github.com/Delta3-Studio/Backdash` - 输入一致性与回归思想参考（不实现联网）。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://tests/run_all_tests.gd` 输出 `TESTS_ALL_PASS`。
  - [x] `godot4 --headless --path . --script res://qa/qa_regression_suite.gd` 输出 `QA_REGRESSION_OK`。
  - [x] `godot4 --headless --path . --script res://qa/qa_private_prototype_guard.gd` 输出 `QA_PRIVATE_GUARD_OK`。

  **Agent-Executed QA Scenarios**:

  ```bash
  Scenario: Full automated test suite passes
    Tool: Bash (godot4 --headless)
    Preconditions: test scripts implemented for core modules
    Steps:
      1. Run: godot4 --headless --path . --script res://tests/run_all_tests.gd
      2. Assert: stdout contains "TESTS_ALL_PASS"
      3. Assert: exit code == 0
    Expected Result: all module tests pass in one command
    Failure Indicators: missing token or non-zero exit
    Evidence: .sisyphus/evidence/task-8-tests-all.log

  Scenario: Regression suite catches edge-case regressions
    Tool: Bash (godot4 --headless)
    Preconditions: regression scripts include tie/double-KO/focus-loss/invalid-data
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_regression_suite.gd
      2. Assert: stdout contains "QA_REGRESSION_OK"
      3. Assert: stdout contains "EDGE_CASES:4/4"
    Expected Result: predefined edge cases remain stable
    Failure Indicators: any case missing or failed
    Evidence: .sisyphus/evidence/task-8-regression.log

  Scenario: Private-prototype legal guard check passes
    Tool: Bash (godot4 --headless)
    Preconditions: qa script checks forbidden release flags/assets
    Steps:
      1. Run: godot4 --headless --path . --script res://qa/qa_private_prototype_guard.gd
      2. Assert: stdout contains "QA_PRIVATE_GUARD_OK"
      3. Assert: stdout contains "PUBLIC_RELEASE_STEPS_PRESENT:false"
    Expected Result: no public release workflow is enabled in v1
    Failure Indicators: guard reports release/export/public pipeline present
    Evidence: .sisyphus/evidence/task-8-private-guard.log
  ```

  **Commit**: YES
  - Message: `test(core): add headless test runner and regression suite`
  - Files: `tests/*`, `qa/qa_regression_suite.gd`
  - Pre-commit: `godot4 --headless --path . --script res://tests/run_all_tests.gd`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `chore(godot): bootstrap project skeleton and baseline config` | `project.godot`, `scenes/*`, `scripts/*`, `qa/qa_project_bootstrap.gd` | `godot4 --headless --path . --script res://qa/qa_project_bootstrap.gd` |
| 2 | `feat(combat): add fighter state machine and fixed-tick loop` | `scripts/combat/*`, `qa/qa_state_machine_transitions.gd` | `godot4 --headless --path . --script res://qa/qa_fixed_tick_determinism.gd` |
| 3 | `feat(input): add dual-player input mapping and buffer logic` | `scripts/input/*`, `qa/qa_input_buffer.gd` | `godot4 --headless --path . --script res://qa/qa_input_buffer.gd` |
| 4 | `feat(combat): implement hitbox hurtbox and hit resolution` | `scripts/combat/collision/*`, `scripts/combat/damage/*` | `godot4 --headless --path . --script res://qa/qa_hitbox_hurtbox_resolution.gd` |
| 5 | `feat(match): add round manager and hud scoreboard` | `scripts/match/*`, `scenes/ui/*` | `godot4 --headless --path . --script res://qa/qa_round_ko_flow.gd` |
| 6 | `feat(data): add fighter move schema and roster selection` | `data/*`, `scripts/roster/*` | `godot4 --headless --path . --script res://qa/qa_roster_and_schema.gd` |
| 7 | `feat(flow): integrate character select fight result rematch` | `scenes/*`, `scripts/flow/*` | `godot4 --headless --path . --script res://qa/qa_full_match_flow.gd` |
| 8 | `test(core): add headless test runner and regression suite` | `tests/*`, `qa/qa_regression_suite.gd` | `godot4 --headless --path . --script res://tests/run_all_tests.gd` |

---

## Success Criteria

### Verification Commands

```bash
godot4 --version
# Expected: output starts with "4."

godot4 --headless --path . --quit
# Expected: exit code 0

godot4 --headless --path . --script res://qa/qa_full_match_flow.gd
# Expected: QA_FULL_MATCH_FLOW_OK

godot4 --headless --path . --script res://qa/qa_regression_suite.gd
# Expected: QA_REGRESSION_OK

godot4 --headless --path . --script res://tests/run_all_tests.gd
# Expected: TESTS_ALL_PASS

godot4 --headless --path . --script res://qa/qa_private_prototype_guard.gd
# Expected: QA_PRIVATE_GUARD_OK
```

### Final Checklist
- [x] 所有 Must Have 已实现。
- [x] 所有 Must NOT Have 未出现。
- [x] 所有 QA 脚本可由 Agent 自动执行并断言成功。
- [x] 可完整跑完“选角 -> 对战 -> 结算 -> 再来一局”闭环。

---

## External References (Authoritative)

- PokeAPI docs: `https://pokeapi.co/docs/v2`
- PokeAPI GraphQL docs: `https://pokeapi.co/docs/graphql`
- Pokemon legal: `https://www.pokemon.com/us/legal/`
- Pokemon terms: `https://www.pokemon.com/us/legal/terms-of-use/`
- Nintendo content guideline: `https://www.nintendo.co.jp/networkservice_guideline/en/index.html`
- Godot AnimationTree: `https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html`
- Godot Area2D physics: `https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html`
- Godot Input examples: `https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html`
- Ikemen-GO: `https://github.com/ikemen-engine/Ikemen-GO`
- Sakuga-Engine: `https://github.com/NoisyChain/Sakuga-Engine`
- Castagne: `https://github.com/panthavma/castagne`
- OpenOMF: `https://github.com/omf2097/openomf`
- Backdash: `https://github.com/Delta3-Studio/Backdash`
