# Pokemon KOF Phase-1 观感快升（竞技场动漫风）工作计划

## TL;DR

> **Quick Summary**: 在不改核心战斗规则的前提下，对当前 Godot 4 原型做一轮“可见且显著”的 UI + 视觉反馈升级。目标是从“占位演示”提升到“可被正常体验并有战斗氛围”的私有学习版。
>
> **Deliverables**:
> - 战斗界面重构（HUD 视觉层级、信息可读性、动画节奏）
> - 竞技场动漫风舞台层（背景、前景、氛围）
> - 角色视觉层升级（开源素材接入、镜像与命名显示）
> - 打击反馈系统（hit spark、受击闪白、相机抖动、短暂停顿）
> - 自动化视觉验收（视觉契约、素材许可、重开局视觉重置）
>
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 -> Task 3 -> Task 6 -> Task 8 -> Task 9

---

## Context

### Original Request
用户反馈当前效果“离希望的宝可梦对战差距太大”，要求在 UI 和游戏效果上显著提升。

### Interview Summary
**Key Discussions**:
- 阶段目标：`观感快升版`（优先快速拉高体验观感）。
- 风格方向：`竞技场动漫风`。
- 素材策略：`接入开源素材包`（CC0/开源资源）。
- 测试策略：`先实现后补测试`，并保持 Agent 可执行 QA。

### Metis Review
**Identified Gaps (addressed in this plan)**:
- 需显式锁死 scope，防止“顺手改玩法/加新模式”。
- 需加入素材许可治理（source/license/attribution 清单 + 自动检查）。
- 需把“视觉变好看”变成可执行验收（结构、token、重置、回归）。
- 需覆盖边界场景（重开局时残留特效、镜像角色可读性、资产缺失回退）。

---

## Work Objectives

### Core Objective
在保持现有玩法逻辑稳定的前提下，为战斗场景建立完整视觉表达层，让用户主观体验从“占位原型”提升到“可持续试玩”的动漫竞技场风格。

### Concrete Deliverables
- `scenes/battle.tscn` 升级为多层视觉结构（HUD 层、战斗层、特效层、转场层）。
- 新增视觉系统脚本与资源清单（`scripts/visual/*`, `assets/*`, `data/assets_manifest.json`）。
- 集成开源角色/特效素材（含 license 元数据）。
- 新增 QA 脚本：视觉契约、素材许可检查、占位视觉移除检查、重开视觉重置检查。

### Definition of Done
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `QA_PHASE1_VISUAL_CONTRACT_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_asset_license_manifest.gd` 输出 `QA_ASSET_LICENSE_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_placeholder_visuals_removed.gd` 输出 `QA_PLACEHOLDER_VISUALS_REMOVED_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_hit_feedback_pipeline.gd` 输出 `QA_HIT_FEEDBACK_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_rematch_visual_reset.gd` 输出 `QA_REMATCH_VISUAL_RESET_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_full_match_flow.gd` 仍输出 `QA_FULL_MATCH_FLOW_OK`。
- [x] `PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_regression_suite.gd` 仍输出 `QA_REGRESSION_OK`。

### Must Have
- 保持 60 FPS 固定步长核心逻辑，不改变战斗规则结算。
- 战斗观感升级后，仍可完整跑通“选角 -> 对战 -> 再来一局”。
- 素材来源与许可可追踪（manifest + 自动检查）。
- 每个任务具备 Agent 可执行验证，不依赖人工目测。
- Phase-1 范围以 battle 场景为主，主菜单/选角仅做最小风格一致性调整。

### Must NOT Have (Guardrails)
- 不改 `scripts/combat/*` 与 `scripts/match/round_manager.gd` 的业务规则（除非修 bug 且有明确记录）。
- 不新增联网、AI、剧情、训练模式、排位系统。
- 不扩增角色数量范围（仍按现阶段双角色原型）。
- 不引入官方宝可梦受版权保护素材。
- 不把 Phase-1 扩展成“全项目重做”。
- Phase-1 不包含 BGM/SFX 体系建设（避免范围膨胀）。

### 法律边界（强约束）
- 仅可用可再分发开源/免费素材（优先 CC0；若 CC-BY 必须记录 attribution）。
- `data/assets_manifest.json` 必须记录 `source_url`, `license`, `attribution_required`, `asset_path`。
- 默认允许许可：`CC0` 与 `CC-BY`（CC-BY 必须在清单标注署名要求）。

