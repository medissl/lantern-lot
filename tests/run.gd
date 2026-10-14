extends SceneTree

const Domain = preload("res://scripts/domain/session.gd")
const Auction = preload("res://scripts/domain/auction.gd")
const Value = preload("res://scripts/domain/valuation.gd")
const Saves = preload("res://scripts/services/save_service.gd")
const Game = preload("res://scripts/services/game_session.gd")
var domain := Domain.new()
var checks: int = 0
var failed: bool = false
var serial: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("FAIL: " + message)

func command(state: Dictionary, kind: String, args: Dictionary = {}) -> Dictionary:
	serial += 1
	var result: Dictionary = domain.apply(state, {"id": "test-%d" % serial, "revision": state.revision, "kind": kind, "args": args})
	check(result.ok, "command %s: %s" % [kind, result.get("message", "")])
	return result.get("state", state)

func run() -> void:
	test_values()
	test_auction_edges()
	test_full_loops()
	test_capacity_and_customers()
	test_saves()
	test_durable_loop()
	print("TEST_RESULT: %d checks; %s" % [checks, "FAILED" if failed else "PASS"])
	quit(1 if failed else 0)

func test_values() -> void:
	var references: Array = []
	var dealer: int = 0
	var net: int = 0
	var items: Array = []
	for index in range(6):
		var item: Dictionary = domain.catalog.instance(domain.catalog.data.items[index], "fixture-%d" % index, true)
		var reference: int = Value.reference_value(item)
		references.append(reference)
		dealer += Value.rounded(reference * 5000)
		net += reference - Value.fee(reference, 800)
		items.append(item)
	check(references == [30, 18, 43, 68, 75, 21], "Exact design fixture references")
	check(dealer == 129 and net == 236, "Per-item fee/dealer half-up rounding")
	for bid in range(40, 251, 10):
		Value.allocate(items, bid)
		var total: int = 0
		for item in items:
			total += int(item.cost)
		check(total == bid, "Cost allocation sums to bid %d" % bid)
	check(domain.valid(domain.initial()), "Initial schema")

func test_auction_edges() -> void:
	var a: Dictionary = Auction.create(domain.catalog.public_slots(), domain.catalog.data.rivals, 1, 250)
	check(Auction.act(a, "player", 40), "Opening accepted")
	check(not Auction.act(a, "player", 0), "Leader cannot withdraw")
	check(not Auction.act(a, "arif", 50), "Out-of-turn bid rejected")
	check(not Auction.act(a, "mei", 45), "Illegal increment rejected")
	var unsold: Dictionary = Auction.create([], domain.catalog.data.rivals, 2, 40)
	check(Auction.act(unsold, "player", 0), "Free opening withdrawal")
	Auction.npc_round(unsold)
	check(unsold.status == "resolved" and unsold.leader == "", "Unsold if nobody accepts opening")
	for seed in range(100):
		var auction: Dictionary = Auction.create(domain.catalog.public_slots(), domain.catalog.data.rivals, seed, 250)
		var same: Dictionary = Auction.create(domain.catalog.public_slots(), domain.catalog.data.rivals, seed, 250)
		check(auction == same, "NPC generation replay %d" % seed)
		var turns: int = 0
		while auction.status == "open" and turns < 100:
			var amount: int = 40 if int(auction.bid) == 0 else int(auction.bid) + 10
			if amount > int(auction.limits.player):
				amount = 0
			check(Auction.act(auction, "player", amount), "Player turn accepted")
			Auction.npc_round(auction)
			turns += 1
		check(auction.status == "resolved", "Bounded settlement %d" % seed)

