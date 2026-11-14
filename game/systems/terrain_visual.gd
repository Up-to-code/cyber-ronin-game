class_name TerrainVisual
extends Node2D
## Presentation only: the owner's collider defines the flat walkable surface at y=0.
## A shallow generated earth cap sits above a non-tiled dark foundation.
var biome := "surface"
var construction := "legacy"
var wall_shelf: bool = false
var span: float = 256
var depth: float = 144
var one_way: bool = false
var variant_seed: int = 0
var foundation: PackedVector2Array = PackedVector2Array()

static func decorate(body: PhysicsBody2D, width: float, optional: bool = false) -> Node2D:
	var visual := TerrainVisual.new()
	visual.name = "JungleGround"
	visual.span = width
	visual.biome = body.get_meta("biome","surface")
	visual.construction=body.get_meta("construction","legacy")
	visual.wall_shelf = body.get_meta("wall_shelf",false)
	visual.one_way = optional
	visual.depth = float(body.get_meta("foundation_depth", 24 if optional else (56 if body is AnimatableBody2D else 144)))
	visual.variant_seed = absi(int(body.position.x * 7 + body.position.y * 13))
	body.add_child(visual)
	return visual

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if biome == "underwater":
		_add_underwater_masonry()
		return
	if biome in ["sky","underground","citadel"]:
		_add_realm_terrain()
		return
	if construction in ["arch","rock","balcony"]:
		_add_architecture()
		return
	_build_foundation()
	_add_cap()
	if one_way: _add_root_details()
	queue_redraw()

func _build_foundation() -> void:
	var half: float = span * 0.5
	foundation.append(Vector2(-half, 0))
	foundation.append(Vector2(half, 0))
	# A single low-contrast mass, never a repeated tall tile. The broken lower edge
	# belongs to the visual only; it cannot change collision or player foot height.
	var count: int = maxi(3, ceili(span / 90))
	for i in range(count, -1, -1):
		var notch: float = float((i * 7 + variant_seed) % 4) * (2 if one_way else 4)
		foundation.append(Vector2(-half + span * i / count, depth - notch))

func _draw() -> void:
	if foundation.size() >= 3:
		draw_colored_polygon(foundation, Color("080b0d"))
		# A shallow irregular cut face separates walkable soil from deep foundation.
		# Its depth is presentation only; top contact remains exactly y=0.
		if depth <= 40: return
		var pieces: int = maxi(1,ceili(span/110.0))
		for i in range(pieces):
			var x0: float = -span*0.5+i*span/pieces
			var x1: float = -span*0.5+(i+1)*span/pieces
			var cut: float = minf(depth,34+float((variant_seed+i*13)%24))
			draw_colored_polygon(PackedVector2Array([Vector2(x0,20),Vector2(x1,20),Vector2(x1-8,cut-5),Vector2(lerpf(x0,x1,0.42),cut),Vector2(x0,cut-12)]),Color("111719") if i%2==0 else Color("0e1416"))

func _add_cap() -> void:
	var path: String = "res://art/concept-pass/stone.png" if one_way else "res://art/concept-pass/stone-continuous.png"
	if not ResourceLoader.exists(path):
		return
	if wall_shelf and ResourceLoader.exists("res://art/crimson-shaft/shelf.png"):
		path = "res://art/crimson-shaft/shelf.png"
	var texture: Texture2D = load(path)
	var strip := NinePatchRect.new()
	strip.name = "WalkableEarthCap"
	strip.texture = texture
	strip.position = Vector2(-span * 0.5, 0)
	strip.size = Vector2(span * 0.5, 24 if wall_shelf else minf(depth*0.5,32.0))
	strip.scale = Vector2(2, 2)
	strip.patch_margin_left = 2
	strip.patch_margin_right = 2
	strip.patch_margin_top = 0
	strip.patch_margin_bottom = 0
	strip.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH if wall_shelf else NinePatchRect.AXIS_STRETCH_MODE_TILE
	strip.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strip)

func _add_root_details() -> void:
	if one_way:
		return
	var path := "res://art/pixel/jungle_roots.png"
	if not ResourceLoader.exists(path):
		return
	var atlas: Texture2D = load(path)
	var count: int = maxi(1, floori(span / 220))
	for i in range(count):
		var variant: int = (i * 3 + variant_seed) % 4
		var piece := AtlasTexture.new()
		piece.atlas = atlas
		piece.region = Rect2(variant % 2 * 64, variant / 2 * 64, 64, 64)
		var roots := Sprite2D.new()
		roots.name = "SparseRootPatch%d" % i
		roots.texture = piece
		roots.centered = false
		var factor: float = minf(1.6, (depth - 22) / 64)
		roots.scale = Vector2(factor, factor)
		var available: float = maxf(0, span - 64 * factor - 24)
		var shift: float = float((variant_seed + i * 37) % 33) - 16
		roots.position = Vector2(-span * 0.5 + 12 + clampf(available * (i + 0.5) / count + shift, 0, available), 16)
		roots.modulate = Color(0.6, 0.65, 0.66, 0.8)
		add_child(roots)


