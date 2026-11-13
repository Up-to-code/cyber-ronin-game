class_name Campaign
extends RefCounted
# Authored action sections; no post-load resizing or enemy relocation.
static var _levels: Array[Dictionary] = []
static func levels() -> Array[Dictionary]:
	if not _levels.is_empty(): return _levels.duplicate(true)
	var raw: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/routes.json"))
	var result: Array[Dictionary] = []
	for value in raw:
		var stage: Dictionary = value
		stage.spawn = Vector2(stage.spawn[0],stage.spawn[1])
		stage.exit = Vector2(stage.exit[0],stage.exit[1])
		if stage.has("water_bounds"):
			var bounds: Array=stage.water_bounds
			stage.water_bounds=Rect2(bounds[0],bounds[1],bounds[2],bounds[3])
		for current in stage.get("water_currents",[]):
			current.center=Vector2(current.center[0],current.center[1])
		for guard in stage.get("water_enemies",[]):
			guard.position=Vector2(guard.position[0],guard.position[1])
		for platform in stage.platforms:
			platform.center = Vector2(platform.center[0],platform.center[1])
		for lift in stage.lifts:
			lift.center = Vector2(lift.center[0],lift.center[1])
			lift.travel = Vector2(lift.travel[0],lift.travel[1])
		for enemy in stage.enemies:
			enemy.position = Vector2(enemy.position[0],enemy.position[1])
		for pickup in stage.get("pickups",[]):
			pickup.position = Vector2(pickup.position[0],pickup.position[1])
		for device in stage.get("devices",[]):
			device.position = Vector2(device.position[0],device.position[1])
		for region in stage.get("realm_regions",[]):
			region.spawn = Vector2(region.spawn[0],region.spawn[1])
			region.bounds = Rect2(region.bounds[0],region.bounds[1],region.bounds[2],region.bounds[3])
		result.append(stage)
	_levels = result
	return result.duplicate(true)
static func get_level(index: int) -> Dictionary:
	if _levels.is_empty(): levels()
	var campaign := _levels
	if index < 1 or index > campaign.size():
		push_error("Campaign level index out of range: %d" % index)
		return {}
	return campaign[index-1].duplicate(true)
