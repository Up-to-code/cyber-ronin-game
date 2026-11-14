extends SceneTree
const Campaign=preload("res://data/campaign.gd")
func _initialize():
 var checked:=0
 for map in Campaign.levels():
  var style:Dictionary=map.gate_visual
  assert(style.scale==[0.65,1.0] and style.offset==[0.0,-88.0])
  var size:=Vector2(style.size[0],style.size[1])
  var frame:=Rect2(map.exit-Vector2(size.x/2,size.y),size)
  var supported:=false
  for deck in map.platforms:
   var geometry:=Rect2(deck.center-Vector2(deck.width/2,0),Vector2(deck.width,deck.depth))
   assert(not frame.intersects(geometry),"Exit art must not overlap another route platform")
   if absf(map.exit.y-deck.center.y)<1 and map.exit.x-size.x/2>=deck.center.x-deck.width/2 and map.exit.x+size.x/2<=deck.center.x+deck.width/2:supported=true
  assert(supported,"Full exit frame must stand on its deck, not float over the edge")
  assert(frame.position.x>=0 and frame.end.x<=map.width and frame.position.y>=0)
  if int(map.id)==8:assert(not map.water_bounds.has_point(map.exit))
  if int(map.id)==11:
   assert(map.exit==Vector2(3535.52,715))
   var cockpit:Vector2=map.exit-Vector2(160,0)
   assert(cockpit.x>map.platforms.back().center.x-map.platforms.back().width/2)
  checked+=1
 print("PASS ",checked," compact exit frames: grounded full width, clear of masonry, within world; dry palace exit and level11 cockpit preserved")
 quit()
