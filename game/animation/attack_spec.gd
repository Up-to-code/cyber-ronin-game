class_name CelAttackSpec
extends RefCounted
## One source for the displayed action, active contact phase, and gameplay query.
## A profile's contact_frame must be chosen from inspected authored artwork.
static func resolve(profile: Dictionary, kind: String, combo: int = 1) -> Dictionary:
	var key: String = "sword%d" % clampi(combo, 1, 3) if kind == "sword" else kind
	var specs: Dictionary = profile.get("attacks", {})
	if not specs.has(key): return {}
	var result: Dictionary = specs[key].duplicate(true)
	var clips: Dictionary = profile.get("clips", {})
	var clip: Dictionary = clips.get(result.get("clip", key), {})
	var frames: Array = clip.get("frames", [])
	var total: float = 0
	var contact: float = 0
	var active_end: float = 0
	var contact_frame: int = clampi(int(result.get("contact_frame", 0)), 0, maxi(0, frames.size() - 1))
	var end_frame: int = clampi(int(result.get("active_end_frame", contact_frame)), contact_frame, maxi(contact_frame, frames.size() - 1))
	for i in range(frames.size()):
		var duration: float = maxf(1, float(frames[i].get("duration_ms", 100)))
		if i < contact_frame: contact += duration
		if i <= end_frame: active_end += duration
		total += duration
	result["id"] = key
	result["contact_progress"] = contact / maxf(1, total)
	result["active_end_progress"] = active_end / maxf(1, total)
	result["duration"] = float(result.get("duration", total / 1000.0))
	return result
