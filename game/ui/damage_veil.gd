extends Control
## Pixel blood stays on the upper/side edges; never covers the combat center or input.
var drops: Array[Dictionary] = []
var sequence := 0
var variants: Array[AtlasTexture] = []
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(4):
		var art:=AtlasTexture.new()
		art.atlas=load("res://art/combat-feedback/blood-edge.png")
		art.region=Rect2(i*64,0,64,64)
		variants.append(art)
func splash(strength: float = 1.0) -> void:
	sequence += 1
	for i in range(6 if strength>0.7 else 3):
		var index := sequence*7+i
		drops.append({"x":fposmod(index*0.173,1.0),"age":-float(i%3)*0.03,"length":9+(index%5)*6,"life":0.8+strength*0.5,"side":i%4==0,"variant":index%4})
	while drops.size()>18: drops.pop_front()
	queue_redraw()
func clear() -> void:
	drops.clear()
	queue_redraw()
func _process(delta: float) -> void:
	if drops.is_empty(): return
	for i in range(drops.size()-1,-1,-1):
		drops[i].age += delta
		if drops[i].age>=drops[i].life: drops.remove_at(i)
	queue_redraw()
func _draw() -> void:
	if variants.is_empty(): return
	for drop in drops:
		var t: float = maxf(0,drop.age)
		var alpha: float = minf(0.78,(drop.life-t)*1.1)
		var x: float = floor(drop.x*size.x/2)*2
		var extent: float = 52+drop.length*0.3
		var point:=Vector2(x-extent/2,-extent*0.30+minf(6,t*5))
		if drop.side:
			point=Vector2(-extent*0.65 if drop.x<0.5 else size.x-extent*0.35,30+drop.x*size.y*0.18)
		draw_texture_rect(variants[drop.variant],Rect2(point.snapped(Vector2(2,2)),Vector2.ONE*extent),false,Color(1,1,1,alpha))
