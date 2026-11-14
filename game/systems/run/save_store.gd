extends RefCounted
# Sole owner of the run save schema: coins, skill state and its atomic write.
# Callers pass the ConfigFile the HUD already loaded so display settings and
# progression share one file; this module never invents a second path.
const DEFAULT_PATH := "user://settings.cfg"
const PROGRESS_SECTION := "progress"
const SKILLS_SECTION := "skills"

var _file: ConfigFile
var _path: String

func _init(file: ConfigFile = null, path: String = DEFAULT_PATH) -> void:
	_file = file if file != null else ConfigFile.new()
	_path = path

func coins() -> int:
	return int(_file.get_value(PROGRESS_SECTION, "coins", 0))

func set_coins(value: int) -> void:
	_file.set_value(PROGRESS_SECTION, "coins", value)

func skill_state() -> Dictionary:
	return _file.get_value(SKILLS_SECTION, "state", {})

func set_skill_state(state: Dictionary) -> void:
	_file.set_value(SKILLS_SECTION, "state", state)

# Write to a sibling temp file, then rename so a crash never truncates the save.
# The path is a parameter so a caller with its own settings file never mutates us.
func save(target: String = _path) -> Error:
	var temporary := target + ".tmp"
	var error := _file.save(temporary)
	if error != OK:
		return error
	return DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary),
		ProjectSettings.globalize_path(target))
