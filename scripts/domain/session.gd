extends RefCounted

const Auction = preload("res://scripts/domain/auction.gd")
const Value = preload("res://scripts/domain/valuation.gd")
const Catalog = preload("res://scripts/services/content_registry.gd")
var catalog := Catalog.new()
var config: Dictionary = catalog.data.economy

func initial() -> Dictionary:
	var inventory: Array = []
	for index in range(3):
		inventory.append(catalog.instance(catalog.data.starters[index], "starter-%d" % index, true))
	return {"revision": 0, "coins": int(config.start_coins), "capacity": int(config.stock_slots), "rack_count": 0, "inventory": inventory, "screen": "shop", "sequence": 0, "lot": {}, "visits": [], "visitor": 0, "shop_sessions": 0, "discoveries": [], "receipts": [], "commands": [], "notice": "Welcome! Price the three practice objects, or visit the auction yard."}

func apply(state: Dictionary, command: Dictionary) -> Dictionary:
	for result in state.commands:
		if result.id == command.id:
			return {"ok": true, "duplicate": true, "state": state}
	if command.revision != state.revision:
		return failure("This action is stale. Please try from the current screen.")
	var next: Dictionary = state.duplicate(true)
	var message: String = reduce(next, str(command.kind), command.get("args", {}))
	if message != "":
		return failure(message)
	next.revision += 1
	next.commands.append({"id": command.id, "revision": next.revision})
	if next.commands.size() > 128:
		next.commands.pop_front()
	if next.receipts.size() > 1000:
		next.receipts.pop_front()
	if not valid(next):
		return failure("State validation failed; nothing changed.")
	return {"ok": true, "duplicate": false, "state": next}

func failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}

