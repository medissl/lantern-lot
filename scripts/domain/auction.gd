extends RefCounted

# This module receives public observations only. No hidden item instances.
static func create(public_slots: Array, rivals: Array, sequence: int, limit: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("lantern-prototype:npc:%d" % sequence).hash()
	var limits: Dictionary = {"player": limit}
	var steps: Dictionary = {}
	for rival in rivals:
		var estimate: float = 0.0
		for slot in public_slots:
			var value: float = 58.7 * 0.8225
			if slot.has("base"):
				value = float(slot.base) * float(slot.get("condition", 8225)) / 10000.0
			if rival.id == "suri" and slot.get("category", "") == "homewares":
				value *= 1.15
			estimate += value
		var budget: int = [80, 120, 160, 200][rng.randi_range(0, 3)]
		var offset: float = [0.85, 1.0, 1.15][rng.randi_range(0, 2)]
		limits[rival.id] = mini(budget, int(floor(estimate * offset * 0.92 * (10000 - int(rival.margin_bp)) / 10000.0)))
		steps[rival.id] = int(rival.step)
	return {"bid": 0, "leader": "", "active": ["player", "mei", "arif", "suri"], "actor": "player", "limits": limits, "steps": steps, "status": "open", "log": []}

static func act(auction: Dictionary, actor: String, amount: int) -> bool:
	if auction.status != "open" or auction.actor != actor or auction.leader == actor:
		return false
	if amount == 0:
		auction.active.erase(actor)
		auction.log.append("%s passed out." % actor.capitalize())
	else:
		if amount > int(auction.limits[actor]):
			return false
		if int(auction.bid) == 0:
			if amount != 40:
				return false
		elif amount - int(auction.bid) not in [10, 20, 40]:
			return false
		auction.bid = amount
		auction.leader = actor
		auction.log.append("%s bid %d." % [actor.capitalize(), amount])
	if auction.active.is_empty() or (auction.active.size() == 1 and auction.leader != ""):
		auction.status = "resolved"
		auction.actor = ""
		return true
	var seats: Array = ["player", "mei", "arif", "suri"]
	var cursor: int = seats.find(actor)
	for offset in range(1, 5):
		var candidate: String = seats[(cursor + offset) % 4]
		if candidate in auction.active and candidate != auction.leader:
			auction.actor = candidate
			return true
	return false

static func npc_round(auction: Dictionary) -> void:
	# Logical turns run only after a command, never on a frame or timer.
	for _turn in range(128):
		if auction.status != "open" or auction.actor == "player":
			return
		var actor: String = auction.actor
		var amount: int = 40 if int(auction.bid) == 0 else int(auction.bid) + int(auction.steps[actor])
		if amount > int(auction.limits[actor]) and int(auction.bid) > 0:
			amount = int(auction.bid) + 10
		if amount > int(auction.limits[actor]):
			amount = 0
		var accepted: bool = act(auction, actor, amount)
		if not accepted:
			push_error("Invalid NPC turn")
			return
	assert(false, "Auction exceeded bounded turn count")
