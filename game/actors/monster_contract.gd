extends Node2D
## One attack clock owns preparation, emission, travel, contact and recovery.
signal action_started(monster_id: int, move: String)
signal damage_contact(monster_id: int, event_name: String, hit: bool)
signal action_ended(monster_id: int)
var actor: CharacterBody2D
var marks: Array[Dictionary]=[]
var contacts:=0
var action_active:=false
var current_action_time:=0.0
var current_action_duration:=0.0
var current_action_phase:="idle"
var sound_cooldown:=0.0
var locked_facing:=1.0
var locked_origin:=Vector2.ZERO
var locked_target:=Vector2.ZERO
var motif_texture: Texture2D
var choreography: Dictionary={}
static var library: Dictionary={}
static var sound_cache: Dictionary={}
const SUPPORTED_PATHS=["straight","leap","lob","wave","float","return","orbit","spiral","sweep","drop","rain","rise","charge","pincer","collapse","fan","expand"]
const COLORS={"blood":Color("dc3651"),"fire":Color("ff9b43"),"frost":Color("9be7ed"),"thunder":Color("f4d85c"),"void":Color("b68be0"),"water":Color("65dbe7")}

func _ready() -> void:
	top_level=true
	global_position=Vector2.ZERO
	z_index=4
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("monster_contracts")

func get_choreography() -> Dictionary:
	if library.is_empty():
		var parsed=JSON.parse_string(FileAccess.get_file_as_string("res://data/monster_choreography.json"))
		if parsed is Array:
			for record in parsed:library[int(record.id)]=record
	return library.get(actor.monster_id,{}) if is_instance_valid(actor) else {}

func cancel_action() -> void:
	marks.clear()
	action_active=false
	current_action_phase="idle"
	current_action_time=0
	queue_redraw()

func cast() -> void:
	if not is_instance_valid(actor.target) or actor.health<=0:return
	cancel_action()
	choreography=get_choreography()
	if choreography.is_empty():return
	locked_facing=actor.facing
	locked_origin=actor.global_position
	locked_target=actor.target.global_position
	current_action_duration=float(choreography.motion.windup)+float(choreography.motion.commit)+float(choreography.motion.recovery)
	action_active=true
	current_action_phase="tell"
	if ResourceLoader.exists(choreography.motif_texture):motif_texture=load(choreography.motif_texture)
	action_started.emit(actor.monster_id,choreography.move)
	_sound("cast",locked_origin)
	if actor.swimming:
		_cast_water()
		return
	for event in choreography.events:
		if event.get("phase_only",false) and (not actor.is_boss or actor.health>actor.max_health/2):continue
		if event.has("branches"):
			for angle in event.branches:
				var branch:Dictionary=event.duplicate(true)
				var destination:=Vector2(event.destination[0],event.destination[1]).rotated(float(angle))
				branch.destination=[destination.x,destination.y]
				_schedule(branch)
		else:_schedule(event)

func _schedule(event: Dictionary) -> void:
	if marks.size()>=12:return
	var total:=0
	for node in get_tree().get_nodes_in_group("monster_contracts"):total+=node.marks.size()
	if total>=64:return
	var offset:=Vector2(event.offset[0]*locked_facing,event.offset[1])
	var destination:=Vector2(event.destination[0]*locked_facing,event.destination[1])
	var anchor: Vector2=locked_target if event.origin=="target" else locked_origin
	var start: Vector2=anchor+offset
	var end: Vector2=anchor+destination
	var contact_at:=float(event.at)+float(event.tell)+float(event.travel)
	current_action_duration=maxf(current_action_duration,contact_at+float(event.hold)+.02)
	marks.append({"event":event,"start":start,"at":end,"visual_at":start,"size":Vector2(event.size[0],event.size[1]),"left":contact_at,"delay":contact_at,"contact_at":contact_at,"fired":false,"emitted":false,"life":float(event.hold),"element":"water" if actor.swimming else actor.roster_spec.get("element","blood"),"trail":[]})

