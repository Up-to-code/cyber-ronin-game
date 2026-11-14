extends RefCounted
# Level-owned gate state machine. The scene decides *when* to ask; this module
# decides whether the gate may open and owns the transition until it completes.
signal opened

var gate_open := false
var gate_opening := false

func reset() -> void:
	gate_open = false
	gate_opening = false

# True only when objectives are met and no open is already running.
func begin_open(objectives_met: bool) -> bool:
	if not objectives_met or gate_open or gate_opening:
		return false
	gate_opening = true
	return true

func complete() -> void:
	gate_opening = false
	gate_open = true
	opened.emit()