func test_full_loops() -> void:
	for seed in range(100):
		var s: Dictionary = domain.initial()
		s.sequence = seed
		s = command(s, "visit_lot")
		var limits: Dictionary = s.lot.auction.limits.duplicate()
		s = command(s, "inspect", {"target": 0})
		s = command(s, "inspect", {"target": 3})
		check(s.lot.auction.limits == limits, "Private inspection never changes NPC ceilings")
		var rejected: Dictionary = domain.apply(s, {"id": "third", "revision": s.revision, "kind": "inspect", "args": {"target": 1}})
		check(not rejected.ok, "Only two close inspections")
		# Simulate JSON load at every stable decision.
		var turns: int = 0
		while s.screen in ["inspect", "auction"] and turns < 100:
			s = JSON.parse_string(JSON.stringify(s))
			check(domain.valid(s), "Serialized auction validates")
			var amount: int = 40 if int(s.lot.auction.bid) == 0 else int(s.lot.auction.bid) + 10
			var kind: String = "pass" if seed % 3 == 0 or amount > int(s.lot.auction.limits.player) else "bid"
			s = command(s, kind, {"amount": amount})
			turns += 1
		check(s.screen in ["reveal", "result"], "Complete domain scenario settles %d" % seed)
		if s.screen == "reveal":
			check(s.inventory.size() == 9 and s.coins == 360 - int(s.lot.auction.bid) and s.coins >= 40, "Atomic debit + six objects + reserve")
			s = command(s, "appraise")
			check(s.discoveries.size() == 6, "Verified lot awards six discoveries")
		else:
			check(s.inventory.size() == 3 and s.coins == 360, "Withdrawal has no debit/loot")
		s = command(s, "return_shop")
		s = command(s, "stock", {"uid": "starter-0"})
		s = command(s, "customers")
		s = command(s, "offer", {"uid": "starter-0"})
		var before: int = int(s.coins)
		var net: int = int(s.visits[0].offer.gross) - int(s.visits[0].offer.fee)
		var sale_command: Dictionary = {"id": "sale-%d" % seed, "revision": s.revision, "kind": "accept"}
		var sold: Dictionary = domain.apply(s, sale_command)
		check(sold.ok, "Sale accepted")
		if not sold.ok:
			return
		s = sold.state
		check(s.coins == before + net and domain.owned(s, "starter-0").is_empty(), "Sale credits and removes exactly once")
		var duplicate: Dictionary = domain.apply(s, sale_command)
		check(duplicate.ok and duplicate.duplicate and duplicate.state == s, "Duplicate command is idempotent")
		var stale: Dictionary = domain.apply(s, {"id": "stale", "revision": sale_command.revision, "kind": "accept"})
		check(not stale.ok, "Stale new command rejected")
		for _visitor in range(5):
			s = command(s, "skip")
		check(s.screen == "receipt" and s.shop_sessions == 1, "Exactly six paused visits and one session credit")
		var invalid: Dictionary = s.duplicate(true)
		invalid.coins = -1
		check(not domain.valid(invalid), "Negative wallet rejected")
		invalid = s.duplicate(true)
		invalid.inventory.append(invalid.inventory[0].duplicate(true))
		check(not domain.valid(invalid), "Duplicate inventory ID rejected")

func test_capacity_and_customers() -> void:
	var s: Dictionary = domain.initial()
	s.coins = 40
	var refused: Dictionary = domain.apply(s, {"id": "poor", "revision": 0, "kind": "visit_lot"})
	check(not refused.ok, "Wallet below 80 cannot enter")
	s = command(s, "commission")
	check(s.coins == 80 and s.discoveries.is_empty(), "Recovery adds 40 and no discovery")
	s = command(s, "visit_lot")
	check(s.lot.auction.limits.player == 40, "Reserve ceiling at low wallet")
	var ceiling_error: Dictionary = domain.apply(s, {"id": "raise-cap", "revision": s.revision, "kind": "ceiling", "args": {"amount": 50}})
	check(not ceiling_error.ok, "Ceiling cannot increase")
	s = command(s, "pass")
	s = command(s, "return_shop")
	for _visit in range(3):
		s = command(s, "commission")
	s = command(s, "rack")
	check(s.capacity == 24 and s.rack_count == 1, "Rack changes stock, not shelves")
	var packed: Dictionary = domain.initial()
	for index in range(10):
		packed.inventory.append(domain.catalog.instance(domain.catalog.data.starters[0], "extra-%d" % index, true))
	check(domain.valid(packed), "Fixture packed inventory valid")
	refused = domain.apply(packed, {"id": "full", "revision": 0, "kind": "visit_lot"})
	check(not refused.ok, "Six slots reserved before participation")
	s = domain.initial()
	s = command(s, "stock", {"uid": "starter-0"})
	s = command(s, "price", {"uid": "starter-0", "amount": 999})
	s = command(s, "customers")
	s = command(s, "offer", {"uid": "starter-0"})
	check(s.visits[0].offer.gross == 15 and s.visits[0].offer.fee == 1, "Preference counteroffer floor + shown fee")
	refused = domain.apply(s, {"id": "second-offer", "revision": s.revision, "kind": "offer", "args": {"uid": "starter-0"}})
	check(not refused.ok, "One counteroffer per visitor")