### 工程边界（强约束）
- 视觉层和逻辑层解耦：表现增强不侵入核心规则实现。
- 优先 scene 驱动结构，不继续在 `_build_ui()` 里堆叠全部控件逻辑。

### 验证边界（强约束）
- 所有验收通过命令行脚本断言 token/状态；零人工点击验收。

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> 所有任务验证必须由 Agent 自动执行；禁止“人工看看效果”。

### Test Decision
- **Infrastructure exists**: YES
- **Automated tests**: YES（先实现后补测试）
- **Framework**: Godot headless script harness（现有 `qa/*.gd` + `tests/run_all_tests.gd`）

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

| Deliverable Type | Tool | Verification Mode |
|---|---|---|
| Godot visual structure | Bash (`godot4 --headless`) | 加载场景树并断言节点/属性 |
| Asset governance | Bash (`godot4 --headless`) | 解析 manifest 并校验 license/source |
| Hit feedback pipeline | Bash (`godot4 --headless`) | 触发受击并断言特效/抖动/恢复状态 |
| Flow/regression | Bash (`godot4 --headless`) | 复用现有 QA token，确保无回归 |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: 素材治理与清单基线
└── Task 2: UI 主题变量与 HUD 组件风格基线

Wave 2 (After Wave 1):
├── Task 3: battle 场景层级重构
├── Task 4: 角色视觉层接入
└── Task 5: 舞台氛围层接入

Wave 3 (After Wave 2):
├── Task 6: 打击反馈系统（spark/flash/shake/hit-stop）
├── Task 7: 开场/KO/时间到转场表现
├── Task 8: rematch 视觉重置加固
└── Task 9: Phase-1 自动化 QA 与回归收口

Critical Path: 1 -> 3 -> 6 -> 8 -> 9
Parallel Speedup: ~35% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|---|---|---|---|
| 1 | None | 3, 4, 5, 9 | 2 |
| 2 | None | 3, 7 | 1 |
| 3 | 1, 2 | 4, 5, 6, 7, 8 | None |
| 4 | 1, 3 | 6, 8 | 5 |
| 5 | 1, 3 | 7 | 4 |
| 6 | 3, 4 | 8, 9 | 7 |
| 7 | 2, 3, 5 | 9 | 6 |
| 8 | 3, 4, 6 | 9 | None |
| 9 | 1, 6, 7, 8 | None | None |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|---|---|---|
| 1 | 1,2 | `task(category="visual-engineering", load_skills=["verification-before-completion"], run_in_background=false)` |
| 2 | 3,4,5 | `task(category="visual-engineering", load_skills=["frontend-ui-ux","systematic-debugging"], run_in_background=false)` |
| 3 | 6,7,8,9 | `task(category="unspecified-high", load_skills=["verification-before-completion","systematic-debugging"], run_in_background=false)` |

---

## TODOs

