extends SceneTree
func _initialize():call_deferred("run")
func run():
	create_timer(25,true,false,true).timeout.connect(func():push_error("Navigation timeout");quit(1))
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.hud.settings_path="user://navigation100-test.cfg"
	scene.hud.max_unlocked=35
	scene.hud._push("maps")
	for frame in range(6):await process_frame
	var atlas=scene.hud.campaign_map
	assert(atlas.overview.visible,"Map opens with horizontal chapter selection")
	var region_buttons=atlas.overview.get_child(0).get_children()
	assert(region_buttons.size()==10,"Overview exposes all ten regions")
	for region_button in region_buttons:
		assert(region_button.size.x>=44 and region_button.size.y>=44,"World regions retain usable touch targets")
	assert(atlas.nodes.size()==100)
	assert(atlas.canvas.points.size()==100)
	assert(atlas.view.vertical_scroll_mode==ScrollContainer.SCROLL_MODE_DISABLED)
	for point in atlas.canvas.points:assert(point.y==82,"All level routes stay horizontal")
	assert(atlas.canvas.find_children("*","TextureRect",true,false).is_empty(),"No decorative map backgrounds")
	atlas.select_route(36)
	assert(atlas.travel.disabled and atlas.details.text.contains("unlock"))
	atlas._enter_selected()
	assert(not scene.transitioning,"Locked selection must never enter a level")
	atlas.select_route(35)
	assert(not atlas.travel.disabled)
	for dimensions in [Vector2i(960,540),Vector2i(1152,648),Vector2i(1600,720),Vector2i(1024,768)]:
		root.size=dimensions
		for frame in range(6):await process_frame
		var safe: Rect2=scene.hud.safe.get_global_rect()
		assert(safe.encloses(atlas.get_global_rect()),"Map/footer must fit safe area: %s %s"%[safe,atlas.get_global_rect()])
		for chapter in range(10):
			atlas.focus_region(chapter)
			for frame in range(4):await process_frame
			assert(atlas.region==chapter)
			var current: Button=atlas.nodes[atlas.selected-1]
			assert(atlas.view.get_global_rect().encloses(current.get_global_rect()),"Selected node stays framed")
			assert(atlas.previous.disabled==(chapter==0) and atlas.next.disabled==(chapter==9))
			for i in range(chapter*10,chapter*10+10):
				assert(atlas.nodes[i].size.x>=44 and atlas.nodes[i].size.y>=44)
				assert(not atlas.nodes[i].get_meta("accessible_description").is_empty())
	# Restore full access in memory only; choose final level through its real action.
	atlas.max_unlocked=100
	atlas.select_route(100)
	atlas.travel.pressed.emit()
	await scene.level_loaded
	assert(scene.level==100)
	assert(scene.hud.progress_label.text=="100 / 100")
	scene.main_menu()
	assert(scene.hud.screens.back()=="title")
	root.get_node("Audio").shutdown()
	print("PASS: 100 map nodes, ten regions, locked travel, touch sizes, responsive safe bounds, focus framing, final level entry and return to title")
	quit()
