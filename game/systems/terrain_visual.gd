class_name TerrainVisual
extends Node2D
## Presentation only: the owner's collider defines the flat walkable surface at y=0.
## A shallow generated earth cap sits above a non-tiled dark foundation.
var span: float = 256
var depth: float = 144
var one_way: bool = false
var variant_seed: int = 0
var foundation: PackedVector2Array = PackedVector2Array()

static func decorate(body: PhysicsBody2D, width: float, optional: bool = false) -> Node2D:
	var visual := TerrainVisual.new()
	visual.name = "JungleGround"
	visual.span = width
	visual.one_way = optional
	visual.depth = float(body.get_meta("foundation_depth", 24 if optional else (56 if body is AnimatableBody2D else 144)))
	visual.variant_seed = absi(int(body.position.x * 7 + body.position.y * 13))
	body.add_child(visual)
	return visual

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	var texture: Texture2D = load(path)
	var strip := NinePatchRect.new()
	strip.name = "WalkableEarthCap"
	strip.texture = texture
	strip.position = Vector2(-span * 0.5, 0)
	strip.size = Vector2(span * 0.5, minf(depth*0.5,32.0))
	strip.scale = Vector2(2, 2)
	strip.patch_margin_left = 2
	strip.patch_margin_right = 2
	strip.patch_margin_top = 0
	strip.patch_margin_bottom = 0
	strip.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
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

