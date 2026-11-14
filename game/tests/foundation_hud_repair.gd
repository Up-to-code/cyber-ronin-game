extends SceneTree
func _initialize():call_deferred("run")
func run():
 var safe:=Control.new();safe.theme=Theme.new();safe.theme.default_font=load("res://art/pixel/PixelifySans.ttf");root.add_child(safe)
 var guide=load("res://ui/objective_guide.gd").new();safe.add_child(guide)
 for viewport in [Vector2(320,640),Vector2(480,320),Vector2(616,340),Vector2(1000,700)]:
  safe.size=viewport
  for kind in ["guard","laser_seal","cloud_anchor","sequence","surface"]:
   guide.refresh("Defeat 3 guards",{"kind":kind,"label":"Sun Beam Seal","position":Vector2(400,400)},Vector2.ZERO)
   await process_frame
   assert(Rect2(Vector2.ZERO,viewport).encloses(guide.get_rect()),"Guide must stay inside safe parent")
   assert(guide.size.y<=36,"Guide must not grow into a tall top-center obstruction")
   assert(guide.size.x<=240,"Guide remains compact")
   assert(not guide.instruction.text.is_empty())
 for biome in ["underground","citadel"]:
  var body:=StaticBody2D.new();body.set_meta("biome",biome);body.set_meta("foundation_depth",500);root.add_child(body)
  var visual=load("res://systems/terrain_visual.gd").decorate(body,400)
  var fill=visual.get_node("RealmMasonryFoundation")
  assert(fill is TextureRect and fill.texture!=null)
  assert(fill.position==Vector2(-200,12) and fill.size==Vector2(400,488),"Masonry follows solid footprint")
  assert(visual.get_child_count()<=3,"Foundation keeps bounded node count")
  body.free()
 root.get_node("Audio").shutdown();print("PASS compact safe-parent HUD at four aspect sizes; textured foundations preserve footprint with three nodes");quit()
