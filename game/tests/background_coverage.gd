extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(42);await scene.level_loaded
 assert(scene.background_layers.size()==4)
 for biome in ["surface","underground","sky","citadel"]:
  var view=scene.map.duplicate();view.biome=biome;scene._set_background(view)
  for extent in [Vector2(640,360),Vector2(1000,360),Vector2(480,640),Vector2(2560,720)]:
   for shift in [Vector2.ZERO,Vector2(100000,2000),Vector2(-3000,-2000)]:
    scene._layout_background(extent,shift)
    for layer in scene.background_layers:
     var first: Sprite2D=layer.sprites[0]
     var size: Vector2=first.texture.get_size()*first.scale
     assert(first.position.x<=0)
     var right: float=first.position.x+size.x
     for i in range(1,layer.sprites.size()):
      var tile: Sprite2D=layer.sprites[i]
      if not tile.visible:continue
      assert(absf(tile.position.x-right)<0.01,"No overlap or gap between actual texture bounds")
      assert(tile.position.y==first.position.y,"All tiles share one vertical offset")
      right=tile.position.x+size.x
     assert(right>=extent.x)
     if not layer.mist:
      assert(first.position.y<=0 and first.position.y+size.y>=extent.y,"Top and bottom cover all viewport shapes and camera heights")
 root.get_node("Audio").shutdown()
 print("PASS: four layers, real texture widths, contiguous tiles, vertical coverage at 48 biome/viewport/camera combinations")
 quit()
