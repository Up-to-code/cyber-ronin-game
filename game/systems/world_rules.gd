class_name WorldRules
extends RefCounted
# Pixel coordinates: +Y is down. A metre is 180 world pixels; time is seconds.
# Gameplay impulses are explicit additions to velocity, never a reversal of gravity.
const PIXELS_PER_METER: float = 180.0
const GRAVITY: float = 9.81 * PIXELS_PER_METER
const MAX_FALL_SPEED: float = 1100.0
const JUMP_HEIGHT: float = 110.0
const GROUND_ACCELERATION: float = 2400.0
const AIR_ACCELERATION: float = 1650.0
const GROUND_FRICTION: float = 3200.0
const BODY_MASS_KG: float = 70.0
static var _parameters: Dictionary = {}
static func parameters() -> Dictionary:
	if _parameters.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/physics.json"))
		if parsed is Dictionary: _parameters = parsed
	return _parameters
static func gravity() -> float:
	return maxf(1, float(parameters().get("gravity", GRAVITY)))
static func jump_velocity(height: float = -1) -> float:
	if height < 0: height = float(parameters().get("jump_height", JUMP_HEIGHT))
	return -sqrt(2.0 * gravity() * maxf(0, height))
static func fall(velocity_y: float, delta: float) -> float:
	return minf(velocity_y + gravity() * delta, float(parameters().get("max_fall_speed", MAX_FALL_SPEED)))
static func impulse_velocity(impulse_ns: Vector2, mass_kg: float = BODY_MASS_KG) -> Vector2:
	return impulse_ns / maxf(1, mass_kg) * float(parameters().get("pixels_per_meter", PIXELS_PER_METER))
static func hit_impulse(kind: String, direction: float) -> Vector2:
	var record: Dictionary=combat_parameters().get("hit_profiles",{}).get(kind,{})
	if record.has("impulse_ns"):
		var components: Array=record.impulse_ns
		return Vector2(float(components[0])*signf(direction),float(components[1]))
	match kind:
		"double": return Vector2(direction * 105, -28)
		"enemy": return Vector2(direction * 70, -30)
		"kick": return Vector2(direction * 120, -150)
		"power", "charged", "plunge", "finisher": return Vector2(direction * 180, -65)
		"ranged": return Vector2(direction * 85, -30)
		_: return Vector2(direction * 60, -20)
static func combat_parameters() -> Dictionary:
	return parameters().get("combat", {})
static func recoil_drag(grounded: bool) -> float:
	return maxf(1, float(combat_parameters().get("ground_drag" if grounded else "air_drag",1250 if grounded else 500)))
static func combo_recovery_time(active_end_seconds: float) -> float:
	return active_end_seconds + maxf(0,float(combat_parameters().get("combo_follow_through",0.05)))
static func combat_response(damage: float, kind: String, direction: float, mass_kg: float = BODY_MASS_KG, resistance: float = 1.0) -> Dictionary:
	# Impulse J = change in momentum. Mass converts it to velocity; resistance
	# is a separate authored bracing/poise factor, not current health or gravity.
	var reference: float = float({"kick":20,"double":42,"finisher":55,"charged":60,"power":90,"plunge":55,"ranged":40,"enemy":15}.get(kind,35))
	reference=maxf(1,float(combat_parameters().get("hit_profiles",{}).get(kind,{}).get("reference_damage",reference)))
	var strength: float = pow(maxf(0,damage)/reference,float(combat_parameters().get("damage_exponent",0.85)))
	var brace: float = maxf(0.25,resistance)
	var momentum: Vector2 = hit_impulse(kind,signf(direction))*strength/brace
	var change: Vector2 = impulse_velocity(momentum,mass_kg)
	var max_x: float = float(combat_parameters().get("max_horizontal_speed",460))
	var max_y: float = float(combat_parameters().get("max_launch_speed",420))
	change.x=clampf(change.x,-max_x,max_x)
	change.y=clampf(change.y,-max_y,0)
	if damage<=0: change=Vector2.ZERO
	# Return the capped impulse too, so angular reaction agrees with translation.
	momentum=change*maxf(1,mass_kg)/float(parameters().get("pixels_per_meter",PIXELS_PER_METER))
	return {"velocity":change,"impulse":momentum,"stun":clampf((0.18+0.1*strength)/sqrt(brace),0.12,0.42) if damage>0 else 0.0,"ground_stop_distance":change.x*change.x/(2*recoil_drag(true))}

static func angular_impulse(contact_from_center: Vector2, impulse_ns: Vector2, mass_kg: float, height_px: float = 116) -> float:
	var scale: float = float(parameters().get("pixels_per_meter", PIXELS_PER_METER))
	var height_m: float = height_px / scale
	# Upright rod approximation about the body center: I = m L² / 12.
	var inertia: float = maxf(0.01, mass_kg * height_m * height_m / 12.0)
	return (contact_from_center / scale).cross(impulse_ns) / inertia
static func spring(current: float, target: float, damping: float, delta: float) -> float:
	return lerpf(current, target, 1.0 - exp(-damping * delta))

# Impact speed is derived from gravity; normal/double jumps stay below safe speed.
static func landing_damage(speed: float) -> int:
	return clampi(int(ceil((speed - 850.0) / 25.0)), 0, 10)