- [x] 1. 建立素材治理与许可清单基线

  **What to do**:
  - 建立 `assets/` 目录结构（fighters, vfx, stage, ui）。
  - 新建 `data/assets_manifest.json`，为每个资源登记来源与许可字段。
  - 新增脚本 `qa/qa_asset_license_manifest.gd` 检查清单完整性与禁用来源。

  **Must NOT do**:
  - 不导入来源不明素材。
  - 不省略 license/source 字段。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 法务风险与工程落地都在此任务收口。
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]
    - `verification-before-completion`: 强制脚本化 license 验收。
    - `systematic-debugging`: 处理 manifest 解析/路径错误。

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: 3,4,5,9
  - **Blocked By**: None

  **References**:
  - `qa/qa_private_prototype_guard.gd` - 现有法务 guard 的 token 风格参考。
  - `README.md` - 项目运行与验证命令入口。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_asset_license_manifest.gd` 输出 `QA_ASSET_LICENSE_OK`。
  - [x] 输出 `UNLICENSED_ASSETS:0` 与 `FORBIDDEN_OFFICIAL_ASSETS:0`。

- [x] 2. 建立竞技场动漫风 UI 主题基线

  **What to do**:
  - 抽离颜色、字号、边框、阴影参数到统一主题配置（脚本或 theme 资源）。
  - 统一 HUD 字体层级（标题/状态/计时/提示）。
  - 按风格定义 HP 条、timer、状态文本视觉规范。

  **Must NOT do**:
  - 不改 HP 与 timer 的业务计算逻辑。

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: 核心是 UI 风格系统化。
  - **Skills**: [`frontend-ui-ux`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: 3,7
  - **Blocked By**: None

  **References**:
  - `scripts/flow/battle_screen.gd` - 当前 UI 代码集中构建方式（待改造点）。
  - `scenes/ui/match_hud.tscn` - HUD 场景挂载入口。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `HUD_THEME_PROFILE:ANIME_ARENA`。

- [x] 3. 重构 battle 场景为可扩展视觉层级

  **What to do**:
  - 将 `scenes/battle.tscn` 拆为明确层：`BackgroundLayer`, `FighterLayer`, `VfxLayer`, `HudLayer`, `OverlayLayer`。
  - 保留现有输入/结算入口，不改流程接口。
  - 场景层节点命名固定，供 QA 结构检查。

  **Must NOT do**:
  - 不删除 rematch 与 back menu 功能入口。

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: 4,5,6,7,8
  - **Blocked By**: 1,2

  **References**:
  - `scenes/battle.tscn` - 当前仅根节点挂脚本，需结构化。
  - `scripts/flow/battle_screen.gd` - 当前 UI 与战斗表现混合，需解耦。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `REQUIRED_NODES_PRESENT:true`。

- [x] 4. 接入开源角色视觉层（双角色 + 镜像可读）

  **What to do**:
  - 为两名角色接入开源 sprite/animation 资源。
  - 保持与 `GameSession` 的角色名同步显示。
  - 镜像对战下仍可区分 P1/P2（描边/颜色标识）。

  **Must NOT do**:
  - 不修改 `data/roster.json` 的核心 schema 契约。

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`frontend-ui-ux`, `systematic-debugging`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 5)
  - **Blocks**: 6,8
  - **Blocked By**: 1,3

  **References**:
  - `scripts/game_session.gd` - 角色名来源。
  - `scripts/flow/character_select_screen.gd` - 选角传参路径。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `FIGHTER_VISUALS_BOUND:true`。

- [x] 5. 接入竞技场舞台氛围层（背景/前景/轻动效）

  **What to do**:
  - 新增舞台背景、前景装饰与轻量动画（循环可控）。
  - 保证战斗对象可读性优先（不抢角色轮廓）。

  **Must NOT do**:
  - 不引入高成本特效导致明显掉帧。

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`frontend-ui-ux`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 4)
  - **Blocks**: 7
  - **Blocked By**: 1,3

  **References**:
  - `scripts/flow/battle_screen.gd` - 现有 arena 占位背景逻辑。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `STAGE_ATMOSPHERE_ACTIVE:true`。

- [x] 6. 打击反馈系统升级（Spark/Flash/Shake/Hit-stop）

  **What to do**:
  - 每次命中触发 hit spark 与受击闪白。
  - 加入轻量 camera shake 与极短 hit-stop（仅表现层）。
  - 保证反馈可在 rematch 后正确复位。

  **Must NOT do**:
  - 不改变 `damage`、`hitstun` 业务值。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 7)
  - **Blocks**: 8,9
  - **Blocked By**: 3,4

  **References**:
  - `scripts/combat/damage/hit_resolution_service.gd` - 命中点接入（只挂表现触发）。
  - `qa/qa_hitbox_hurtbox_resolution.gd` - 命中行为回归基线。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_hit_feedback_pipeline.gd` 输出 `QA_HIT_FEEDBACK_OK`。
  - [x] 输出 `HIT_TO_VFX_RATIO:1.00`（命中事件与反馈事件一一对应）。

- [x] 7. 回合表现升级（ROUND/FIGHT/KO/TIME UP）

  **What to do**:
  - 开场、KO、时间到的文案与动画统一风格。
  - 保持信息优先级（状态文本不遮挡关键操作区域）。

  **Must NOT do**:
  - 不改回合胜负判定逻辑。

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`frontend-ui-ux`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 6)
  - **Blocks**: 9
  - **Blocked By**: 2,3,5

  **References**:
  - `scripts/flow/battle_screen.gd` - `_start_intro_sequence`, `_finish_match` 现有入口。
  - `qa/qa_round_ko_flow.gd` - 回合 KO 回归基线。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` 输出 `ROUND_TRANSITION_STYLE_OK`。

- [x] 8. Rematch 视觉重置加固

  **What to do**:
  - rematch 后清空激活特效节点、恢复相机偏移/缩放、重置角色材质临时状态。
  - 防止“上一局残留效果”污染下一局。

  **Must NOT do**:
  - 不破坏现有 `QA_REMATCH_RESET_OK` 逻辑语义。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: [`systematic-debugging`, `verification-before-completion`]

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: 9
  - **Blocked By**: 3,4,6

  **References**:
  - `scripts/flow/battle_screen.gd` - `_reset_match()` 当前重置入口。
  - `qa/qa_rematch_state_reset.gd` - 现有重置断言风格。

  **Acceptance Criteria**:
  - [x] `godot4 --headless --path . --script res://qa/qa_rematch_visual_reset.gd` 输出 `QA_REMATCH_VISUAL_RESET_OK`。
  - [x] 输出 `ACTIVE_VFX_NODES_AFTER_RESET:0`。

