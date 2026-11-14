extends RefCounted
## Owns route/menu session transitions; HUD keeps its internal screen stack.
var started := false
var transitioning := false
var _state := "title"
var _generation := 0
var _origin := "title"
var _return_focus: WeakRef
var _story_ending := false
var _player: CharacterBody2D
var _hud: CanvasLayer
var _armory: Control
var _story: CanvasLayer
var _audio: Node

func _init(player: CharacterBody2D, hud: CanvasLayer, armory: Control, story: CanvasLayer, audio: Node) -> void:
	_player=player;_hud=hud;_armory=armory;_story=story;_audio=audio

func _release_input() -> void:
	_player.cancel_pending_input()
	_hud.touch.release_all()

func _dismiss_overlays() -> void:
	_armory.hide()
	_story.close()
	_return_focus=null

func _pause_world() -> void:
	_release_input()
	_player.get_tree().paused=true
	_audio.set_combat(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func show_title() -> bool:
	if transitioning:return false
	_generation+=1
	_state="title";started=false
	_dismiss_overlays();_pause_world()
	_hud.show_title()
	return true

func begin_loading(index: int, title: String) -> int:
	if transitioning:return -1
	_generation+=1
	transitioning=true;_state="loading"
	_dismiss_overlays();_pause_world()
	_hud.show_loading(index,title)
	return _generation

func fail_loading(ticket: int) -> void:
	if ticket!=_generation or not transitioning:return
	transitioning=false
	show_title()

func finish_loading(ticket: int) -> bool:
	if ticket!=_generation or not transitioning:return false
	await _hud.finish_loading()
	if ticket!=_generation or not transitioning:return false
	started=true;transitioning=false;_state="play"
	_release_input()
	_player.get_tree().paused=false
	return true

func pause() -> bool:
	_release_input()
	if not started or transitioning or _state!="play" or _player.get_tree().paused:return false
	_state="pause";_pause_world();_hud.show_pause()
	return true

func resume() -> bool:
	if transitioning or _state!="pause" or _player.health<=0:return false
	_state="play";_release_input();_hud.close_menu()
	_player.get_tree().paused=false
	return true

func open_armory(mode: String, coins: int) -> bool:
	if transitioning or _player.health<=0 or _state not in ["title","play"]:return false
	if started and _player.get_tree().paused:return false
	_origin=_state
	var focus := _player.get_viewport().gui_get_focus_owner()
	_return_focus=weakref(focus) if is_instance_valid(focus) else null
	_state="armory"
	_armory.mode="all" if _origin=="play" else mode
	_pause_world();_hud.gameplay.hide()
	_armory.show();_armory.refresh(coins);_armory.close_button.grab_focus()
	return true

func close_armory() -> bool:
	# A delayed close from an interrupted overlay cannot resume loading or death.
	if _state!="armory":return false
	_armory.hide();_state=_origin
	_release_input()
	_hud.gameplay.visible=_state=="play"
	_player.get_tree().paused=_state!="play"
	_player.get_viewport().gui_release_focus()
	if _state=="title":
		var focus: Control=_return_focus.get_ref() if _return_focus!=null else null
		if is_instance_valid(focus) and focus.is_visible_in_tree():focus.grab_focus()
		elif is_instance_valid(_hud.title_view) and _hud.title_view.is_visible_in_tree():_hud.title_view.primary.grab_focus()
	_return_focus=null
	return true

func show_story(index: int, ending: bool) -> void:
	if transitioning or not started:return
	_generation+=1;_state="story";_story_ending=ending
	_dismiss_overlays();_pause_world();_hud.touch.hide()
	_story.show_chapter(index,ending)

func finish_story() -> void:
	if _state!="story":return
	var ticket:=_generation
	await _player.get_tree().process_frame
	if ticket!=_generation or _state!="story":return
	_release_input()
	if _story_ending:show_result(true)
	else:
		_state="play";_hud.close_menu();_hud.state_label.hide()
		_player.get_tree().paused=false

func begin_defeat() -> int:
	if transitioning or not started:return -1
	if _state!="defeat_pending":
		_generation+=1;_state="defeat_pending"
		_dismiss_overlays();_release_input();_hud.hide_touch_controls()
		_player.get_tree().paused=false
	return _generation

func finish_defeat(ticket: int) -> void:
	if ticket==_generation and _state=="defeat_pending" and _player.health<=0:show_result(false)

func show_result(won: bool) -> void:
	_generation+=1;_state="result"
	_dismiss_overlays();_pause_world();_hud.show_result(won)
