extends SceneTree

const MANIFEST_PATH := "res://data/assets_manifest.json"
const ASSETS_ROOT := "res://assets"
const ALLOWED_LICENSES := ["CC0", "CC-BY"]
const FORBIDDEN_OFFICIAL_TERMS := [
	"pokemon",
	"nintendo",
	"gamefreak",
	"thepokemoncompany",
	"pokemon.com",
]

func _init() -> void:
	var manifest_result := _load_manifest(MANIFEST_PATH)
	if not bool(manifest_result.get("ok", false)):
		printerr(str(manifest_result.get("error", "Failed to load asset manifest")))
		quit(1)
		return

	var assets: Array = manifest_result.get("assets", [])
	var validation_result := _validate_manifest_entries(assets)

	var unlicensed_assets := int(validation_result.get("unlicensed_assets", 0))
	var forbidden_official_assets := int(validation_result.get("forbidden_official_assets", 0))
	var tracked_manifest_paths: Dictionary = validation_result.get("tracked_manifest_paths", {})

	var discovered_assets := _collect_asset_files(ASSETS_ROOT)
	for asset_path in discovered_assets:
		if not tracked_manifest_paths.has(asset_path):
			unlicensed_assets += 1
			printerr("Missing manifest entry for asset: %s" % asset_path)
		if _contains_forbidden_official_terms(asset_path):
			forbidden_official_assets += 1
			printerr("Forbidden official asset path detected: %s" % asset_path)

	print("UNLICENSED_ASSETS:%d" % unlicensed_assets)
	print("FORBIDDEN_OFFICIAL_ASSETS:%d" % forbidden_official_assets)

	if unlicensed_assets != 0 or forbidden_official_assets != 0:
		quit(1)
		return

	print("QA_ASSET_LICENSE_OK")
	quit(0)

func _load_manifest(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {
			"ok": false,
			"error": "Asset manifest missing: %s" % path,
		}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"error": "Failed to open asset manifest: %s" % path,
		}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_text) != OK:
		return {
			"ok": false,
			"error": "Asset manifest JSON parse failed: %s" % path,
		}

	if not (json.data is Dictionary):
		return {
			"ok": false,
			"error": "Asset manifest root must be Dictionary: %s" % path,
		}

	var manifest: Dictionary = json.data
	if not (manifest.get("assets") is Array):
		return {
			"ok": false,
			"error": "Asset manifest 'assets' must be Array: %s" % path,
		}

	return {
		"ok": true,
		"assets": manifest.get("assets", []),
	}

func _validate_manifest_entries(assets: Array) -> Dictionary:
	var unlicensed_assets := 0
	var forbidden_official_assets := 0
	var tracked_manifest_paths := {}

	for i in assets.size():
		var entry = assets[i]
		if not (entry is Dictionary):
			unlicensed_assets += 1
			printerr("Manifest entry %d must be Dictionary" % i)
			continue

		var entry_dict: Dictionary = entry
		var required_fields := ["source_url", "license", "attribution_required", "asset_path"]
		var missing_field := ""
		for field_name in required_fields:
			if not entry_dict.has(field_name):
				missing_field = field_name
				break
		if missing_field != "":
			unlicensed_assets += 1
			printerr("Manifest entry %d missing field: %s" % [i, missing_field])
			continue

		var source_url := str(entry_dict.get("source_url", "")).strip_edges()
		var license := str(entry_dict.get("license", "")).strip_edges()
		var asset_path := str(entry_dict.get("asset_path", "")).strip_edges()
		var attribution_raw = entry_dict.get("attribution_required")

		if source_url == "":
			unlicensed_assets += 1
			printerr("Manifest entry %d has empty source_url" % i)

		if asset_path == "" or not asset_path.begins_with("res://assets/"):
			unlicensed_assets += 1
			printerr("Manifest entry %d has invalid asset_path: %s" % [i, asset_path])
		else:
			if tracked_manifest_paths.has(asset_path):
				unlicensed_assets += 1
				printerr("Duplicate manifest asset_path: %s" % asset_path)
			tracked_manifest_paths[asset_path] = true

		if not ALLOWED_LICENSES.has(license):
			unlicensed_assets += 1
			printerr("Manifest entry %d has disallowed license: %s" % [i, license])

		if not (attribution_raw is bool):
			unlicensed_assets += 1
			printerr("Manifest entry %d attribution_required must be bool" % i)
		else:
			var attribution_required: bool = attribution_raw
			if license == "CC-BY" and not attribution_required:
				unlicensed_assets += 1
				printerr("Manifest entry %d must set attribution_required=true for CC-BY" % i)

		if _contains_forbidden_official_terms(asset_path) or _contains_forbidden_official_terms(source_url):
			forbidden_official_assets += 1
			printerr("Manifest entry %d uses forbidden official source reference" % i)

	return {
		"unlicensed_assets": unlicensed_assets,
		"forbidden_official_assets": forbidden_official_assets,
		"tracked_manifest_paths": tracked_manifest_paths,
	}

func _collect_asset_files(root_path: String) -> Array[String]:
	var collected: Array[String] = []
	_scan_asset_files(root_path, collected)
	collected.sort()
	return collected

func _scan_asset_files(current_path: String, output: Array[String]) -> void:
	var dir := DirAccess.open(current_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue

		var child_path := "%s/%s" % [current_path, name]
		if dir.current_is_dir():
			_scan_asset_files(child_path, output)
		else:
			if not child_path.ends_with(".import"):
				output.append(child_path)

		name = dir.get_next()

	dir.list_dir_end()

func _contains_forbidden_official_terms(value: String) -> bool:
	var normalized := value.to_lower().replace("-", "").replace("_", "").replace(" ", "")
	for term in FORBIDDEN_OFFICIAL_TERMS:
		if normalized.find(term) != -1:
			return true
	return false