func _physics_process(delta: float) -> void:
	sound_cooldown=maxf(0,sound_cooldown-delta)
	if not is_instance_valid(actor) or actor.health<=0:
		cancel_action();return
	if not action_active:return
	current_action_time+=delta
	var windup:float=choreography.motion.windup
	var commit:float=choreography.motion.commit
	current_action_phase="tell" if current_action_time<windup else ("commit" if current_action_time<windup+commit else "recovery")
	for mark in marks:
		var event:Dictionary=mark.event
		var emitted_at:=float(event.at)+float(event.tell)
		mark.left=mark.contact_at-current_action_time
		if current_action_time>=emitted_at and not mark.emitted:
			mark.emitted=true
			if event.origin=="actor" and actor.has_method("attack_origin"):
				# The visual emitter follows the actual pose, while its committed lane stays locked.
				var facing_correction: float=locked_facing/actor.facing if absf(actor.facing)>.1 else 1.0
				mark.start=actor.attack_origin(Vector2(event.offset[0]*facing_correction,event.offset[1]))
		var travel_progress:=clampf((current_action_time-emitted_at)/maxf(.01,float(event.travel)),0,1)
		var previous:Vector2=mark.visual_at
		mark.visual_at=_path_position(mark.start,mark.at,travel_progress,event.path,mark.size)
		if mark.emitted and not mark.fired:
			mark.trail.append(mark.visual_at)
			if mark.trail.size()>5:mark.trail.pop_front()
		if mark.emitted and not mark.fired and event.get("collision_mode","arrival")=="sweep" and _sweep_hits(previous,mark.visual_at,mark.size):
			mark["swept_contact"]=true
			mark.at=mark.visual_at
			mark.contact_at=current_action_time
			mark.left=0
		if mark.left<=0 and not mark.fired:
			mark.fired=true
			var hit:=_contact(mark)
			damage_contact.emit(actor.monster_id,event.name,hit)
			_sound("contact",mark.at)
	marks=marks.filter(func(m):return m.left > -m.life)
	if current_action_time>=current_action_duration:
		action_active=false
		current_action_phase="idle"
		marks.clear()
		action_ended.emit(actor.monster_id)
	queue_redraw()

func _contact(mark: Dictionary) -> bool:
	var victim=actor.target
	if not is_instance_valid(victim) or victim.health<=0:return false
	var rect:=Rect2(mark.at-mark.size*.5,mark.size)
	var victim_rect:=Rect2(victim.global_position+Vector2(-15,-90),Vector2(30,90))
	if not mark.get("swept_contact",false) and not rect.intersects(victim_rect):return false
	var before:int=victim.health
	victim.take_damage(maxi(1,roundi(actor.melee_damage*float(mark.event.get("damage_scale",1)))),locked_facing)
	if victim.health>=before:return false
	contacts+=1
	return true

func _path_position(start: Vector2,end: Vector2,p: float,path: String,size: Vector2) -> Vector2:
	var point:=start.lerp(end,p)
	match path:
		"leap","lob":point.y-=sin(p*PI)*maxf(45,size.y)
		"wave","float":point.y+=sin(p*TAU*1.5)*size.y*.45*sin(p*PI)
		"return":point=start.lerp(end,sin(p*PI*.5));point.y-=sin(p*TAU)*size.y*.5
		"orbit","spiral":point+=Vector2.from_angle(p*TAU*(2 if path=="spiral" else 1))*sin(p*PI)*size.x*.55
		"fan":point.y+=sin(p*PI)*size.y*.75
		"expand":point=start.lerp(end,sqrt(p))
		"sweep":point.y+=sin(p*PI)*size.y*.5
		"drop","rain":point.y=lerpf(start.y-110,end.y,p*p)
		"rise":point.y=lerpf(start.y+70,end.y,sqrt(p))
		"charge","straight":point=start.lerp(end,p*p)
		"pincer":point.x+=sin(p*PI)*size.x*.6*locked_facing
		"collapse":point=start.lerp(end,1-pow(1-p,3))
	return point

func _draw() -> void:
	for mark in marks:
		var event:Dictionary=mark.event
		if current_action_time<float(event.at):continue
		var color:Color=COLORS[mark.element]
		if not mark.emitted:
			var progress:=clampf((current_action_time-float(event.at))/maxf(.01,float(event.tell)),0,1)
			_draw_motif(mark.at,mark.size*(.5+progress*.5),Color(1,1,1,.18+progress*.28),event.shape)
			# The thin path previews travel, not a generic corner box or rune.
			var points:=PackedVector2Array()
			for i in range(9):points.append(_path_position(mark.start,mark.at,float(i)/8,event.path,mark.size))
			draw_polyline(points,Color(color,.15+progress*.2),1)
		elif not mark.fired:
			for i in range(mark.trail.size()):
				_draw_motif(mark.trail[i],mark.size*.55,Color(1,1,1,.06+float(i)*.035),event.shape)
			_draw_motif(mark.visual_at,mark.size,Color.WHITE,event.shape)
		else:
			var progress:=clampf(-mark.left/mark.life,0,1)
			_draw_motif(mark.at,mark.size*(1+progress*.35),Color(1,1,1,1-progress),event.shape)
			_draw_contact_particles(mark,progress,color)


