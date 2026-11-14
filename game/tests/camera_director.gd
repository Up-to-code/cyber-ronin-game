extends SceneTree
const CameraDirector = preload("res://systems/run/camera_director.gd")
func _initialize(): call_deferred("run")
func run():
	var map := {
		"width": 2000, "height": 950,
		"platforms": [{"center": Vector2(600, 500), "width": 400, "route": true}],
	}
	var body := CharacterBody2D.new()
	body.position = Vector2(600, 450)
	var camera := Camera2D.new()
	camera.zoom = Vector2(0.69, 0.69)
	var director = CameraDirector.new()
	director.add_trauma(0.2)
	assert(is_equal_approx(director.trauma, 0.2))
	director.add_trauma(2.0)
	assert(director.trauma <= 0.65, "trauma must stay bounded")
	director.reset()
	assert(director.trauma == 0.0 and not director.initialized)
	director.update(0.016, camera, map, body, Vector2(1280, 720), false)
	assert(director.initialized, "first update snaps the camera")
	assert(camera.position.x >= 0 and camera.position.x <= 2000)
	assert(camera.position.y >= 180 and camera.position.y <= 650)
	assert(camera.offset.length() < 0.01, "no shake without trauma")
	director.add_trauma(0.5)
	director.update(0.016, camera, map, body, Vector2(1280, 720), true)
	assert(camera.offset.length() <= 12.01, "shake must stay bounded")
	body.free()
	camera.free()
	print("PASS camera director bounded trauma, snap, clamp and pause")
	quit()
