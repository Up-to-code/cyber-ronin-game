class_name StoryBook
extends RefCounted
## Read-only narrative data. Game flow owns when to show it and how progress saves.
const DATA_PATH: String = "res://data/story.json"
static var _data: Dictionary = {}

static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if parsed is Dictionary:
			_data = parsed
	return _data.duplicate(true)

static func chapter_count() -> int:
	return preload("res://data/campaign.gd").levels().size()

static func get_chapter(index: int) -> Dictionary:
	var route: Dictionary = preload("res://data/campaign.gd").get_level(index)
	if not route.is_empty():
		return {"id":index,"name":route.name,"title":route.chapter_name,"location":route.chapter_name,"body":route.objective,"objective":route.objective}
	for chapter in data().get("chapters", []):
		if int(chapter.get("id", 0)) == index:
			return chapter.duplicate(true)
	return {}

static func objective(index: int) -> String:
	return str(get_chapter(index).get("objective", ""))

static func completion() -> Dictionary:
	return data().get("ending", {}).duplicate(true)
