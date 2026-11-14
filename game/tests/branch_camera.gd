extends SceneTree
func _initialize():
 var camera_rules=load("res://systems/route_camera.gd")
 for map in load("res://data/campaign.gd").levels():
  for link in map.get("branch_links",[]):
   var source: Dictionary=map.platforms[link[0]]
   if source.get("route",true):continue
   var target: Dictionary=map.platforms[link[1]]
   var point: Vector2=camera_rules.next_landing(map,source.center)
   assert(is_equal_approx(point.y,target.center.y),"Camera must target the branch's next ledge")
   var center: Vector2=camera_rules.focus(map,source.center,Vector2.ZERO)
   var screen: Vector2=(point-center)*0.69+Vector2(320,180)
   assert(screen.x>24 and screen.x<616 and screen.y>38 and screen.y<270)
 print("PASS: optional branch and recovery camera targets and framing")
 quit()
