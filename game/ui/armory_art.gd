extends RefCounted
## Generated art is sliced at runtime; text and ownership remain live.
const ROOT := "res://art/armory-grid/"
const ICONS := [Rect2(812,132,266,246),Rect2(1082,132,266,246),Rect2(1352,132,274,246),Rect2(812,388,266,250),Rect2(1082,388,266,250),Rect2(1352,388,274,250)]
const GEAR := [Rect2(171,765,127,126),Rect2(305,765,132,126),Rect2(440,765,132,126),Rect2(576,765,130,126)]
static func atlas(asset: String, region: Rect2) -> AtlasTexture:
 var result := AtlasTexture.new()
 result.atlas = load(ROOT+asset+".png")
 result.region = region
 return result
static func icon(index: int) -> Texture2D:
 return atlas("icons",ICONS[index])
static func font() -> SystemFont:
 var result := SystemFont.new()
 result.font_names = PackedStringArray(["Baskerville","Times New Roman","serif"])
 return result
static func outline(color: Color, width: int = 3) -> StyleBoxFlat:
 var result := StyleBoxFlat.new()
 result.bg_color = Color.TRANSPARENT
 result.border_color = color
 for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: result.set_border_width(side,width)
 return result
