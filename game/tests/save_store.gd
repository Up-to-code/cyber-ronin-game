extends SceneTree
const SaveStore = preload("res://systems/run/save_store.gd")
func _initialize(): call_deferred("run")
func run():
	var path := "user://save_store_test.cfg"
	var file := ConfigFile.new()
	var store = SaveStore.new(file, path)
	store.set_coins(42)
	store.set_skill_state({"tide": 2})
	assert(store.save() == OK, "save must write the temp file and rename it")
	assert(not FileAccess.file_exists(path + ".tmp"), "temp file must not survive")
	var reloaded := ConfigFile.new()
	assert(reloaded.load(path) == OK)
	var read_back = SaveStore.new(reloaded, path)
	assert(read_back.coins() == 42, "coins must round-trip")
	assert(int(read_back.skill_state().get("tide", 0)) == 2, "skill state must round-trip")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS save store schema and atomic write")
	quit()
