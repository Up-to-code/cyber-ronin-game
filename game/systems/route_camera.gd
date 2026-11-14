extends RefCounted
# Authored route order determines the next landing, including alternating shafts.
static func next_landing(map: Dictionary, feet: Vector2) -> Vector2:
	# While using an upper branch or recovery ledge, frame its authored next step.
	var nearest_index := -1
	var nearest_score := INF
	for i in range(map.platforms.size()):
		var surface: Dictionary=map.platforms[i]
		var dx: float=maxf(0,absf(feet.x-surface.center.x)-surface.width/2)
		var score: float=dx*dx+pow(feet.y-surface.center.y,2)
		if score<nearest_score:
			nearest_score=score
			nearest_index=i
	if nearest_index>=0 and not map.platforms[nearest_index].get("route",true):
		for link in map.get("branch_links",[]):
			if link[0]==nearest_index:
				var target: Dictionary=map.platforms[link[1]]
				return Vector2(clampf(feet.x,target.center.x-target.width/2+50,target.center.x+target.width/2-50),target.center.y)
	var route: Array = map.platforms.filter(func(p): return p.get("route",not p.get("optional",false) or map.get("shaft",false)))
	var closest := 0
	var best := INF
	for i in range(route.size()):
		var p: Dictionary = route[i]
		var dx: float = maxf(0,absf(feet.x-p.center.x)-p.width*0.5)
		var score: float = dx*dx + pow(feet.y-p.center.y,2)
		if score < best:
			best=score
			closest=i
	var next: Dictionary = route[mini(closest+1,route.size()-1)]
	# Show the safe landing area near the approaching edge, not a distant center.
	return Vector2(clampf(feet.x,next.center.x-next.width/2+70,next.center.x+next.width/2-70),next.center.y)

static func focus(map: Dictionary, feet: Vector2, velocity: Vector2) -> Vector2:
	var landing := next_landing(map,feet)
	if feet.distance_to(landing)>520: return feet+Vector2(velocity.x*0.2,-100)
	return feet.lerp(landing,0.5 if map.get("vertical_route",map.get("shaft",false)) else 0.45)+Vector2(velocity.x*0.12,-30 if map.get("vertical_route",map.get("shaft",false)) else -45)