func _draw_contact_particles(mark: Dictionary,progress: float,color: Color) -> void:
	# Contact-only burst, aligned to the authored attack's direction and element.
	# Deterministic bounded pixels add recoil/decay without hiding the enemy silhouette.
	var aquatic: bool=mark.element=="water"
	for i in range(7):
		var angle: float=float(i)*TAU/7+float(actor.monster_id%13)*.17
		var ray:=Vector2.from_angle(angle)
		var reach: float=(8+float((i*7+actor.monster_id)%23))*progress
		var point: Vector2=(mark.at+ray*reach+Vector2(0,(-14 if mark.element=="fire" else 12)*progress*progress)).snapped(Vector2(2,2))
		var tint:=Color(color,1-progress)
		if aquatic:draw_rect(Rect2(point,Vector2(3,3)),tint,false,1)
		else:draw_rect(Rect2(point,Vector2(2+i%2,2+i%2)),tint)
	if progress<.18:
		var flash: Vector2=mark.size*.12
		draw_line(mark.at-Vector2(flash.x,0),mark.at+Vector2(flash.x,0),Color(1,.94,.78,1-progress/.18),2)

func _draw_motif(at: Vector2,size: Vector2,color: Color,shape: String) -> void:
	if is_instance_valid(motif_texture) and not actor.swimming:
		var facing_size:=Vector2(size.x*locked_facing,size.y)
		draw_texture_rect(motif_texture,Rect2(at-facing_size*.5,facing_size),false,color)
	else:
		for i in range(3):draw_arc(at,(8+i*7)*(size.x/80),0,TAU,12,Color(.4,.9,1,color.a),2)
	# Shape-specific emitter glints follow each image's authored delivery, not elemental recolors.
	if shape in ["needle","spear","arrow","line","sting"]:draw_line(at-Vector2(size.x*.45,0),at+Vector2(size.x*.45,0),Color(1,.95,.8,color.a*.6),2)

func _cast_water() -> void:
	var windup:float=choreography.motion.windup
	var origin:=Vector2(0,-50)
	match actor.swim_role:
		"eel":
			_schedule({"name":"Current stitch","at":0,"tell":windup,"travel":.32,"hold":.2,"shape":"jet","path":"wave","origin":"actor","offset":[0,-50],"destination":[220,-50],"size":[65,50]})
		"crab":
			for side in [-1,1]:_schedule({"name":"Closing claw","at":0,"tell":windup,"travel":.3,"hold":.2,"shape":"claw","path":"pincer","origin":"actor","offset":[side*100,-50],"destination":[side*40,-50],"size":[55,75]})
		_:
			for i in range(8):
				var direction:=Vector2.from_angle(i*TAU/8)*115
				_schedule({"name":"Luminous pulse","at":0,"tell":windup,"travel":.45,"hold":.2,"shape":"ring","path":"straight","origin":"actor","offset":[0,-50],"destination":[direction.x,direction.y-50],"size":[42,42]})

func _sound(cue: String,at: Vector2) -> void:
	var audio=get_node_or_null("/root/Audio")
	if is_instance_valid(audio) and not audio.enabled:return
	if sound_cooldown>0 or get_tree().get_nodes_in_group("monster_sfx").size()>=8:return
	if not is_instance_valid(actor.target) or actor.target.global_position.distance_to(at)>1000:return
	var key:="%d_%s"%[actor.monster_id,cue]
	if not sound_cache.has(key):sound_cache[key]=_synthesize(choreography.sound,cue)
	var voice:=AudioStreamPlayer2D.new()
	voice.stream=sound_cache[key]
	voice.volume_db=-16 if cue=="cast" else -13
	voice.max_distance=1000
	if AudioServer.get_bus_index("EnemyCombat")>=0:voice.bus="EnemyCombat"
	voice.add_to_group("monster_sfx")
	get_tree().root.add_child(voice)
	voice.global_position=at
	voice.finished.connect(voice.queue_free)
	voice.play()
	sound_cooldown=.09

func _synthesize(spec: Dictionary,cue: String) -> AudioStreamWAV:
	var rate:=16000
	var count:=int(float(spec.duration)*rate)
	var data:=PackedByteArray();data.resize(count*2)
	var phase:=0.0
	for i in range(count):
		var p:=float(i)/count
		var frequency:=float(spec.pitch)+float(spec.fall)*(p if cue=="cast" else 1-p)
		phase+=TAU*frequency/rate
		var noise:=sin(float(i*i+17)*12.9898)*float(spec.noise)
		var pulse:=.65+.35*sin(TAU*float(spec.pulse)*float(i)/rate)
		var value:=(sin(phase)+noise)*pulse*minf(1,p*25)*pow(1-p,2)*.3
		data.encode_s16(i*2,int(clampf(value,-1,1)*32767))
	var stream:=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=rate;stream.data=data
	return stream


func _sweep_hits(start: Vector2,end: Vector2,size: Vector2) -> bool:
	if not is_instance_valid(actor.target):return false
	var rect:=Rect2(actor.target.global_position+Vector2(-15,-90),Vector2(30,90)).grow_individual(size.x*.5,size.y*.5,size.x*.5,size.y*.5)
	if rect.has_point(start) or rect.has_point(end):return true
	var points: Array[Vector2]=[rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for i in range(4):
		if Geometry2D.segment_intersects_segment(start,end,points[i],points[(i+1)%4])!=null:return true
	return false
