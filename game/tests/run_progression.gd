extends SceneTree
const Progression = preload("res://systems/run/run_progression.gd")
const Campaign = preload("res://data/campaign.gd")

func _initialize() -> void:
	call_deferred("run")

func clear_requirements(p: RefCounted, route: Dictionary) -> void:
	for device in route.get("devices", []): p.device_completed(str(device.id))
	for pickup in route.get("pickups", []):
		if pickup.kind == "seal": p.seal_collected()
	for enemy in route.get("enemies", []):
		p.enemy_defeated(enemy.get("boss", false) or enemy.get("captain", false))
	p.observe("done", false)

func run() -> void:
	var p = Progression.new()
	for number in range(1, 101):
		var route: Dictionary = Campaign.get_level(number)
		p.reset(route)
		assert(not p.gate_open and not p.gate_opening and p.entry_time == 0)
		if not p.objectives_met(): assert(not p.begin_open())
		clear_requirements(p, route)
		assert(p.objectives_met(), "Route %d completes through gameplay events" % number)
		assert(p.begin_open())
		assert(not p.begin_open(), "Repeated notifications cannot restart opening")
		var ticket: int = p.generation
		assert(p.complete(ticket))
		assert(not p.complete(ticket), "Opening completion is accepted only once")
		assert(p.exit_available(route.exit))
		assert(not p.advance_entry(.2, route.exit, false, true), "Dead players cannot leave")
		assert(not p.advance_entry(.2, route.exit, true, false))
		assert(not p.advance_entry(.2, route.exit + Vector2(80, 0), true, false))
		assert(p.entry_time == 0, "Leaving aperture cancels passage charge")
		assert(p.advance_entry(.45, route.exit, true, false))
		p.reset(route)
		assert(not p.complete(ticket), "Retry rejects delayed completion from old route")
		assert(not p.gate_open and p.entry_time == 0)

	# A mother is replaced by six required children before her defeat event.
	var boss_route := {"id":10,"mission":"boss","exit":Vector2(600,500),"enemies":[{"boss":true}]}
	p.reset(boss_route)
	for i in range(6): p.enemy_spawned(true)
	p.enemy_defeated(true)
	assert(not p.objectives_met())
	for i in range(5): p.enemy_defeated(true)
	assert(not p.begin_open())
	p.enemy_defeated(true)
	assert(p.objectives_met())

	# Hunt routes ignore living unmarked guards.
	p.reset({"id":5,"mission":"hunt","exit":Vector2.ZERO,"enemies":[{"captain":true},{}]})
	p.enemy_defeated(true)
	assert(p.objectives_met())

	# Pearls and dry escape gate swimming routes, not living wildlife.
	var swim := {"id":8,"traversal":"swim","water_bounds":Rect2(),"exit":Vector2.ZERO,"enemies":[{}],"pickups":[{"kind":"seal"}]}
	p.reset(swim)
	p.observe("idle",true)
	assert(not p.begin_open())
	p.seal_collected()
	assert(p.objective_state().kind == "surface" and not p.begin_open())
	p.observe("idle",false)
	assert(p.begin_open() and p.complete(p.generation))
	p.observe("idle",true)
	assert(p.gate_open and not p.exit_available(Vector2.ZERO))
	assert(not p.advance_entry(1,Vector2.ZERO,true,true))
	p.observe("idle",false)
	assert(p.advance_entry(0,Vector2.ZERO,true,true))

	# Cockpit, required device, and seal precedence stays intact.
	p.reset({"id":11,"exit":Vector2.ZERO,"devices":[{"id":"prism","type":"laser_seal","required":true}],"pickups":[{"kind":"seal"}]})
	assert(p.objective_state().kind == "laser_seal")
	p.device_completed("prism")
	assert(p.objective_state().kind == "seal")
	p.seal_collected()
	assert(p.objective_state().kind == "sequence")
	p.observe("done",false)
	assert(p.begin_open())
	var old: int = p.generation
	p.cancel()
	assert(not p.complete(old) and not p.begin_open(), "Menu return cancels pending opening")
	print("PASS progression: 100 event-driven route lifecycles, retries, duplicate callbacks, brood, hunt, swim and cockpit requirements")
	quit()
