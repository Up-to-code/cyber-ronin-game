extends Control
## Flat, borderless pixel switch. The parent Button owns input and focus.
var enabled: bool = false
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func _draw() -> void:
	var track := Rect2(Vector2(0,4),Vector2(size.x,12))
	draw_rect(track,Color("a32f3b") if enabled else Color("47383f"))
	var knob_x: float = size.x-16 if enabled else 2
	draw_rect(Rect2(Vector2(knob_x,1),Vector2(14,18)),Color("f1dfbf") if enabled else Color("bdadb0"))
