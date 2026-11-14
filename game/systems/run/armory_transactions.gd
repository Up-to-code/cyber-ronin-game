extends RefCounted
## Owns purchase commit policy; callers receive an outcome and render it.
const Inventory = preload("res://systems/skill_inventory.gd")
var _inventory: RefCounted
var _store: RefCounted

func _init(inventory: RefCounted, store: RefCounted) -> void:
	_inventory = inventory
	_store = store

func purchase(id: String, wallet: int, save_path: String) -> Dictionary:
	var candidate := Inventory.new()
	candidate.load_state(_inventory.export_state())
	var result: Dictionary = candidate.purchase(id, wallet)
	if not result.ok: return result
	var error: Error = _store.commit_progress(int(result.wallet), candidate.export_state(), save_path)
	if error != OK:
		return {"ok":false,"wallet":wallet,"message":"Could not save. Purchase was cancelled."}
	_inventory.load_state(candidate.export_state())
	return result

# Consumption has already affected gameplay and cannot be refunded on write
# failure. Keep it in session state so a later settings/checkpoint save retries it.
func save_progress(banked_coins: int, save_path: String) -> Error:
	_store.set_coins(banked_coins)
	_store.set_skill_state(_inventory.export_state())
	return _store.save(save_path)
