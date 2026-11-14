extends Node2D
# Transient pixel strokes around the feet; body artwork remains untransformed.
var kind:="jump"
var direction:=1.0
var age:=0.0
var lifetime:=.34
func _process(delta: float) -> void:
 age+=delta
 if age>=lifetime:queue_free()
 queue_redraw()
func _draw() -> void:
 var t:=clampf(age/lifetime,0,1)
 var tint:=Color("a4dad3") if kind=="air_jump" else Color("e9c69c")
 tint.a=(1-t)*.8
 if kind=="air_jump":
  # Broken ascending helix: the second jump has an unmistakable aerial signature.
  for side in [-1,1]:
   for i in range(7):
    var u:=float(i)/7
    var x: float=side*(26+20*t)*cos(u*PI*.8)
    var y: float=-u*52-18*t
    draw_rect(Rect2(Vector2(x,y).round(),Vector2(6,3)),tint)
 else:
  # Takeoff lifts strips vertically; landing fans gravel along the contact plane.
  for i in range(10):
   var side:=-1 if i%2==0 else 1
   var landing:=kind in ["land","aerial_land"]
   var x: float=side*(8+(i/2)*5+t*(48 if landing else 12))
   var y: float=(-sin(t*PI)*12 if landing else -t*38)-float(i%3)*4
   draw_rect(Rect2(Vector2(x,y).round(),Vector2(5 if landing else 3,3 if landing else 7)),tint)
