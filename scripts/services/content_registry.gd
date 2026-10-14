extends RefCounted

var data: Dictionary

func _init() -> void:
	data = JSON.parse_string(FileAccess.get_file_as_string("res://content/prototype.json"))
	assert(data.items.size() == 6 and data.starters.size() == 3)
	assert(data.economy.opening == 40 and data.rivals.size() == 3)

func definition(id: String) -> Dictionary:
	for item in data.items + data.starters:
		if item.id == id:
			return item
	return {}

func instance(definition_data: Dictionary, uid: String, verified: bool = false) -> Dictionary:
	return {"uid": uid, "definition_id": definition_data.id, "base": int(definition_data.base), "condition": int(definition_data.condition), "verified": verified, "shelf": false, "ask": 0, "cost": 0}

func public_slots() -> Array:
	# Fixed fixture exposes silhouettes/categories only. Player close clues are private.
	return [{"category": "homewares"}, {"category": "homewares"}, {"category": "tools"}, {}, {}, {}]
