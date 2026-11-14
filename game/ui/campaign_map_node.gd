extends Button
var route_id := 1
var unlocked := false
var frontier := false
func _ready() -> void:
	custom_minimum_size=Vector2(44,44)
	text=""
	var number:=Label.new()
	number.text=str(route_id)
	number.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	number.add_theme_font_size_override("font_size",14)
	number.add_theme_color_override("font_color",Color("ffe4df") if unlocked else Color("b5a7aa"))
	number.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(number)
	number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_theme_font_size_override("font_size",14)
	add_theme_color_override("font_color",Color("ffe4df") if unlocked else Color("b5a7aa"))
	for state in ["normal","hover","pressed","focus"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
func _draw() -> void:
	var color := Color("cf344d") if frontier or button_pressed else (Color("48202b") if unlocked else Color("201a23"))
	var border := Color("ffe4df") if has_focus() else (Color("aa6761") if unlocked else Color("5b4853"))
	var r := Rect2(Vector2(4,4),size-Vector2(8,8))
	draw_rect(r,border)
	draw_rect(r.grow(-2),color)
	# Cut corners preserve a stepped pixel silhouette; boss nodes carry a crown.
	for corner in [r.position,r.position+Vector2(r.size.x-3,0),r.end-Vector2(3,3),r.position+Vector2(0,r.size.y-3)]:
		draw_rect(Rect2(corner,Vector2(3,3)),Color("17131b"))
	if route_id%10==0:
		for x in [-6,0,6]: draw_rect(Rect2(Vector2(size.x/2+x-2,0),Vector2(4,4)),Color("ff9b9f"))
	elif not unlocked:
		draw_rect(Rect2(Vector2(size.x/2-2,37),Vector2(4,3)),Color("b5a7aa"))
