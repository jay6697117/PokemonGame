# Learnings

## Godot 4 Headless Theme Management
- Date: 2026-02-12
- Finding: `class_name` defined in scripts might not be globally available in headless execution if `project.godot` isn't updated by the editor. Using `preload("res://path/to/script.gd")` ensures scripts can find dependencies without relying on the global class cache.
- Finding: Code-driven UI (creating nodes in `_ready`) makes theme extraction very clean (search/replace constants), but harder to visualize than scene-based UI.
