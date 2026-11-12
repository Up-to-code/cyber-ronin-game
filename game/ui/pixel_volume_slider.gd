extends HSlider
## Native input/focus with a deterministic pixel-art meter, not theme-dependent height.
var frame_art: Texture2D
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for role in ["slider","grabber_area","grabber_area_highlight"]:
		add_theme_stylebox_override(role,StyleBoxEmpty.new())
	for role in ["grabber","grabber_highlight","grabber_disabled"]:
		var hidden := GradientTexture2D.new()
		hidden.width = 1
		hidden.height = 1
		var clear := Gradient.new()
		clear.colors = PackedColorArray([Color.TRANSPARENT,Color.TRANSPARENT])
		hidden.gradient = clear
		add_theme_icon_override(role,hidden)
	value_changed.connect(func(_value:float):queue_redraw())
	resized.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
func _draw() -> void:
	var y: float = floorf((size.y-8)*0.5)
	var track := Rect2(Vector2(8,y),Vector2(maxf(1,size.x-16),8))
	# Explicit whole-pixel geometry keeps the actual progress fill readable at8px.
	draw_rect(track,Color("48262e"))
	draw_rect(track.grow(-2),Color("210c13"))
	var fraction: float = clampf((value-min_value)/maxf(0.001,max_value-min_value),0,1)
	var inside: Rect2 = track.grow(-2)
	draw_rect(Rect2(inside.position,Vector2(floorf(inside.size.x*fraction),inside.size.y)),Color("cf3434"))
	if fraction > 0:
		draw_rect(Rect2(inside.position,Vector2(floorf(inside.size.x*fraction),2)),Color("ed7361"))
	var thumb_x: float = roundf(lerpf(track.position.x+4,track.end.x-4,fraction))
	var thumb := Rect2(Vector2(thumb_x-3,y-2),Vector2(6,12))
	draw_rect(thumb,Color("fff0ca") if has_focus() else Color("d7a89a"))
