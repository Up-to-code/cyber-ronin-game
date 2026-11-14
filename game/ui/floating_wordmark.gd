extends VBoxContainer
## Live pixel-font identity, sharing the game's palette and scenery.
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_theme_constant_override("separation",4)
 for line in [["ASHEN",32],["VEIL",40],["100 ROUTES. ONE BLADE.",10]]:
  var label:=Label.new()
  label.text=line[0]
  label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  label.add_theme_font_size_override("font_size",line[1])
  label.add_theme_color_override("font_color",Color("f7dfae"))
  label.add_theme_color_override("font_shadow_color",Color("0b101d"))
  label.add_theme_constant_override("shadow_offset_x",2)
  label.add_theme_constant_override("shadow_offset_y",3)
  add_child(label)
