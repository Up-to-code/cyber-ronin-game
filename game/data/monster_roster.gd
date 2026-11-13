class_name MonsterRoster
extends RefCounted
static var _records: Array = []
static func all() -> Array:
	if _records.is_empty():
		_records = JSON.parse_string(FileAccess.get_file_as_string("res://data/monsters.json"))
	return _records.duplicate(true)
static func get_monster(id: int) -> Dictionary:
	if id < 1 or id > 100: return {}
	if _records.is_empty(): all()
	return _records[id-1].duplicate(true)
