extends RefCounted
# Owns the parallax background: builds its layers, swaps the theme textures and
# lays the tiles out for the current viewport. The scene only supplies data.
const LAYER_SPECS := [
	{"sky": true, "ratio": 0.035, "speed": 0.8, "mist": false},
	{"sky": false, "ratio": 0.10, "speed": 0.0, "mist": false},
	{"sky": false, "ratio": 0.18, "speed": 3.5, "mist": true},
	{"sky": false, "ratio": 0.26, "speed": 0.0, "mist": false},
]
const BIOME_TINT := {
	"sky": Color(0.72, 0.78, 0.88),
	"underground": Color(0.68, 0.70, 0.82),
	"citadel": Color(0.65, 0.60, 0.60),
	"underwater": Color(0.65, 0.8, 0.88),
}
const THEME_TINT := {
	"approach": Color(1, 0.9, 0.88),
	"courtyard": Color(1.1, 0.86, 0.8),
	"bamboo": Color(0.8, 0.78, 0.88),
	"rooftops": Color(0.88, 0.85, 1.0),
	"sanctuary": Color(1.0, 0.8, 0.85),
	"summit": Color(1.18, 0.76, 0.76),
}

var layers: Array[Dictionary] = []

static func backdrop_for(theme: String) -> String:
	match theme:
		"bamboo": return "bamboo"
		"rooftops", "sanctuary": return "roofs"
		_: return "castle"

func build(host: CanvasItem) -> void:
	var backdrop := CanvasLayer.new()
	backdrop.layer = -10
	host.add_child(backdrop)
	layers.clear()
	for spec in LAYER_SPECS:
		var sprites: Array[Sprite2D] = []
		for i in range(4):
			var visual := Sprite2D.new()
			visual.centered = false
			visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			visual.flip_h = i % 2 == 1
			visual.z_index = layers.size()
			backdrop.add_child(visual)
			sprites.append(visual)
		layers.append({"sprites": sprites, "ratio": spec.ratio, "speed": spec.speed, "sky": spec.sky, "mist": spec.mist})

func set_theme(data: Dictionary, textures: Dictionary, snow_field: Node) -> void:
	var biome: String = data.get("biome", "surface")
	if is_instance_valid(snow_field): snow_field.biome = biome
	if biome in ["underground", "sky", "citadel", "underwater"]:
		for layer in layers:
			for visual in layer.sprites:
				visual.texture = load("res://art/world-migration/%s.png" % biome) if layer.sky else preload("res://art/living-marsh/mist.png")
				visual.modulate = BIOME_TINT[biome] if layer.sky else Color(0.5, 0.7, 0.9, 0.10 if layer.mist else 0.0)
		return
	var sky_texture: Texture2D = preload("res://art/living-marsh/background.png")
	var near_texture: Texture2D = textures["res://art/pixel/" + backdrop_for(data.theme) + ".png"]
	var tint: Color = THEME_TINT[data.theme]
	for layer in layers:
		for visual in layer.sprites:
			if layer.mist:
				visual.texture = preload("res://art/living-marsh/mist.png")
				visual.modulate = Color(0.65, 0.48, 0.60, 0.18)
				continue
			visual.texture = sky_texture if layer.sky else near_texture
			if not layer.sky and layer.ratio < 0.2:
				visual.texture = load("res://art/concept-pass/skyline.png")
			elif not layer.sky and data.theme in ["approach", "courtyard"]:
				visual.texture = load("res://art/pixel/castle-separated.png")
			visual.modulate = tint
			if not layer.sky:
				visual.modulate *= Color(0.55, 0.48, 0.60, 0.40) if layer.ratio < 0.2 else Color(0.48, 0.40, 0.50, 0.68)

func layout(extent: Vector2, camera_shift: Vector2, elapsed: float) -> void:
	for layer in layers:
		var texture: Texture2D = layer.sprites[0].texture
		if texture == null: continue
		var native: Vector2 = texture.get_size()
		var factor: float
		var y: float
		if layer.sky:
			factor = maxf(extent.x / native.x, extent.y / native.y) * 1.18
			var excess := native * factor - extent
			var drift := Vector2(
				clampf(camera_shift.x * .025, -excess.x * .45, excess.x * .45),
				clampf(camera_shift.y * .015, -excess.y * .45, excess.y * .45))
			for i in range(layer.sprites.size()):
				var background: Sprite2D = layer.sprites[i]
				background.visible = i == 0
				background.flip_h = false
				background.scale = Vector2.ONE * factor
				background.position = (-excess * .5 - drift).floor()
			continue
		elif layer.mist:
			factor = maxf(1, extent.y / 360.0)
			y = extent.y * 0.36 + sin(elapsed * 0.2) * 4
		else:
			# Keep both cut texture edges outside the viewport at every camera height.
			factor = (extent.y + 128.0) / native.y
			y = -64.0 - clampf(camera_shift.y * layer.ratio * 0.25, -28, 28)
		var tile_width: float = ceilf(native.x * factor)
		factor = tile_width / native.x
		var offset: float = fposmod(camera_shift.x * 0.5 * layer.ratio + elapsed * layer.speed, tile_width * 2)
		var required: int = maxi(4, ceili(extent.x / tile_width) + 3)
		while layer.sprites.size() < required:
			var copy: Sprite2D = layer.sprites[0].duplicate()
			layer.sprites[0].get_parent().add_child(copy)
			layer.sprites.append(copy)
		for i in range(layer.sprites.size()):
			var visual: Sprite2D = layer.sprites[i]
			visual.visible = i < required
			visual.flip_h = i % 2 == 1
			visual.scale = Vector2.ONE * factor
			# One shared Y and integer tile pitch: no per-tile bob or width assumption.
			visual.position = Vector2(floorf(i * tile_width - offset), floorf(y))
