extends VBoxContainer
signal level_selected(index: int)
signal back_requested
const Campaign = preload("res://data/campaign.gd")
const NodeButton = preload("res://ui/campaign_map_node.gd")
var max_unlocked := 1
var selected := 1
var region := 0
var view: ScrollContainer
var canvas: Control
var nodes: Array[Button] = []
var details: Label
var travel: Button
var previous: Button
var next: Button
var region_label: Label
var overview: ScrollContainer
var world_button: Button
func _ready() -> void:
	name="CampaignAtlas"
	add_theme_constant_override("separation",6)
	var navigation:=HBoxContainer.new()
	navigation.add_theme_constant_override("separation",8)
	add_child(navigation)
	previous=_flat_button("<",func():focus_region(region-1))
	previous.set_meta("accessible_description","Previous region")
	navigation.add_child(previous)
	world_button=_flat_button("CHAPTERS",_show_world)
	navigation.add_child(world_button)
	region_label=Label.new()
	region_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	region_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	region_label.add_theme_font_size_override("font_size",12)
	navigation.add_child(region_label)
	next=_flat_button(">",func():focus_region(region+1))
	next.set_meta("accessible_description","Next region")
	navigation.add_child(next)
	overview=ScrollContainer.new()
	overview.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO
	overview.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	overview.follow_focus=true
	add_child(overview)
	var regions:=HBoxContainer.new()
	regions.add_theme_constant_override("separation",12)
	overview.add_child(regions)
	for chapter in range(10):
		var chapter_name: String=Campaign.get_level(chapter*10+1).chapter_name.to_upper()
		var region_button:=_flat_button("%02d  %s\nLEVELS %d - %d"%[chapter+1,chapter_name,chapter*10+1,chapter*10+10],func():focus_region(chapter))
		region_button.custom_minimum_size=Vector2(190,80)
		region_button.set_meta("accessible_description","Open region %d: %s"%[chapter+1,chapter_name])
		regions.add_child(region_button)
	view=ScrollContainer.new()
	view.name="AtlasViewport"
	view.follow_focus=true
	view.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO
	view.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	view.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	add_child(view)
	canvas=preload("res://ui/campaign_map_canvas.gd").new()
	canvas.custom_minimum_size=Vector2(6800,130)
	canvas.unlocked=max_unlocked
	view.add_child(canvas)
	for chapter in range(10):
		var origin:=Vector2(chapter*680,0)
		for step in range(10):
			var index:=chapter*10+step+1
			var center:=origin+Vector2(32+step*64,82)
			canvas.points.append(center)
			var button:=NodeButton.new()
			button.route_id=index
			button.unlocked=index<=max_unlocked
			button.frontier=index==max_unlocked
			button.position=center-Vector2(22,22)
			button.size=Vector2(44,44)
			button.name="Route%03d"%index
			button.set_meta("accessible_description","Level %d · %s · %s"%[index,Campaign.get_level(index).name,"unlocked" if button.unlocked else "locked"])
			button.pressed.connect(func():select_route(index))
			button.focus_entered.connect(func():select_route(index))
			canvas.add_child(button)
			nodes.append(button)
	for i in range(nodes.size()):
		nodes[i].focus_neighbor_left=nodes[maxi(0,i-1)].get_path()
		nodes[i].focus_neighbor_right=nodes[mini(99,i+1)].get_path()
		nodes[i].focus_neighbor_top=nodes[maxi(0,i-1)].get_path()
		nodes[i].focus_neighbor_bottom=nodes[mini(99,i+1)].get_path()
		nodes[i].focus_next=nodes[mini(99,i+1)].get_path()
	var footer:=HBoxContainer.new()
	footer.add_theme_constant_override("separation",10)
	add_child(footer)
	details=Label.new()
	details.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	details.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_font_size_override("font_size",11)
	footer.add_child(details)
	travel=_flat_button("ENTER",_enter_selected)
	travel.custom_minimum_size.x=90
	footer.add_child(travel)
	var back:=_flat_button("BACK",func():back_requested.emit())
	back.custom_minimum_size.x=70
	footer.add_child(back)
	nodes[99].focus_next=travel.get_path()
	travel.focus_previous=nodes[99].get_path()
	get_viewport().size_changed.connect(_fit)
	_fit()
	select_route(max_unlocked)
	call_deferred("focus_region",(max_unlocked-1)/10)
	call_deferred("_show_world")
func _flat_button(text: String, callback: Callable) -> Button:
	var button:=Button.new()
	button.text=text
	button.custom_minimum_size=Vector2(44,44)
	button.add_theme_font_size_override("font_size",13)
	for state in ["normal","hover","focus","pressed","disabled"]:
		var style=preload("res://ui/pixel_menu_components.gd").button_style(state in ["focus","hover","pressed"],true)
		button.add_theme_stylebox_override(state,style)
	button.pressed.connect(callback)
	return button
func _fit() -> void:
	var visible_size:=get_viewport_rect().size
	custom_minimum_size.x=minf(570,maxf(240,visible_size.x-56))
	view.custom_minimum_size=Vector2(0,140)
	overview.custom_minimum_size=Vector2(0,140)
func select_route(index: int) -> void:
	if not is_instance_valid(details): return
	overview.hide()
	view.show()
	selected=clampi(index,1,100)
	region=(selected-1)/10
	var route:=Campaign.get_level(selected)
	details.text="%03d · %s\n%s"%[selected,route.name,route.objective if selected<=max_unlocked else "Clear the preceding route to unlock."]
	travel.disabled=selected>max_unlocked
	region_label.text="REGION %02d / 10 · LEVELS %d–%d"%[region+1,region*10+1,region*10+10]
	previous.disabled=region==0
	next.disabled=region==9
func focus_region(index: int) -> void:
	region=clampi(index,0,9)
	var target:=region*10+1 if max_unlocked>=region*10+10 else maxi(region*10+1,max_unlocked)
	select_route(target)
	view.scroll_horizontal=region*680
	view.scroll_vertical=0
	nodes[target-1].grab_focus()
	call_deferred("_frame_region",region)
func _enter_selected() -> void:
	if selected<=max_unlocked: level_selected.emit(selected)

func _frame_region(index: int) -> void:
	var point: Vector2=canvas.points[selected-1]
	view.scroll_horizontal=roundi(point.x-view.size.x/2)
	view.scroll_vertical=0

func _show_world() -> void:
	if not is_instance_valid(overview):return
	view.hide()
	overview.show()
	region_label.text="10 CHAPTERS / 100 LEVELS"
	world_button.grab_focus()