func reduce(s: Dictionary, kind: String, args: Dictionary) -> String:
	match kind:
		"visit_lot":
			if s.screen != "shop":
				return "Finish the current visit first."
			if int(s.coins) < 80:
				return "Auction entry needs 80 coins. Sorting pays 40; 160 is a cautious working balance."
			if int(s.capacity) - s.inventory.size() < 6:
				return "Reserve six free stock slots. Sell to visitors or the dealer first."
			s.sequence += 1
			var items: Array = []
			for index in range(6):
				items.append(catalog.instance(catalog.data.items[index], "lot-%d-%d" % [s.sequence, index]))
			s.lot = {"id": "fixture-%d" % s.sequence, "items": items, "inspections": [], "auction": Auction.create(catalog.public_slots(), catalog.data.rivals, s.sequence, mini(int(config.lot_cap), int(s.coins) - int(config.reserve)))}
			s.screen = "inspect"
			s.notice = "Household clearance · six objects · opening 40. This prototype repeats one authored lot."
		"inspect":
			if s.screen != "inspect":
				return "Inspection is available before bidding."
			var target: int = int(args.get("target", -1))
			if target < 0 or target > 3:
				return "Unknown inspection target."
			if target not in s.lot.inspections:
				if s.lot.inspections.size() >= 2:
					return "Both close inspections are used. Your clues remain in the notebook."
				s.lot.inspections.append(target)
			s.notice = catalog.data.items[target].clue
		"ceiling":
			if s.screen not in ["inspect", "auction"]:
				return "No active auction."
			var auction: Dictionary = s.lot.auction
			var ceiling: int = int(args.get("amount", 0))
			var minimum: int = int(auction.bid) if auction.leader == "player" else 40
			if ceiling < minimum or ceiling > int(auction.limits.player):
				return "Ceilings can only tighten and cannot retract a binding bid."
			auction.limits.player = ceiling
			s.notice = "Your ceiling is %d. It cannot increase for this lot." % ceiling
		"bid", "pass":
			if s.screen not in ["inspect", "auction"]:
				return "No active auction."
			var auction: Dictionary = s.lot.auction
			var amount: int = 0 if kind == "pass" else int(args.get("amount", -1))
			if not Auction.act(auction, "player", amount):
				return "Illegal bid or withdrawal. Respect your ceiling and the current turn."
			Auction.npc_round(auction)
			s.screen = "auction"
			s.notice = "Decisions are paused. Raise or pass; there is no timer."
			if auction.status == "resolved":
				resolve(s)
		"appraise":
			if s.screen not in ["shop", "reveal"]:
				return "Return to the shop or reveal first."
			for item in s.inventory:
				item.verified = true
				if not str(item.definition_id).begins_with("practice.") and item.definition_id not in s.discoveries:
					s.discoveries.append(item.definition_id)
			s.notice = "All owned objects identified. Practice objects do not count as discoveries."
		"return_shop":
			if s.screen not in ["reveal", "result", "receipt"]:
				return "Finish the active decision first."
			s.screen = "shop"
			s.lot = {}
			s.notice = "Stock a shelf, visit the yard, or take a sorting commission."
		"stock":
			if s.screen != "shop":
				return "Stock shelves between customer waves."
			var item: Dictionary = owned(s, str(args.get("uid", "")))
			if item.is_empty() or not item.verified:
				return "Identify this object before listing it."
			if not item.shelf and shelves(s) >= int(config.shelf_slots):
				return "All six sale shelf slots are occupied."
			item.shelf = not item.shelf
			if int(item.ask) == 0:
				item.ask = maxi(5, Value.rounded(Value.reference_value(item), 5) * 5)
			s.notice = "Shelf updated. Stock still occupies one inventory slot."
		"price":
			if s.screen != "shop":
				return "Edit prices before starting a customer wave."
			var item: Dictionary = owned(s, str(args.get("uid", "")))
			var amount: int = int(args.get("amount", -1))
			if item.is_empty() or not item.verified or amount < 1 or amount > 100000:
				return "Choose an identified object and a positive asking price."
			item.ask = amount
			s.notice = "Asking price saved. Customers decide only when you offer an object."
		"dealer":
			if s.screen != "shop":
				return "Dealer sales are available between customer waves."
			var item: Dictionary = owned(s, str(args.get("uid", "")))
			if item.is_empty() or not item.verified:
				return "Identify this object first."
			sell(s, item, Value.rounded(Value.reference_value(item) * int(config.dealer_bp)), false, "Dealer")
		"commission":
			if s.screen != "shop":
				return "Return to the shop first."
			s.coins += int(config.commission)
			s.notice = "Sorting commission completed using the accessible skip option: +40. No discoveries awarded."
		"rack":
			if s.screen != "shop" or int(s.rack_count) >= 2:
				return "No further rack upgrade available."
			var cost: int = 120 if int(s.rack_count) == 0 else 180
			if int(s.coins) < cost:
				return "Not enough coins for this rack."
			s.coins -= cost
			s.rack_count += 1
			s.capacity += 6
			s.notice = "Six stock slots added. Sale shelves remain six."
		"customers":
			if s.screen != "shop":
				return "The current customer queue must finish first."
			var rng := RandomNumberGenerator.new()
			rng.seed = ("lantern-prototype:customers:%d" % s.shop_sessions).hash()
			s.visits = []
			for customer in catalog.data.customers:
				s.visits.append({"id": customer.id, "budget": [60, 100, 160, 300][rng.randi_range(0, 3)], "offer": {}, "considered": false})
			s.visitor = 0
			s.screen = "customers"
			s.notice = "Six visitors, one paused encounter at a time. Choose one shelf object or skip."
		"offer":
			if s.screen != "customers":
				return "No active visitor."
			var visit: Dictionary = s.visits[int(s.visitor)]
			if visit.considered:
				return "One object and one counteroffer per encounter. Accept, decline, or skip."
			var item: Dictionary = owned(s, str(args.get("uid", "")))
			if item.is_empty() or not item.verified or not item.shelf:
				return "Choose an identified object on a sale shelf."
			var customer: Dictionary = catalog.data.customers[int(s.visitor)]
			var category: String = catalog.definition(item.definition_id).category
			var taste: int = 8500 if visit.id == "bargain" else (11500 if category in customer.preferences else 10000)
			var reserve: int = mini(int(visit.budget), Value.rounded(Value.reference_value(item) * taste))
			var gross: int = mini(int(item.ask), reserve)
			if int(item.ask) > reserve and reserve >= 5:
				gross = int(reserve / 5) * 5
			visit.offer = {"uid": item.uid, "gross": gross, "fee": Value.fee(gross, int(config.fee_bp))}
			visit.considered = true
			s.notice = "Accepted your ask." if int(item.ask) <= reserve else "One counteroffer. You may decline freely."
		"accept":
			if s.screen != "customers":
				return "No active visitor."
			var visit: Dictionary = s.visits[int(s.visitor)]
			if visit.offer.is_empty():
				return "Select a shelf object first."
			var item: Dictionary = owned(s, str(visit.offer.uid))
			if item.is_empty():
				return "This object has already left your stock."
			sell(s, item, int(visit.offer.gross), true, catalog.data.customers[int(s.visitor)].name)
			advance_visitor(s)
		"skip":
			if s.screen != "customers":
				return "No active visitor."
			advance_visitor(s)
		_:
			return "Unknown command."
	return ""

