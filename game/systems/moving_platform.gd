extends AnimatableBody2D

@export var travel: Vector2 = Vector2(180, 0)
@export_range(0.5, 12.0, 0.1) var duration: float = 3.0
@export var phase: float = 0.0
var origin: Vector2
var elapsed: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	origin = position
	reset_motion()

func _physics_process(delta: float) -> void:
	elapsed += delta
	# Smooth turnaround, zero initial displacement; velocity is inferred by physics.
	var blend: float = (1.0 - cos((elapsed / maxf(duration, 0.1) + phase) * TAU)) * 0.5
	position = origin + travel * blend

func reset_motion() -> void:
	elapsed = 0.0
	if is_inside_tree():
		position = origin + travel * (1.0 - cos(phase * TAU)) * 0.5
