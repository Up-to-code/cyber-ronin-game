extends SceneTree
const Terrain = preload("res://systems/terrain_visual.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	var world := Node2D.new()
	root.add_child(world)
	var background := ColorRect.new()
	background.position = Vector2.ZERO
	background.size = Vector2(1280,720)
	background.color = Color("4b1229")
	world.add_child(background)
	var short_body := StaticBody2D.new()
	short_body.position = Vector2(200,180)
	world.add_child(short_body)
	var short_visual: Node2D = Terrain.decorate(short_body,256)
	var broad_body := StaticBody2D.new()
	broad_body.position = Vector2(780,180)
	world.add_child(broad_body)
	var broad_visual: Node2D = Terrain.decorate(broad_body,600)
	var moving := AnimatableBody2D.new()
	moving.position = Vector2(800,470)
	world.add_child(moving)
	var moving_visual: Node2D = Terrain.decorate(moving,256)
	var optional := StaticBody2D.new()
	optional.position = Vector2(230,470)
	world.add_child(optional)
	var optional_visual: Node2D = Terrain.decorate(optional,256,true)
	await process_frame
	await process_frame
	assert(short_visual.depth == 144 and broad_visual.depth == 144)
	assert(moving_visual.depth == 56 and optional_visual.depth == 24)
	for visual in [short_visual,broad_visual,moving_visual,optional_visual]:
		var cap: NinePatchRect = visual.get_node("WalkableEarthCap")
		assert(cap.position.y == 0, "Walking edge must begin exactly at the collision top")
		assert(is_equal_approx(cap.size.x * cap.scale.x, visual.span), "Cap must cover exactly the platform width")
		assert(cap.axis_stretch_vertical == NinePatchRect.AXIS_STRETCH_MODE_STRETCH, "Foundation must not repeat vertically")
		assert(visual.foundation[0].y == 0 and visual.foundation[1].y == 0)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/jungle-terrain-qa.png")
	print("PASS: y=0 walkable cap, exact widths 256/600, non-tiled foundation, 144/56/24 depths")
	world.queue_free()
	await process_frame
	await process_frame
	var audio: Node = root.get_node_or_null("Audio")
	if audio:
		audio.shutdown()
	await create_timer(0.20).timeout
	quit()
