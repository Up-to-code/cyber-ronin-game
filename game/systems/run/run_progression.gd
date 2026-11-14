extends RefCounted
## Owns one route's requirements, gate lifecycle and passage eligibility.
## Rendering stays in the scene; delayed rendering callbacks carry a generation.
const Objectives = preload("res://systems/objective_tracker.gd")
const ENTRY_SECONDS := 0.45

var generation := 0
var remaining := 0
var seals_left := 0
var marked_left := 0
var gate_open := false
var gate_opening := false
var entry_time := 0.0
var _map: Dictionary = {}
var _required: Dictionary = {}
var _sequence_phase := "idle"
var _submerged := false
var _active := false

func reset(route: Dictionary) -> void:
	cancel()
	_map = route.duplicate(true)
	_active = true
	remaining = route.get("enemies", []).size()
	marked_left = 0
	seals_left = 0
	_required.clear()
	_sequence_phase = "idle"
	_submerged = false
	for enemy in route.get("enemies", []):
		if enemy.get("boss", false) or enemy.get("captain", false): marked_left += 1
	for pickup in route.get("pickups", []):
		if pickup.kind == "seal": seals_left += 1
	for device in route.get("devices", []):
		if device.get("required", false): _required[str(device.id)] = true

func cancel() -> void:
	generation += 1
	_active = false
	gate_open = false
	gate_opening = false
	entry_time = 0.0

func required_devices() -> Dictionary:
	return _required.duplicate()

func enemy_spawned(marked: bool) -> void:
	remaining += 1
	if marked: marked_left += 1

func enemy_defeated(marked: bool) -> void:
	remaining = maxi(0, remaining - 1)
	if marked: marked_left = maxi(0, marked_left - 1)

func seal_collected() -> void:
	seals_left = maxi(0, seals_left - 1)

func device_completed(id: String) -> void:
	_required.erase(id)

# These are observations of live cockpit/water state, not duplicate objectives.
func observe(sequence_phase: String, submerged: bool) -> void:
	_sequence_phase = sequence_phase
	_submerged = submerged

func objective_state() -> Dictionary:
	return Objectives.describe(_map, remaining, seals_left, marked_left, _required, _sequence_phase, _submerged)

func objectives_met() -> bool:
	return _active and bool(objective_state().complete)

func begin_open() -> bool:
	if not objectives_met() or gate_open or gate_opening: return false
	gate_opening = true
	return true

# False means this callback belongs to a cancelled or already-completed opening.
func complete(opening_generation: int) -> bool:
	if not _active or opening_generation != generation or not gate_opening: return false
	gate_opening = false
	gate_open = true
	return true

func exit_available(position: Vector2) -> bool:
	return gate_open and objectives_met() and position.distance_to(_map.exit) < 120

func advance_entry(delta: float, position: Vector2, alive: bool, interact: bool) -> bool:
	var eligible := alive and gate_open and objectives_met()
	var inside := absf(position.x - _map.exit.x) < 34 and absf(position.y - _map.exit.y) < 24
	entry_time = minf(ENTRY_SECONDS, entry_time + delta) if eligible and inside else 0.0
	return eligible and position.distance_to(_map.exit) < 120 and (interact or entry_time >= ENTRY_SECONDS)
