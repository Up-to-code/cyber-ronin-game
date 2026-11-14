extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	create_timer(100,true,false,true).timeout.connect(func():push_error("Menu session timeout");quit(1))
	var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame;await process_frame
	var menu=scene.menu_session
	var player=scene.player
	var origin: Control=scene.hud.title_view.primary
	origin.grab_focus()
	scene.hud.armory_requested.emit()
	assert(paused and scene.inventory_screen.visible and scene.inventory_screen.mode=="inventory")
	assert(root.gui_get_focus_owner()==scene.inventory_screen.close_button)
	scene.inventory_screen.closed.emit()
	assert(paused and not scene.hud.gameplay.visible and root.gui_get_focus_owner()==origin)
	# Return to the actual originating settings control, not an invisible title button.
	scene.hud._push("settings");await process_frame;await process_frame
	var settings_focus: Control=root.gui_get_focus_owner()
	assert(is_instance_valid(settings_focus))
	assert(menu.open_armory("skills",scene.coins))
	assert(menu.close_armory() and paused and scene.hud.screens.back()=="settings")
	assert(root.gui_get_focus_owner()==settings_focus)
	scene.hud._back()
	scene._choose_level(1);await scene.level_loaded
	player.set_physics_process(false)
	player.attack_buffer_left=.2;player.jump_buffer_left=.2
	Input.action_press("attack")
	assert(menu.open_armory("skills",scene.coins))
	assert(scene.inventory_screen.mode=="all","Playing route retains combined armory")
	assert(player.attack_buffer_left==0 and player.jump_buffer_left==0 and not Input.is_action_pressed("attack"))
	assert(menu.close_armory() and not paused and scene.hud.gameplay.visible)
	assert(root.gui_get_focus_owner()==null)
	scene.pause_game();assert(paused and scene.hud.screens.back()=="pause")
	assert(not menu.open_armory("all",scene.coins))
	scene.hud._push("settings");scene.hud.handle_back()
	assert(paused and scene.hud.screens.back()=="pause")
	scene.hud.handle_back();assert(not paused)
	# Retry interrupts an armory; its late Close must never resume loading.
	assert(menu.open_armory("all",scene.coins))
	scene.retry_game()
	assert(scene.transitioning and paused and not scene.inventory_screen.visible)
	assert(not menu.close_armory() and paused)
	await scene.level_loaded
	assert(not paused and scene.started)
	player.set_physics_process(false)
	# Defeat interrupts an overlay. Results cannot be dismissed by an old Close.
	assert(menu.open_armory("all",scene.coins))
	player.health=0
	var death_ticket: int=menu.begin_defeat()
	assert(death_ticket>=0 and not scene.inventory_screen.visible)
	menu.finish_defeat(death_ticket)
	assert(paused and scene.hud.screens.back()=="death")
	assert(not menu.close_armory() and not menu.resume() and paused)
	# A pending old defeat must not cover a newly loaded route.
	scene.retry_game();await scene.level_loaded
	player.set_physics_process(false);player.health=0
	menu.finish_defeat(death_ticket)
	assert(not paused and scene.hud.screens.is_empty())
	player.health=player.max_health
	# An asynchronous story return cannot resume a different loading session.
	menu.show_story(1,false);assert(paused and scene.story_card.is_open())
	menu.finish_story()
	scene.retry_game();assert(paused and scene.transitioning and not scene.story_card.is_open())
	await scene.level_loaded
	assert(not paused and scene.hud.screens.is_empty())
	scene.main_menu();assert(paused and not scene.started)
	assert(menu.open_armory("skills",scene.coins) and scene.inventory_screen.mode=="skills")
	assert(menu.close_armory() and paused)
	var load_ticket: int=menu.begin_loading(1,"Failure fixture")
	assert(load_ticket>=0 and paused and not menu.open_armory("all",scene.coins))
	assert(not await menu.finish_loading(load_ticket-1),"Stale loading completion must be ignored")
	menu.fail_loading(load_ticket)
	assert(paused and not scene.started and not scene.transitioning and scene.hud.screens.back()=="title")
	scene.queue_free();paused=false;await process_frame
	root.get_node("Audio").shutdown()
	print("PASS menu sessions: title/settings focus, playing armory, input release, pause/back, retry, death, stale close/result/story cancellation")
	quit()
