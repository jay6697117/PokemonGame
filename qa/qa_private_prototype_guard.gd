extends SceneTree

const FORBIDDEN_RELEASE_FILES := [
	"res://export_presets.cfg",
	"res://.github/workflows/release.yml",
	"res://.github/workflows/publish.yml",
	"res://.github/workflows/deploy.yml",
]

func _init() -> void:
	for path in FORBIDDEN_RELEASE_FILES:
		if FileAccess.file_exists(path):
			printerr("Forbidden release pipeline file exists: %s" % path)
			quit(1)
			return

	print("QA_PRIVATE_GUARD_OK")
	print("PUBLIC_RELEASE_STEPS_PRESENT:false")
	quit(0)
