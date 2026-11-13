extends SceneTree
const Maps = preload("res://data/campaign.gd")
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
func _supported(point: Vector2, platforms: Array) -> int:
	for i in range(platforms.size()):
		var surface: Dictionary = platforms[i]
		if absf(point.y - surface.center.y) < 0.1 and absf(point.x - surface.center.x) < surface.width * 0.5 - 20:
			return i
	return -1
func _gap(a: Dictionary, b: Dictionary) -> float:
	return maxf(0, absf(a.center.x - b.center.x) - (a.width + b.width) * 0.5)
func _jump_edge(a: Dictionary, b: Dictionary) -> bool:
	var rise: float = a.center.y - b.center.y
	# Conservative platform graph: modest gaps, maximum 90px ascent.
	# Lift states are joined by riding, not an assumption of instantaneous teleport.
	var maximum_gap: float = 145 if rise > 60 else (170 if rise > 0 else 195)
	return rise <= 90 and rise >= -180 and _gap(a, b) <= maximum_gap
func _route_exists(level: Dictionary) -> bool:
	var nodes: Array[Dictionary] = []
	for platform in level.platforms:
		var node: Dictionary = platform.duplicate(true)
		node["lift_id"] = -1
		nodes.append(node)
	for i in range(level.lifts.size()):
		var lift: Dictionary = level.lifts[i]
		for blend in [0.0,0.5,1.0]:
			nodes.append({"center":lift.center + lift.travel * blend,"width":lift.width,"lift_id":i})
	var start: int = _supported(level.spawn, level.platforms)
	var finish: int = _supported(level.exit, level.platforms)
	if start < 0 or finish < 0:
		return false
	var reached: Array[int] = [start]
	var frontier: Array[int] = [start]
	while not frontier.is_empty():
		var current: int = frontier.pop_front()
		if current == finish:
			return true
		for target in range(nodes.size()):
			if target in reached:
				continue
			var ride: bool = nodes[current].lift_id >= 0 and nodes[current].lift_id == nodes[target].lift_id
			if ride or _jump_edge(nodes[current], nodes[target]):
				reached.append(target)
				frontier.append(target)
	return false
func _run() -> void:
	var levels: Array[Dictionary] = Maps.levels()
	_check(levels.size() == 100, "campaign must contain 100 maps")
	var names: Dictionary = {}
	var signatures: Dictionary = {}
	for level in levels:
		var label: String = "Level %d" % level.id
		_check(level.width >= 1280 and level.width <= 5600, label + " width must fit design bounds")
		_check(not names.has(level.name), label + " must have a distinct name")
		names[level.name] = true
		var signature: String = str(level.platforms)
		_check(not signatures.has(signature), label + " must have distinct terrain geometry")
		signatures[signature] = true
		for platform in level.platforms:
			_check(platform.width >= 120, label + " platform must be wide enough for standing combat")
			_check(platform.center.x - platform.width/2 >= -0.05 and platform.center.x + platform.width/2 <= level.width+0.05, label + " platform bounds")
			if platform.get("optional",false):
				_check(platform.get("one_way",false), label + " optional overhead ledge must be one-way")
		_check(_supported(level.spawn,level.platforms) >= 0, label + " spawn needs stable ground")
		_check(_supported(level.exit,level.platforms) >= 0, label + " exit needs stable ground")
		for guard in level.enemies:
			_check(_supported(guard.position,level.platforms) >= 0, label + " guard needs stable ground")
		_check(_route_exists(level), label + " needs a conservative jump/lift route to exit")
	_check(levels[5].difficulty == "hard", "final keep must be marked hard")
	_check(levels.back().enemies.back().get("boss",false), "final arena needs its captain")
	# Callers must be able to alter runtime health/theme without modifying definitions.
	var copy: Dictionary = Maps.get_level(1)
	copy.name = "runtime mutation"
	_check(Maps.get_level(1).name == "Monastery Approach", "level lookup must return independent data")
	if failures.is_empty():
		print("PASS: 100 distinct campaign maps, bounds, stable spawns/exits/guards, one-way optional ledges, conservative route graph, final captain")
		quit()
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