func resolve(s: Dictionary) -> void:
	var auction: Dictionary = s.lot.auction
	if auction.leader == "player":
		s.coins -= int(auction.bid)
		Value.allocate(s.lot.items, int(auction.bid))
		s.inventory.append_array(s.lot.items.duplicate(true))
		s.screen = "reveal"
		s.notice = "Won for %d. All six objects transferred in one free batch. Appraise to identify them." % auction.bid
	else:
		s.screen = "result"
		s.notice = "No charge. %s" % ("Lot unsold." if auction.leader == "" else "%s won at %d." % [str(auction.leader).capitalize(), auction.bid])
	s.receipts.append({"kind": "auction", "lot_id": s.lot.id, "winner": auction.leader, "bid": auction.bid})

func advance_visitor(s: Dictionary) -> void:
	s.visitor += 1
	if int(s.visitor) == 6:
		s.shop_sessions += 1
		s.screen = "receipt"
		s.notice = "Customer wave complete. All sales were confirmed; nothing runs while away."

func sell(s: Dictionary, item: Dictionary, gross: int, retail: bool, buyer: String) -> void:
	var fee: int = Value.fee(gross, int(config.fee_bp)) if retail else 0
	s.coins += gross - fee
	s.receipts.append({"kind": "sale", "uid": item.uid, "buyer": buyer, "gross": gross, "fee": fee, "net": gross - fee, "cost": item.cost})
	s.inventory.erase(item)
	s.notice = "%s paid %d; fee %d; you received %d." % [buyer, gross, fee, gross - fee]

func owned(s: Dictionary, uid: String) -> Dictionary:
	for item in s.inventory:
		if item.uid == uid:
			return item
	return {}

func shelves(s: Dictionary) -> int:
	var count: int = 0
	for item in s.inventory:
		if item.shelf:
			count += 1
	return count

func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

func valid(s: Dictionary) -> bool:
	# Prototype schema is intentionally closed: no script/resource deserialization.
	var keys: Array = ["revision", "coins", "capacity", "rack_count", "inventory", "screen", "sequence", "lot", "visits", "visitor", "shop_sessions", "discoveries", "receipts", "commands", "notice"]
	if s.size() != keys.size():
		return false
	for key in keys:
		if not s.has(key):
			return false
	if not integer(s.revision, 0, 1000000000) or not integer(s.coins, 0, 1000000000) or not integer(s.sequence, 0, 1000000000):
		return false
	if not integer(s.rack_count, 0, 2) or s.capacity != 18 + int(s.rack_count) * 6:
		return false
	if not integer(s.shop_sessions, 0, 1000000000) or not integer(s.visitor, 0, 6):
		return false
	if s.screen not in ["shop", "inspect", "auction", "reveal", "result", "customers", "receipt"]:
		return false
	if not s.inventory is Array or s.inventory.size() > int(s.capacity) or not s.lot is Dictionary:
		return false
	if not s.commands is Array or s.commands.size() > 128 or not s.receipts is Array or s.receipts.size() > 1000:
		return false
	if not s.discoveries is Array or s.discoveries.size() > 6 or not s.visits is Array or s.visits.size() > 6 or not s.notice is String:
		return false
	var ids: Array = []
	for item in s.inventory:
		if not item_valid(item) or item.uid in ids:
			return false
		ids.append(item.uid)
	if shelves(s) > 6:
		return false
	var discovered_ids: Array = []
	for id in s.discoveries:
		if not id is String or catalog.definition(id).is_empty() or id.begins_with("practice."):
			return false
		if id in discovered_ids:
			return false
		discovered_ids.append(id)
	var command_ids: Array = []
	for command in s.commands:
		if not command is Dictionary or not command.get("id") is String or not integer(command.get("revision"), 1, int(s.revision)):
			return false
		if command.id in command_ids:
			return false
		command_ids.append(command.id)
	for receipt in s.receipts:
		if not receipt is Dictionary or receipt.get("kind") not in ["sale", "auction"]:
			return false
		if receipt.kind == "sale":
			if receipt.size() != 7 or not receipt.get("uid") is String or not receipt.get("buyer") is String or not integer(receipt.get("gross"), 0, 100000) or not integer(receipt.get("fee"), 0, 8000) or not integer(receipt.get("cost"), 0, 250):
				return false
			if receipt.get("net") != int(receipt.gross) - int(receipt.fee) or int(receipt.fee) > int(receipt.gross):
				return false
		elif receipt.size() != 4 or not receipt.get("lot_id") is String or receipt.get("winner") not in ["", "player", "mei", "arif", "suri"] or not integer(receipt.get("bid"), 0, 250):
			return false
	if not s.lot.is_empty() and not lot_valid(s.lot, s):
		return false
	if s.screen in ["inspect", "auction", "reveal", "result"] and s.lot.is_empty():
		return false
	if s.screen == "customers" and (s.visits.size() != 6 or int(s.visitor) >= 6):
		return false
	for index in range(s.visits.size()):
		var visit: Variant = s.visits[index]
		if not visit is Dictionary or visit.size() != 4 or visit.get("id") != catalog.data.customers[index].id or not integer(visit.get("budget"), 60, 300):
			return false
		if int(visit.budget) not in [60, 100, 160, 300]:
			return false
		if not visit.get("offer") is Dictionary or not visit.get("considered") is bool:
			return false
		if not visit.offer.is_empty():
			if visit.offer.size() != 3 or not visit.offer.get("uid") is String or not integer(visit.offer.get("gross"), 0, 300) or visit.offer.get("fee") != Value.fee(int(visit.offer.gross), int(config.fee_bp)):
				return false
			if s.screen == "customers" and index == int(s.visitor) and owned(s, visit.offer.uid).is_empty():
				return false
	return true

