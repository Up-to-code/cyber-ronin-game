extends Control
## Independent title artwork; never moves the menu hit targets.
var elapsed := 0.0
var art := preload("res://art/pixel/ui-kit/ashen-wordmark.png")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
func _draw() -> void:
	var width := minf(size.x,220.0)
	var height := width * art.get_height() / art.get_width()
	var origin := Vector2(roundf((size.x-width)*0.5),roundf((size.y-height)*0.5+sin(elapsed*1.2)*2.0))
	draw_texture_rect(art,Rect2(origin,Vector2(width,height)),false)