func _add_architecture() -> void:
	if construction == "balcony":
		var support_depth: float = float(get_parent().get_meta("support_depth",0))
		if support_depth > 48:
			var pillar := NinePatchRect.new()
			pillar.name = "BalconyGroundSupport"
			pillar.texture = preload("res://art/crimson-gold/support.png")
			pillar.position = Vector2(-48,26)
			pillar.size = Vector2(96,support_depth-26)
			pillar.patch_margin_top = 24
			pillar.patch_margin_bottom = 24
			pillar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pillar.modulate = Color(0.65,0.60,0.60)
			add_child(pillar)
		var image := Sprite2D.new()
		image.name = "StructuralPlatformArt"
		image.texture = preload("res://art/vertical-world/balcony.png")
		image.centered = false
		image.position = Vector2(-span/2,-86*1.1)
		image.scale = Vector2(span/256,1.1)
		add_child(image)
		return
	# Opaque fill begins behind the cap, so no sky seam opens at the join.
	var fill := TextureRect.new()
	fill.name = "ContinuousFoundation"
	fill.texture = preload("res://art/crimson-gold/fill.png")
	fill.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fill.stretch_mode = TextureRect.STRETCH_TILE
	fill.position = Vector2(-span/2,8)
	fill.size = Vector2(span,maxf(1,depth-8))
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)
	var cap := NinePatchRect.new()
	cap.name = "AlignedWalkableCap"
	cap.texture = preload("res://art/crimson-gold/cap.png")
	cap.position = Vector2(-span/2,-2)
	cap.size = Vector2(span,minf(depth+2,72))
	cap.patch_margin_left = 12
	cap.patch_margin_right = 12
	cap.patch_margin_top = 8
	cap.patch_margin_bottom = 4
	cap.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cap)

func _add_realm_terrain() -> void:
	if biome != "sky" and depth > 48:
		# Fill the actual solid collider footprint. Texture tiling preserves pixel
		# scale instead of stretching one cap into a flat, unarticulated column.
		var fill := TextureRect.new()
		fill.name = "RealmMasonryFoundation"
		fill.texture = preload("res://art/vertical-world/wall.png") if biome == "underground" else preload("res://art/crimson-gold/fill.png")
		fill.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fill.stretch_mode = TextureRect.STRETCH_TILE
		fill.position = Vector2(-span/2,12)
		fill.size = Vector2(span,depth-12)
		fill.modulate = Color(1.15,1.25,1.7) if biome == "underground" else Color(.86,.72,.64)
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fill)
		# Recess the wall beneath the projecting cap, without implying another
		# walkable ledge or extending art beyond the solid collision footprint.
		var recess := ColorRect.new()
		recess.name = "CapRecessShadow"
		recess.color = Color(0.015,0.012,0.025,.35)
		recess.position = Vector2(-span/2,12)
		recess.size = Vector2(span,12)
		recess.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(recess)
	var cap := NinePatchRect.new()
	cap.name = "RealmWalkableCap"
	cap.texture = load("res://art/world-migration/citadel-corbel.png" if biome == "citadel" else "res://art/world-migration/%s-cap.png" % biome)
	cap.position = Vector2(-span/2,0)
	cap.size = Vector2(span,minf(depth+8,64))
	cap.patch_margin_left = 16
	cap.patch_margin_right = 16
	cap.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cap)

func _add_underwater_masonry() -> void:
	var stone := TextureRect.new()
	stone.texture = preload("res://art/tidal-castle/cap.png")
	stone.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	stone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stone.stretch_mode = TextureRect.STRETCH_TILE
	stone.position = Vector2(-span/2,0)
	stone.size = Vector2(span,depth)
	stone.modulate = Color(.6,.75,.8)
	stone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stone)
	var cap := NinePatchRect.new()
	cap.texture = stone.texture
	cap.position = Vector2(-span/2,0)
	cap.size = Vector2(span,24)
	cap.patch_margin_left = 12
	cap.patch_margin_right = 12
	cap.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cap)
	if span>250:
		for i in range(clampi(int(span/300),1,5)):
			var coral:=Sprite2D.new()
			coral.texture=preload("res://art/tidal-castle/coral.png") if i%2==0 else preload("res://art/tidal-castle/kelp.png")
			coral.position=Vector2(-span/2+70+i*280,-coral.texture.get_height()*.4)
			coral.scale=Vector2(.8,.8)
			coral.modulate=Color(.7,.85,.9)
			add_child(coral)