func item_valid(item: Variant) -> bool:
	if not item is Dictionary or item.size() != 8:
		return false
	if not item.get("uid") is String or not item.get("definition_id") is String:
		return false
	var definition: Dictionary = catalog.definition(item.definition_id)
	if definition.is_empty() or item.get("base") != definition.base or item.get("condition") != definition.condition:
		return false
	return item.get("verified") is bool and item.get("shelf") is bool and integer(item.get("ask"), 0, 100000) and integer(item.get("cost"), 0, 250)

func lot_valid(lot: Dictionary, s: Dictionary) -> bool:
	if lot.size() != 4 or not lot.get("id") is String or not lot.get("items") is Array or lot.items.size() != 6 or not lot.get("inspections") is Array or lot.inspections.size() > 2:
		return false
	var ids: Array = []
	for item in lot.items:
		if not item_valid(item) or item.uid in ids:
			return false
		ids.append(item.uid)
	for target in lot.inspections:
		if not integer(target, 0, 3):
			return false
	if not lot.get("auction") is Dictionary:
		return false
	var a: Dictionary = lot.auction
	if a.size() != 8 or not integer(a.get("bid"), 0, 250) or a.get("status") not in ["open", "resolved"] or not a.get("active") is Array or not a.get("limits") is Dictionary or not a.get("steps") is Dictionary or not a.get("log") is Array:
		return false
	if a.active.size() > 4 or a.log.size() > 128 or a.get("leader") not in ["", "player", "mei", "arif", "suri"] or a.get("actor") not in ["", "player", "mei", "arif", "suri"]:
		return false
	for actor in ["player", "mei", "arif", "suri"]:
		if not integer(a.limits.get(actor), 0, 250):
			return false
	if a.limits.size() != 4 or a.steps.size() != 3 or a.steps.get("mei") != 10 or a.steps.get("arif") != 20 or a.steps.get("suri") != 10:
		return false
	var active_ids: Array = []
	for actor in a.active:
		if actor not in ["player", "mei", "arif", "suri"] or actor in active_ids:
			return false
		active_ids.append(actor)
	for entry in a.log:
		if not entry is String:
			return false
	if a.leader != "" and (a.leader not in a.active or int(a.bid) < 40 or int(a.bid) > int(a.limits[a.leader])):
		return false
	if a.leader == "" and int(a.bid) != 0:
		return false
	if a.status == "open":
		if s.screen not in ["inspect", "auction"]:
			return false
		if a.actor != "player" or "player" not in a.active or a.leader == "player":
			return false
		if int(s.coins) - int(a.limits.player) < 40 or int(s.capacity) - s.inventory.size() < 6:
			return false
	else:
		if s.screen not in ["reveal", "result"] or a.actor != "" or a.active.size() > 1:
			return false
		if (s.screen == "reveal") != (a.leader == "player"):
			return false
	return true
