class_name Campaign
extends RefCounted

# Platform center.y is the flat WALKABLE TOP, not the collision-box center.
# Optional ledges are one-way so they never obstruct the route beneath them.
static func _ledge(x: float, y: float, width: float, optional: bool = false) -> Dictionary:
	return {"center": Vector2(x, y), "width": width, "optional": optional, "one_way": optional}

static func _lift(x: float, y: float, width: float, travel: Vector2, duration: float) -> Dictionary:
	return {"center": Vector2(x, y), "width": width, "travel": travel, "duration": duration}

static func _guard(x: float, y: float, elite: bool = false, kind: String = "guard") -> Dictionary:
	return {"position": Vector2(x, y), "elite": elite, "kind": kind}

static func levels() -> Array[Dictionary]:
	var maps: Array[Dictionary] = [
		{
			"id": 1, "name": "Monastery Approach", "theme": "approach", "difficulty": "normal",
			"width": 2520.0, "spawn": Vector2(380, 550), "exit": Vector2(2380, 550),
			"description": "Cross the old causeway and reach the first castle gate.",
			"platforms": [_ledge(460,550,920), _ledge(1860,550,1320), _ledge(610,470,180,true), _ledge(1040,610,400,true), _ledge(1720,470,200,true)],
			"lifts": [_lift(1040,535,150,Vector2(0,-45),3.6)],
			"enemies": [_guard(780,550), _guard(1900,550)]
		},
		{
			"id": 2, "name": "Ember Courtyard", "theme": "courtyard", "difficulty": "normal",
			"width": 2800.0, "spawn": Vector2(380,550), "exit": Vector2(2670,510),
			"description": "Climb the courtyard terraces between lantern-lit battlements.",
			"platforms": [_ledge(340,550,680), _ledge(1145,510,650), _ledge(1885,550,530), _ledge(2545,510,510), _ledge(1120,420,180,true)],
			"lifts": [_lift(750,540,140,Vector2(0,-45),3.6)],
			"enemies": [_guard(510,550), _guard(1290,510,false,"fire"), _guard(2480,510), _guard(1860,550,false,"wraith")]
		},
		{
			"id": 3, "name": "Bamboo Ramparts", "theme": "bamboo", "difficulty": "normal",
			"width": 3000.0, "spawn": Vector2(380,550), "exit": Vector2(2860,530),
			"description": "Follow the bamboo-lined wall and its drifting stone bridge.",
			"platforms": [_ledge(280,550,560), _ledge(915,490,450), _ledge(1570,530,540), _ledge(2185,470,410), _ledge(2765,530,470), _ledge(280,460,150,true), _ledge(2110,380,160,true)],
			"lifts": [_lift(1220,510,130,Vector2(0,-35),3.0)],
			"enemies": [_guard(420,550), _guard(1010,490,false,"fire"), _guard(1710,530), _guard(2750,530,false,"wraith"), _guard(2150,470,false,"sentinel")]
		},
		{
			"id": 4, "name": "Castle Rooftops", "theme": "rooftops", "difficulty": "normal",
			"width": 3300.0, "spawn": Vector2(380,560), "exit": Vector2(3160,500),
			"description": "Ascend the tiled roofs, then descend toward the inner keep.",
			"platforms": [_ledge(310,560,620), _ledge(970,490,500), _ledge(1570,420,420), _ledge(2155,490,470), _ledge(2685,440,310), _ledge(3140,500,320), _ledge(1050,400,150,true), _ledge(2420,410,170,true)],
			"lifts": [_lift(1290,470,120,Vector2(0,-40),3.4)],
			"enemies": [_guard(490,560), _guard(1080,490,false,"lancer"), _guard(1660,420,false,"wraith"), _guard(2290,490,false,"fire"), _guard(2700,440,false,"wraith")]
		},
		{
			"id": 5, "name": "Broken Sanctuary", "theme": "sanctuary", "difficulty": "normal",
			"width": 3500.0, "spawn": Vector2(380,550), "exit": Vector2(3350,550),
			"description": "Clear the inner shrine and the guards protecting its final ascent.",
			"platforms": [_ledge(350,550,700), _ledge(1100,550,500), _ledge(1780,490,620), _ledge(2470,550,540), _ledge(3195,550,610), _ledge(420,460,180,true), _ledge(2470,460,180,true), _ledge(1920,410,180,true)],
			"lifts": [_lift(1430,530,140,Vector2(0,-40),3.1)],
			"enemies": [_guard(520,550), _guard(1190,550,false,"wraith"), _guard(1870,490,false,"sentinel"), _guard(2540,550,true,"fire"), _guard(3240,550), _guard(1620,490,false,"wraith")]
		},
		{
			"id": 6, "name": "Crimson Castle Keep", "theme": "summit", "difficulty": "hard",
			"width": 2800.0, "spawn": Vector2(380,550), "exit": Vector2(2670,510),
			"description": "Climb the keep and defeat the captain beneath the red moon.",
			"platforms": [_ledge(320,550,640), _ledge(980,500,400), _ledge(1550,450,420), _ledge(2350,510,900), _ledge(430,460,150,true), _ledge(2070,430,180,true)],
			"lifts": [_lift(1260,480,120,Vector2(0,-35),2.9)],
			"enemies": [_guard(510,550,false,"lancer"), _guard(1050,500,false,"fire"), _guard(1620,450,false,"wraith"), _guard(2070,510,false,"sentinel"), _guard(2250,510,false,"wraith"), _guard(2440,510,true,"fire")]
		}
	]

	# Keep the authored elevations, encounter positions and endpoints, while giving
	# touch players a reliable landing margin without mandatory double jumps.
	for map in maps:
		var route: Array = map.platforms.filter(func(p: Dictionary): return not p.get("optional", false))
		var max_gap: float = 80.0 + float(map.id - 1) * 6.0
		for i in range(route.size() - 1):
			var left: Dictionary = route[i]
			var right: Dictionary = route[i + 1]
			var edge_a: float = left.center.x + left.width * 0.5
			var edge_b: float = right.center.x - right.width * 0.5
			var extension: float = maxf(0, (edge_b - edge_a - max_gap) * 0.5)
			left.width += extension
			left.center.x += extension * 0.5
			right.width += extension
			right.center.x -= extension * 0.5
		# Lifts remain visibly moving, but fit the repaired opening.
		for lift in map.lifts:
			for i in range(route.size() - 1):
				var edge_a: float = route[i].center.x + route[i].width * 0.5
				var edge_b: float = route[i+1].center.x - route[i+1].width * 0.5
				if lift.center.x > route[i].center.x and lift.center.x < route[i+1].center.x:
					lift.center.x = (edge_a + edge_b) * 0.5
					lift.width = minf(lift.width, edge_b - edge_a - 8)
					lift.travel.x = 0
	return maps

static func get_level(index: int) -> Dictionary:
	var campaign: Array[Dictionary] = levels()
	if index < 1 or index > campaign.size():
		push_error("Campaign level index out of range: %d" % index)
		return {}
	return campaign[index - 1].duplicate(true)
