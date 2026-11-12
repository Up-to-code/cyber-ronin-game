extends Node2D
# Screen-space weather with camera-relative depth; fixed budget, no accumulating nodes.
var camera_x: float = 0
var age: float = 0
var flakes: Array[Vector4] = []
func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 78123
	for i in range(100):
		flakes.append(Vector4(rng.randf(), rng.randf(), rng.randf_range(0.25,1.0), rng.randf()*TAU))
func _process(delta: float) -> void:
	age += delta
	queue_redraw()
func _draw() -> void:
	var extent := get_viewport_rect().size
	for f in flakes:
		var depth: float = f.z
		var x: float = fposmod(f.x * extent.x + age*(9+depth*22) + sin(age*0.8+f.w)*12 - camera_x*depth*0.22, extent.x+8)-4
		var y: float = fposmod(f.y * extent.y + age*(12+depth*26),extent.y+8)-4
		var side: float = 1 if depth < 0.55 else 2
		draw_rect(Rect2(Vector2(x,y).floor(),Vector2(side,side)),Color(0.84,0.90,0.93,0.22+depth*0.48))
