extends Node2D
## Whole-character replacement drawings. Gameplay owns action time and collision.
var actor: CharacterBody2D
var signature: Dictionary={}
var manifest: Dictionary={}
var frames: Array[Texture2D]=[]
var sprite: Sprite2D
var gait:=0.0
var clock:=0.0
var lunge:=0.0
var phase:="idle"
var progress:=0.0
var frame_index:=0
var dying:=false
var death_facing:=1.0
var last_step:=-1
var cadence:=0.0
func configure(target: CharacterBody2D,data: Dictionary) -> void:
 actor=target;signature=data.duplicate(true)
 manifest=JSON.parse_string(FileAccess.get_file_as_string("res://art/monster-cels/%03d.json"%actor.monster_id))
 var atlas: Texture2D=load(manifest.texture)
 var size: int=int(manifest.get("cell_size",128));var columns: int=int(manifest.get("columns",4))
 frames.clear()
 for i in range(int(atlas.get_width()/size)*int(atlas.get_height()/size)):
  var frame:=AtlasTexture.new();frame.atlas=atlas;frame.region=Rect2((i%columns)*size,(i/columns)*size,size,size);frames.append(frame)
 if not is_instance_valid(sprite):
  sprite=Sprite2D.new();sprite.centered=false;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite)
 actor.rig.set_meta("monster_cel_visual",self)
 tick(0)
func begin_death() -> void:
 if dying:return
 dying=true;death_facing=actor.facing
func _clip(name: String,fallback: Array) -> Array:
 return manifest.get("clips",{}).get(name,fallback)
func _choose_frame(clip: Array,t: float) -> int:
 return int(clip[clampi(int(clampf(t,0,.99999)*clip.size()),0,clip.size()-1)])
func tick(delta: float) -> void:
 if frames.is_empty():return
 clock+=delta
 var speed: float=actor.velocity.length() if actor.swimming else absf(actor.velocity.x)
 var moving: bool=speed>12 and (actor.is_on_floor() or actor.swimming or actor._is_hovering())
 var flying: bool=actor.swimming or actor._is_hovering()
 var cycle_distance: float=clampf(float(signature.get("stride",30)),28,80)
 gait+=delta*(clampf(speed/cycle_distance,1.8,3.5) if flying else speed/cycle_distance)
 var body: Dictionary=actor.action_body_state()
 if actor.health<=0:
  begin_death();phase="death";progress=clampf(actor.death_elapsed/.55,0,1)
  frame_index=_choose_frame(_clip("death",[10,11]),progress)
  modulate.a=1-clampf((actor.death_elapsed-.9)/.35,0,1)
 elif actor.hurt_left>0:
  phase="hurt";progress=1-actor.hit_reaction;frame_index=_choose_frame(_clip("hurt",[8,9]),progress)
 elif body.phase=="windup":
  phase="windup";progress=body.progress;frame_index=int(_clip("attack",[4,5,6,7])[0])
 elif body.phase=="strike":
  phase="strike";progress=body.progress
  var attack: Array=_clip("attack",[4,5,6,7]);frame_index=int(attack[1 if progress<.6 else 2])
 elif body.phase=="recovery":
  phase="recovery";progress=0;frame_index=int(_clip("attack",[4,5,6,7]).back())
 elif moving or flying:
  phase="travel";progress=fposmod(gait,1);frame_index=_choose_frame(_clip("walk",[0,1,2,3]),progress)
 else:
  phase="idle";progress=0;frame_index=int(_clip("idle",[7])[0])
 lunge=-.25*progress if phase=="windup" else (sin(progress*PI)*.5 if phase=="strike" else 0)
 var rig=actor.rig
 var art_scale: float=float(rig.profile.get("scale",2))
 var center: float=float(rig.profile.get("body_center_height",58))
 var origins: Array=manifest.get("origins",[])
 var anchor: Array=origins[frame_index] if origins.size()>frame_index else manifest.get("feet_origin",[64,112])
 var origin:=Vector2(float(anchor[0]),float(anchor[1]))
 var face: float=death_facing if dying else actor.facing
 var size: float=float(manifest.get("cell_size",128))
 sprite.texture=frames[frame_index];sprite.flip_h=face<0
 sprite.scale=Vector2.ONE*art_scale
 sprite.position=Vector2(-(size-origin.x if face<0 else origin.x)*art_scale,-origin.y*art_scale+center)
 if phase=="travel" and not flying and frame_index!=last_step and frame_index in [0,2] and actor.footstep_cooldown<=0:
  if is_instance_valid(actor.target) and actor.target.global_position.distance_to(actor.global_position)<360:
   actor._audio("enemy_step");actor.footstep_cooldown=.15
 last_step=frame_index if phase=="travel" else -1
 rig.sprite.hide();rig.body_pivot.rotation=0
 visible=true
func create_snapshot() -> Node2D:
 var copy:=Node2D.new();copy.scale=actor.rig.global_scale;var drawing:=Sprite2D.new();drawing.texture=sprite.texture;drawing.centered=false;drawing.flip_h=sprite.flip_h;drawing.transform=actor.rig.body_pivot.transform*sprite.transform;drawing.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;copy.add_child(drawing);return copy
