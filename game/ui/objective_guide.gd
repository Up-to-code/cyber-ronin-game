extends PanelContainer
var instruction: Label
var target_line: Label
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var style:=StyleBoxFlat.new()
 style.bg_color=Color(.035,.02,.05,.52)
 style.border_color=Color("9b7141")
 style.border_width_left=2
 for side in [SIDE_LEFT,SIDE_RIGHT]:style.set_content_margin(side,6)
 for side in [SIDE_TOP,SIDE_BOTTOM]:style.set_content_margin(side,3)
 add_theme_stylebox_override("panel",style)
 var box:=VBoxContainer.new();box.add_theme_constant_override("separation",1);add_child(box)
 instruction=Label.new();instruction.clip_text=true;instruction.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;instruction.add_theme_font_size_override("font_size",11);instruction.add_theme_color_override("font_color",Color("ffe2a0"));box.add_child(instruction)
 target_line=Label.new();target_line.add_theme_font_size_override("font_size",10);target_line.add_theme_color_override("font_color",Color("95e0df"));target_line.clip_text=true;target_line.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;box.add_child(target_line)
 get_viewport().size_changed.connect(_layout);_layout()
func _layout() -> void:
 var available: Vector2=get_parent().size if get_parent() is Control else get_viewport_rect().size
 var content_width: float=148
 if is_instance_valid(instruction):
  content_width=maxf(content_width,instruction.get_theme_font("font").get_string_size(instruction.text,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x+14)
  content_width=maxf(content_width,target_line.get_theme_font("font").get_string_size(target_line.text,HORIZONTAL_ALIGNMENT_LEFT,-1,10).x+14)
 var width:float=minf(minf(240,content_width),maxf(140,available.x-300))
 set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 var left:float=floorf((available.x-width)/2)
 var top:float=2
 if available.x<480:
  left=152
  width=minf(content_width,maxf(100,available.x-left-8))
  top=49
 offset_left=left;offset_right=left+width;offset_top=top;offset_bottom=top+31
 size=Vector2(width,31)

func refresh(text: String, target: Dictionary, feet: Vector2) -> void:
 if not is_instance_valid(instruction):return
 var short: String=text.split("•")[0].strip_edges()
 match target.get("kind",""):
  "relic_laser":short="Take Sun Core · charge laser"
  "laser_seal":short="Face seal · fire X / G"
  "relic_cloud":short="Take Cloud Seed · grow bridge"
  "cloud_anchor":short="E at loom · climb for vow"
  "portal":short="E at engine · enter realm"
  "sequence":short="Stand on pad · follow arrows"
  "surface":short="Pearls found · rise to exit"
 instruction.text=short
 tooltip_text=text
 if target.is_empty():
  target_line.text="";_layout();return
 var offset:Vector2=target.position-feet
 var direction: String="HERE"
 if offset.length()>75:
  direction=("LEFT" if offset.x<0 else "RIGHT") if absf(offset.x)>absf(offset.y)*1.2 else ("UP" if offset.y<0 else "DOWN")
 target_line.text="%s  •  %s  •  %dm"%[direction,target.label,roundi(offset.length()/32)]
 set_meta("accessible_description",text+" "+target_line.text)
 _layout()
