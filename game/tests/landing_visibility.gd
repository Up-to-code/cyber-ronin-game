extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var camera_rules = load("res://systems/route_camera.gd")
	var maps = load("res://data/campaign.gd").levels()
	for map in maps:
		var route: Array = map.platforms if map.get("shaft",false) else map.platforms.filter(func(p): return not p.get("optional",false))
		for i in range(route.size()-1):
			var from: Dictionary=route[i]
			var to: Dictionary=route[i+1]
			var direction: float=signf(to.center.x-from.center.x)
			var feet: Vector2=from.center+Vector2(direction*(from.width/2-24),0)
			var landing: Vector2=camera_rules.next_landing(map,feet)
			var center: Vector2=camera_rules.focus(map,feet,Vector2.ZERO)
			# Logical viewport, reserve bottom 90px for touch controls.
			var zoom: float=0.56 if map.get("shaft",false) else 0.69
			var half_width: float=640/(2*zoom)
			center.x=clampf(center.x,half_width,maxf(half_width,map.width-half_width))
			center.y=clampf(center.y,180,map.get("height",950.0)-300)
			var screen: Vector2=(landing-center)*zoom+Vector2(320,180)
			assert(screen.x>24 and screen.x<616,"Landing must be horizontally visible")
			assert(screen.y>38 and screen.y<270,"Landing must be above touch controls")
	print("PASS: every authored route transition shows its next landing on 640x360 logical viewport")
	quit()
