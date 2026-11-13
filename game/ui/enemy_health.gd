extends Node2D
## Health is pushed by the enemy after spawn configuration and on every hit.
var current := 1
var maximum := 1
var boss := false
var delayed := 1.0
var hit_age := 1.0
func set_health(value: int, total: int, major: bool = false) -> void:
	current = value
	maximum = maxi(1,total)
	boss = major
	hit_age = 0
	visible = current>0
	queue_redraw()
func _process(delta: float) -> void:
	hit_age += delta
	var target := float(current)/maximum
	if hit_age>0.18: delayed = move_toward(delayed,target,delta*1.6)
	if hit_age<1.2: queue_redraw()
func _draw() -> void:
	var width := 64 if boss else 38
	var start := Vector2(-width/2,-3)
	draw_rect(Rect2(start-Vector2(2,2),Vector2(width+4,9)),Color("190d18"))
	draw_rect(Rect2(start,Vector2(width,5)),Color("481b2b"))
	draw_rect(Rect2(start,Vector2(floor(width*delayed),5)),Color("e9b794"))
	draw_rect(Rect2(start,Vector2(floor(width*float(current)/maximum),5)),Color("c93242"))
	draw_rect(Rect2(start,Vector2(floor(width*float(current)/maximum),1)),Color("f16b60"))
	for i in range(1,4): draw_rect(Rect2(start+Vector2(floor(width*i/4.0),0),Vector2(1,5)),Color("32131f"))
	if boss:
		for x in [-5,0,5]: draw_rect(Rect2(Vector2(x-1,-8),Vector2(3,3)),Color("ecd1a4"))
