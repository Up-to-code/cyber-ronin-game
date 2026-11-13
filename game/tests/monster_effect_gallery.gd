extends SceneTree
class Board extends Node2D:
 var records:Array=[]
 var page:=0
 var font=preload("res://art/pixel/PixelifySans.ttf")
 var textures: Dictionary={}
 func _ready():
  for record in records:textures[record.id]=load(record.motif_texture)
 func _draw():
  draw_rect(Rect2(0,0,1500,960),Color("161723"))
  for i in range(20):
   var record=records[page*20+i];var at=Vector2(i%5*300,i/5*240)
   draw_string(font,at+Vector2(12,24),"%03d %s"%[record.id,record.name],HORIZONTAL_ALIGNMENT_LEFT,280,14,Color("ffdf9e"))
   draw_string(font,at+Vector2(12,48),record.move,HORIZONTAL_ALIGNMENT_LEFT,280,12,Color("94dedb"))
   draw_texture_rect(textures[record.id],Rect2(at+Vector2(65,58),Vector2(150,150)),false)
   draw_string(font,at+Vector2(12,226),"%s > %s"%[record.events[0].path,record.events[1].path],HORIZONTAL_ALIGNMENT_LEFT,280,12,Color("c1b9c6"))
func _initialize():call_deferred("run")
func run():
 var viewport=SubViewport.new();viewport.size=Vector2i(1500,960);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
 var board=Board.new();board.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;board.records=JSON.parse_string(FileAccess.get_file_as_string("res://data/monster_choreography.json"));viewport.add_child(board)
 for page in range(5):
  board.page=page;board.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  viewport.get_texture().get_image().save_png("res://../docs/qa/individual-motifs-%d.png"%page)
 root.get_node("Audio").shutdown();viewport.queue_free();await process_frame;quit()
