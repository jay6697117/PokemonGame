# Learnings

- 2026-02-12: QA scripts in this repo use deterministic uppercase tokens (for example `QA_*_OK`) plus machine-assertable counters (`KEY:VALUE`) for CI parsing.
- 2026-02-12: Asset-governance baseline works best when scanning `res://assets` recursively and ignoring hidden files/`.import`, so placeholder keep files do not produce false positives.

## Godot 4 Headless Theme Management
- Date: 2026-02-12
- Finding: `class_name` defined in scripts might not be globally available in headless execution if `project.godot` isn't updated by the editor. Using `preload("res://path/to/script.gd")` ensures scripts can find dependencies without relying on the global class cache.
- Finding: Code-driven UI (creating nodes in `_ready`) makes theme extraction very clean (search/replace constants), but harder to visualize than scene-based UI.

## Battle Scene Layering
- Date: 2026-02-12
- Finding: `Control` nodes respect tree order for drawing, making `_build_ui` logic simple (add to layer = sort correctly).
- Finding: Separating layout (VBox) from visuals (Arena) required a spacer approach in the VBox to maintain the layout while the actual Arena visual is in a different layer (`FighterLayer`).
