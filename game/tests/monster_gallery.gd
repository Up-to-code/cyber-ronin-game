extends SceneTree
class Gallery extends Node2D:
	var bodies: Array[Texture2D] = []
	func _ready() -> void:
		for id in range(1,101): bodies.append(load("res://art/monster-migration/%03d.png"%id))
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,1280),Color("241722"))
		for i in range(100):
			var at := Vector2((i%10)*128,(i/10)*128)
			draw_texture(bodies[i],at)
			draw_string(ThemeDB.fallback_font,at+Vector2(4,15),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("f5d58b"))
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	root.size=Vector2i(1280,1280)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,1280)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var gallery := Gallery.new();viewport.add_child(gallery)
	await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://../docs/qa/monster-gallery-native.png")
	print("Native gallery saved: 100 bodies")
	quit()
