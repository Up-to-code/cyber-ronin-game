extends RefCounted
# Sole owner of the run save schema: coins, skill state and its atomic write.
# Callers pass the ConfigFile the HUD already loaded so display settings and
# progression share one file; this module never invents a second path.
const DEFAULT_PATH := "user://settings.cfg"
const PROGRESS_SECTION := "progress"
const SKILLS_SECTION := "skills"

var _file: ConfigFile
var _path: String
var _writer: Callable

func _init(file: ConfigFile = null, path: String = DEFAULT_PATH, writer: Callable = Callable()) -> void:
	_file = file if file != null else ConfigFile.new()
	_path = path
	_writer = writer if writer.is_valid() else _write_atomic

func coins() -> int:
	return int(_file.get_value(PROGRESS_SECTION, "coins", 0))

func set_coins(value: int) -> void:
	_file.set_value(PROGRESS_SECTION, "coins", value)

func skill_state() -> Dictionary:
	return _file.get_value(SKILLS_SECTION, "state", {}).duplicate(true)

func set_skill_state(state: Dictionary) -> void:
	_file.set_value(SKILLS_SECTION, "state", state.duplicate(true))

# Commit a candidate without publishing uncommitted values to the shared HUD file.
func commit_progress(wallet: int, state: Dictionary, target: String = _path) -> Error:
	var candidate := ConfigFile.new()
	var error: Error = candidate.parse(_file.encode_to_text())
	if error != OK: return error
	candidate.set_value(PROGRESS_SECTION, "coins", wallet)
	candidate.set_value(SKILLS_SECTION, "state", state.duplicate(true))
	error = _writer.call(candidate, target)
	if error != OK: return error
	set_coins(wallet)
	set_skill_state(state)
	return OK

func save(target: String = _path) -> Error:
	return _writer.call(_file, target)

# A sibling temp file keeps the previous save intact on write/rename failure.
func _write_atomic(file: ConfigFile, target: String) -> Error:
	var temporary := target + ".tmp"
	var error := file.save(temporary)
	if error != OK: return error
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target))
	if error != OK: DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary))
	return error