func test_saves() -> void:
	var folder: String = ProjectSettings.globalize_path("res://build/test-saves-%d" % Time.get_ticks_usec())
	var saves := Saves.new(folder)
	var s: Dictionary = domain.initial()
	check(saves.commit(s), "Initial verified save commit")
	check(saves.load_latest() == saves.normalize_numbers(JSON.parse_string(JSON.stringify(s))), "Initial disk replay")
	s = command(s, "visit_lot")
	check(saves.commit(s), "Save materialized listing")
	s = command(s, "bid", {"amount": 40})
	check(saves.commit(s), "Save bid + full NPC round")
	var loaded: Dictionary = saves.load_latest()
	check(loaded == saves.normalize_numbers(JSON.parse_string(JSON.stringify(s))), "Exact mid-auction disk replay")
	var newest: String = folder.path_join("slot_a.json" if int(s.revision) % 2 == 0 else "slot_b.json")
	var file := FileAccess.open(newest, FileAccess.WRITE)
	file.store_string("{truncated")
	file.close()
	loaded = saves.load_latest()
	check(not loaded.is_empty() and loaded.revision == s.revision - 1, "Corrupt newest recovers valid previous slot")
	var bad: Dictionary = s.duplicate(true)
	bad.inventory[0].definition_id = "missing"
	check(not saves.commit(bad), "Missing definition rejected before write")
	var corrupt_folder: String = folder + "-corrupt"
	DirAccess.make_dir_recursive_absolute(corrupt_folder)
	file = FileAccess.open(corrupt_folder.path_join("slot_a.json"), FileAccess.WRITE)
	file.store_string("garbage")
	file.close()
	var corrupt := Saves.new(corrupt_folder)
	check(corrupt.load_latest().is_empty() and corrupt.error != "", "All corrupt blocks silent reset")
	check(FileAccess.get_file_as_string(corrupt_folder.path_join("slot_a.json")) == "garbage", "Corrupt originals retained")
	var future_folder: String = folder + "-future"
	var future := Saves.new(future_folder)
	check(future.commit(domain.initial()), "Compatible save before future-schema fixture")
	var future_path: String = future_folder.path_join("slot_b.json")
	file = FileAccess.open(future_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 2, "content_version": "prototype-2", "generator_version": 1, "save_sequence": "5"}))
	file.close()
	check(future.load_latest().is_empty() and future.error.contains("incompatible"), "Future schema blocks rollback despite older compatible slot")
	var tampered: String = folder + "-hash"
	var hash_save := Saves.new(tampered)
	check(hash_save.commit(domain.initial()), "Hash fixture saved")
	var envelope: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tampered.path_join("slot_a.json")))
	envelope.payload_sha256 = "wrong"
	file = FileAccess.open(tampered.path_join("slot_a.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(envelope))
	file.close()
	check(hash_save.load_latest().is_empty() and hash_save.error != "", "Checksum mismatch rejected")
	var bad_io := Saves.new(folder.path_join("slot_b.json/child"))
	check(not bad_io.commit(s), "IO failure reports pending state")

func test_durable_loop() -> void:
	var folder: String = ProjectSettings.globalize_path("res://build/durable-loop-%d" % Time.get_ticks_usec())
	var game := Game.new()
	game.saves = Saves.new(folder)
	game.boot()
	check(game.error == "" and not game.state.is_empty(), "Game service boot")
	check(game.command("visit_lot"), "Durable listing")
	check(game.command("inspect", {"target": 0}), "Durable inspection")
	var fresh := Game.new()
	fresh.saves = Saves.new(folder)
	fresh.boot()
	check(fresh.command("inspect", {"target": 0}), "Revisit saved clue costs no extra action")
	check(fresh.state.lot.inspections.size() == 1, "Normalized saved inspection membership")
	for _turn in range(50):
		if fresh.state.screen not in ["inspect", "auction"]:
			break
		var amount: int = 40 if int(fresh.state.lot.auction.bid) == 0 else int(fresh.state.lot.auction.bid) + 10
		if not fresh.command("bid", {"amount": amount}):
			check(false, "Durable bid failed: " + fresh.error)
			return
	check(fresh.state.screen == "reveal", "Durable win")
	check(fresh.command("appraise"), "Durable appraisal")
	check(fresh.command("return_shop"), "Durable shop return")
	check(fresh.command("stock", {"uid": "starter-0"}), "Durable shelf")
	check(fresh.command("customers"), "Durable six-visitor queue")
	check(fresh.command("offer", {"uid": "starter-0"}), "Durable offer")
	var resumed := Game.new()
	resumed.saves = Saves.new(folder)
	resumed.boot()
	check(resumed.state.screen == "customers" and resumed.state.visits[0].offer.uid == "starter-0", "Mid-offer disk resume")
	check(resumed.command("accept"), "Durable sale after reload")
	for _visitor in range(5):
		check(resumed.command("skip"), "Durable skip")
	check(resumed.state.screen == "receipt" and resumed.state.shop_sessions == 1, "Durable queue receipt")
	check(resumed.command("return_shop"), "Durable receipt return")