- [x] 9. 新增 Phase-1 验收脚本并回归收口

  **What to do**:
  - 新增脚本：
    - `qa/qa_phase1_visual_contract.gd`
    - `qa/qa_asset_license_manifest.gd`
    - `qa/qa_placeholder_visuals_removed.gd`
    - `qa/qa_hit_feedback_pipeline.gd`
    - `qa/qa_rematch_visual_reset.gd`
  - 把 Phase-1 脚本并入 `start-demo.sh --verify-only` 的可扩展检查。
  - 复跑原有关键回归，确保无回退。

  **Must NOT do**:
  - 不移除或弱化原有 `QA_FULL_MATCH_FLOW_OK` / `QA_REGRESSION_OK` / `TESTS_ALL_PASS`。

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: [`verification-before-completion`, `systematic-debugging`]

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Final Sequential
  - **Blocks**: None
  - **Blocked By**: 1,6,7,8

  **References**:
  - `qa/qa_full_match_flow.gd` - token 与流程断言模板。
  - `qa/qa_regression_suite.gd` - 多 case 汇总脚本模板。
  - `tests/run_all_tests.gd` - 统一测试入口样式。
  - `start-demo.sh` - 一键验证流程。

  **Acceptance Criteria**:
  - [x] `./start-demo.sh --verify-only` 输出 `DEMO_CHECKLIST_PASS`。
  - [x] 包含新增 Phase-1 token 与原有 token 全通过。

---

## Commit Strategy

| After Task | Message | Files | Verification |
|---|---|---|---|
| 1 | `chore(assets): add asset manifest and license checks` | `assets/*`, `data/assets_manifest.json`, `qa/qa_asset_license_manifest.gd` | `godot4 --headless --path . --script res://qa/qa_asset_license_manifest.gd` |
| 2-3 | `feat(ui): restructure battle scene and anime arena hud` | `scenes/battle.tscn`, `scripts/flow/battle_screen.gd`, `scenes/ui/*` | `godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd` |
| 4-5 | `feat(visual): add fighter visuals and arena atmosphere` | `assets/fighters/*`, `assets/stage/*`, `scripts/visual/*` | `godot4 --headless --path . --script res://qa/qa_placeholder_visuals_removed.gd` |
| 6-8 | `feat(feedback): implement hit fx and rematch visual reset` | `scripts/visual/*`, `qa/qa_hit_feedback_pipeline.gd`, `qa/qa_rematch_visual_reset.gd` | `godot4 --headless --path . --script res://qa/qa_hit_feedback_pipeline.gd` |
| 9 | `test(qa): add phase1 visual contract and regression gates` | `qa/*`, `start-demo.sh` | `./start-demo.sh --verify-only` |

---

## Success Criteria

### Verification Commands

```bash
PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_phase1_visual_contract.gd
# Expected: QA_PHASE1_VISUAL_CONTRACT_OK

PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_asset_license_manifest.gd
# Expected: QA_ASSET_LICENSE_OK

PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_placeholder_visuals_removed.gd
# Expected: QA_PLACEHOLDER_VISUALS_REMOVED_OK

PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_hit_feedback_pipeline.gd
# Expected: QA_HIT_FEEDBACK_OK

PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script res://qa/qa_rematch_visual_reset.gd
# Expected: QA_REMATCH_VISUAL_RESET_OK

./start-demo.sh --verify-only
# Expected: DEMO_CHECKLIST_PASS
```

### Final Checklist
- [x] UI/HUD 视觉明显升级（结构与主题已替换占位实现）。
- [x] 角色视觉与舞台氛围完成开源素材接入并通过许可检查。
- [x] 命中反馈与转场表现可自动化断言通过。
- [x] rematch 视觉重置无残留。
- [x] 现有核心回归 token 全部保持通过。
