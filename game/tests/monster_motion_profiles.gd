extends SceneTree
func _initialize():
 var checked:=0
 for id in range(1,101):
  var path: String="res://art/monster-cels/%03d.json"%id
  assert(FileAccess.file_exists(path),"Missing authored motion sheet %d"%id)
  var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
  var texture: Texture2D=load(manifest.texture)
  assert(texture!=null)
  var cell: int=manifest.cell_size
  var image:=texture.get_image()
  assert(image.get_size()==Vector2i(cell*4,cell*3))
  var unique: Dictionary={}
  for frame in range(12):
   var drawing:=image.get_region(Rect2i(frame%4*cell,frame/4*cell,cell,cell))
   assert(drawing.get_used_rect().has_area(),"Empty frame")
   unique[hash(drawing.get_data())]=true
  assert(unique.size()==12,"Every pose must have distinct image data")
  assert(manifest.clips.walk.size()==4 and manifest.clips.attack.size()==4)
  assert(manifest.clips.hurt.size()==2 and manifest.clips.death.size()==2)
  checked+=1
 print("PASS: ",checked," actual 12-pose atlases, nonempty unique drawings and required state coverage; not visual approval")
 quit()
