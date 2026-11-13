extends Node2D
# Screen-space weather with camera-relative depth; fixed budget, no accumulating nodes.
var biome := "surface"
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
	for index in range(flakes.size()):
		var f: Vector4 = flakes[index]
		var ember: bool = biome == "underwater" or index % 3 == 0
		var depth: float = f.z
		var x: float = fposmod(f.x * extent.x + age*(9+depth*22) + sin(age*0.8+f.w)*12 - camera_x*depth*0.22, extent.x+8)-4
		var y: float = fposmod(f.y * extent.y + age*(-18-depth*20 if ember else 12+depth*26),extent.y+8)-4
		var side: float = 1 if depth < 0.55 else 2
		var tint := Color(1.0,0.42+sin(age+f.w)*0.12,0.16,0.25+depth*0.35) if ember else Color(0.70,0.66,0.72,0.15+depth*0.3)
		if biome in ["underground","underwater"]: tint = Color(0.3,0.9,1.0,0.15+depth*0.25)
		elif biome == "sky": tint = Color(1.0,0.96,0.7,0.2+depth*0.3)
		elif biome == "citadel": tint = Color(1.0,0.65,0.22,0.2+depth*0.3)
		draw_rect(Rect2(Vector2(x,y).floor(),Vector2(side,side)),tint)
