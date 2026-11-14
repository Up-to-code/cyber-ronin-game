extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var world:=Node2D.new();root.add_child(world)
 var camera:=Camera2D.new();camera.position=Vector2(576,324);camera.zoom=Vector2(.55,.55);world.add_child(camera)
 var bg:=Polygon2D.new();bg.polygon=PackedVector2Array([Vector2.ZERO,Vector2(1152,0),Vector2(1152,648),Vector2(0,648)]);bg.color=Color("211321");world.add_child(bg)
 var p=load("res://actors/player_2d.gd").new();p.position=Vector2(160,490);world.add_child(p);p.set_physics_process(false)
 var fx=load("res://systems/pixel_fx.gd").new();world.add_child(fx);p.fx_requested.connect(fx.spawn)
 for pair in [["relic_laser",260],["laser_seal",560],["relic_cloud",730],["portal",960]]:
  var d=load("res://systems/realm_device.gd").new();d.setup(p,{"id":pair[0],"type":pair[0],"position":[pair[1],490]});world.add_child(d)
 for i in range(4):await process_frame
 p.grant_relic("laser");p.use_relic_laser()
 for i in range(18):await physics_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/relic-devices-native.png")
 root.get_node("Audio").shutdown()
 quit()
