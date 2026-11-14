extends Node2D
signal collected(kind: String, amount: int, at: Vector2)
var kind := "coin"
var amount := 5
var target: CharacterBody2D
var age := 0.0
var taken := false
var visual: Sprite2D
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_PAUSABLE
 add_to_group("world_pickups")
 visual=Sprite2D.new()
 visual.texture=load("res://art/pickups/"+kind+".png")
 visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 visual.scale=Vector2(1.25,1.25)
 add_child(visual)
 z_index=3
func _physics_process(delta: float) -> void:
 age+=delta
 visual.position.y=roundf(sin(age*3.5)*4)
 if taken or not is_instance_valid(target) or target.health<=0: return
 if kind=="health" and target.health>=target.max_health: return
 var chest:=target.global_position+Vector2(0,-45)
 if chest.distance_to(global_position)<60:
  var query:=PhysicsRayQueryParameters2D.create(global_position,chest,1)
  if get_world_2d().direct_space_state.intersect_ray(query).is_empty():
   taken=true
   collected.emit(kind,amount,global_position)
   queue_free()
