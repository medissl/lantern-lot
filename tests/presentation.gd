extends SceneTree

const Layout = preload("res://scripts/presentation/layout_controller.gd")
const VisualSave = preload("res://scripts/services/presentation_save.gd")
const Domain = preload("res://scripts/domain/session.gd")
const EconomicSave = preload("res://scripts/services/save_service.gd")
const InputRouter = preload("res://scripts/presentation/world_input_router.gd")
const Room = preload("res://scripts/presentation/room_view.gd")
var checks := 0
var failed := false

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("FAIL: " + message)

func run() -> void:
	test_input()
	var editor := Layout.new()
	var initial := Layout.defaults()
	check(Layout.validate(initial).ok, "Safe default layout has reachable services")
	editor.begin(initial)
	check(not editor.place("stool", 2, 3).ok, "Solid aisle placement rejected")
	check(editor.draft == initial, "Rejected placement leaves draft intact")
	check(not editor.place("lamp", 0, 1).ok, "Shelf collision rejected")
	check(not editor.place("stool", 4, 0).ok, "Bench collision rejected")
	check(not editor.place("lamp", 6, 2).ok, "Outside bounds rejected")
	check(not editor.place("wall_clock", 1, 1).ok, "Wall decoration needs wall socket")
	check(not editor.place("wall_clock", 4, 0).ok, "Wall socket overlap rejected")
	check(not editor.place("lamp", 1, 2).ok, "Shelf service access protected")
	check(editor.place("rug", 2, 7).ok, "Nonsolid rug does not block entry")
	check(editor.undo() and editor.draft == initial, "Undo restores prior draft")
	for index in range(24):
		check(editor.place("rug", 2, 3 if index % 2 == 0 else 4).ok, "Valid rug edit")
	check(editor.history.size() == 20, "Undo bounded to twenty edits")
	check(editor.cancel() == initial and editor.history.is_empty(), "Cancel restores edit start")
	check(not editor.place("shelf0", 2, 2).ok, "Shelf cannot enter central lane")
	check(not editor.place("shelf0", 5, 1).ok, "Two shelves cannot share footprint")
	check(not editor.place("shelf0", 4, 0).ok, "Shelf cannot overlap fixed bench")
	check(editor.place("shelf0", 0, 2).ok, "Shelf can move to valid alternate service position")
	check(Layout.fixture_positions(editor.draft)[0] == Vector2(32,104), "Moved shelf provides new truthful item socket")
	check(not Layout.navigation_blockers(editor.draft).has(Vector2i(0,2)) and Layout.navigation_blockers(editor.draft).has(Vector2i(0,4)), "Shelf move updates navigation occupancy")
	check(editor.undo() and editor.draft == initial, "Shelf move uses shared undo history")
	var malformed := initial.duplicate(true)
	malformed.placements.lamp.col = 1.5
	check(not Layout.validate(malformed).ok, "Fractional placement rejected")
	malformed = initial.duplicate(true)
	malformed.placements["phantom"] = {"col": 1, "row": 3}
	check(not Layout.validate(malformed).ok, "Unknown decoration rejected")
	var directory := "res://build/presentation-tests-%d" % Time.get_ticks_usec()
	var visual := VisualSave.new(directory.path_join("visual"))
	var economy := EconomicSave.new(directory.path_join("business"))
	var business := Domain.new().initial()
	check(economy.commit(business), "Isolated business fixture committed")
	check(visual.load_layout() == initial, "Missing visual file loads default")
	check(visual.save_layout(initial), "Layout atomically committed")
	check(visual.load_layout() == initial, "Layout round trip")
	check(editor.place("rug", 2, 6).ok, "Second layout edit valid")
	check(visual.save_layout(editor.draft), "Existing layout atomically replaced")
	check(VisualSave.new(visual.directory).load_layout() == editor.draft, "Relaunch restores latest layout")
	var legacy_layout := editor.draft.duplicate(true)
	legacy_layout.erase("fixtures")
	var legacy_layout_payload := JSON.stringify(legacy_layout)
	var legacy_layout_file := FileAccess.open(visual.directory.path_join("layout.json"), FileAccess.WRITE)
	legacy_layout_file.store_string(JSON.stringify({"version":1,"kind":"layout","payload":legacy_layout_payload,"sha256":legacy_layout_payload.sha256_text()}))
	legacy_layout_file.close()
	check(visual.load_layout() == editor.draft, "Version1 decoration file migrates six default fixture positions")
	editor.place("shelf0",0,2)
	check(visual.save_layout(editor.draft) and VisualSave.new(visual.directory).load_layout() == editor.draft, "Relocated shelves persist independently of economy")
	var settings := VisualSave.default_settings()
	settings.text_scale = 2.0
	settings.reduced_motion = true
	check(visual.save_settings(settings), "Accessibility settings saved independently")
	check(visual.load_settings() == settings, "Settings round trip")
	var sockets := {"starter-0": 5, "starter-1": 1}
	check(visual.save_sockets(sockets) and visual.load_sockets() == sockets, "Stable uid sockets persist through relaunch")
	check(not visual.save_sockets({"starter-0": 1, "starter-1": 1}), "Two goods cannot occupy same persisted socket")
	check(not visual.save_sockets({"starter-0": 6}), "Out-of-bounds socket rejected")
	var old_settings := settings.duplicate(true)
	old_settings.erase("sfx_volume")
	old_settings.erase("ambience_volume")
	var legacy_payload := JSON.stringify(old_settings)
	var legacy := FileAccess.open(visual.directory.path_join("settings.json"), FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"version": 1, "kind": "settings", "payload": legacy_payload, "sha256": legacy_payload.sha256_text()}))
	legacy.close()
	check(visual.load_settings() == settings, "Old four-key settings migrate without resetting preferences")
	var invalid_settings := settings.duplicate(true)
	invalid_settings.sfx_volume = -0.2
	check(not visual.save_settings(invalid_settings), "Out-of-range audio volume rejected")
	var file := FileAccess.open(visual.directory.path_join("layout.json"), FileAccess.WRITE)
	file.store_string("{broken visual data")
	file.close()
	check(visual.load_layout() == initial and not visual.recovery_message.is_empty(), "Corrupt visual file explains safe fallback")
	check(visual.load_settings() == settings, "Layout corruption cannot reset settings")
	check(visual.load_sockets() == sockets, "Layout corruption cannot reset shelf mapping")
	check(economy.load_latest() == business, "Visual writes/corruption cannot affect economic stock or coins")
	check(not visual.save_layout(malformed), "Invalid draft cannot overwrite saved presentation")
	var sentinel := FileAccess.open(directory.path_join("blocked"), FileAccess.WRITE)
	sentinel.store_string("file prevents directory creation")
	sentinel.close()
	var blocked := VisualSave.new(directory.path_join("blocked/child"))
	var retained := editor.draft.duplicate(true)
	check(not blocked.save_layout(retained) and not blocked.error.is_empty(), "Visual save failure surfaced for Retry or Cancel")
	check(editor.draft == retained, "Failed visual save retains draft")
	await test_room()
	print("PRESENTATION_TEST_RESULT: %d checks; %s" % [checks, "FAILED" if failed else "PASS"])
	quit(1 if failed else 0)

func test_input() -> void:
	var router := InputRouter.new()
	var display := Rect2(20, 80, 360, 448)
	var transform := Transform2D(0.0, Vector2(2, 2), 0.0, Vector2(-14, -30))
	var world := Vector2(104, 160)
	var viewport_point := transform * world
	var screen := display.position + viewport_point / Vector2(360, 448) * display.size
	check(InputRouter.map_pointer(screen, display, Vector2(360, 448), transform).is_equal_approx(world), "Pointer inverts pan/zoom transform")
	check(InputRouter.map_pointer(Vector2(10, 10), display, Vector2(360, 448), transform) == null, "HUD pointer cannot reach world")
	check(router.begin(1, Vector2(50, 50)), "First touch captured")
	check(not router.begin(2, Vector2(50, 50)), "Second touch cannot steal gesture")
	check(router.update(1, Vector2(70, 50)).pan, "Dragging enters pan")
	check(not router.finish(1, Vector2(50, 50)).tap, "Pan returning over object cannot tap it")
	check(router.begin(1, Vector2(50, 50)) and router.finish(1, Vector2(52, 50)).tap, "Clean release selects once")
	check(router.finish(1, Vector2(52, 50)).is_empty(), "Duplicate pointer release ignored")
	router.begin(1, Vector2(50, 50))
	router.cancel()
	check(router.finish(1, Vector2(50, 50)).is_empty(), "Suspension cancellation cannot tap")

func test_room() -> void:
	var domain := Domain.new()
	var state := domain.initial()
	var room := Room.new()
	root.add_child(room)
	await process_frame
	room.sync(state, domain.catalog.data, Layout.defaults(), true)
	check(room.items.size() == 3, "Shop draws all three real starter instances")
	var uid := str(state.inventory[0].uid)
	var persistent_item: Node = room.items[uid]
	state = domain.apply(state, {"id": "presentation-stock", "revision": state.revision, "kind": "stock", "args": {"uid": uid}}).state
	room.sync(state, domain.catalog.data, Layout.defaults(), true)
	check(room.items[uid] == persistent_item, "Stocking reconciles existing item node")
	check(room.items[uid].position + room.items[uid].visual_offset == Room.SHELF_SOCKETS[int(room.shelf_mapping[uid])], "Stocked instance art moves to actual shelf surface")
	var moved_layout := Layout.defaults()
	moved_layout.fixtures.shelf0 = {"col":0,"row":2}
	room.sync(state,domain.catalog.data,moved_layout,false)
	var active_tween: Tween = room.items[uid].movement
	check(active_tween != null and active_tween.is_running(), "Shelf relocation animates actual bound item")
	room.sync(state,domain.catalog.data,moved_layout,false)
	check(room.items[uid].movement == active_tween, "Unchanged sync does not restart running item tween")
	room.sync(state,domain.catalog.data,moved_layout,true)
	check(room.items[uid].position + room.items[uid].visual_offset == Layout.fixture_positions(moved_layout)[0], "Moved shelf carries same uid to correct visual surface")
	check(room.items[uid].position == room.fixtures.shelf0.position and room.items[uid].get_index() > room.fixtures.shelf0.get_index(), "Goods share shelf floor sort and draw after fixture")
	check(not room.player.sprite.is_playing(), "Reduced motion stops player idle animation")
	room.sync(state,domain.catalog.data,Layout.defaults(),true)
	for service in Layout.SERVICE_CELLS:
		var target := Vector2(16,32) + Vector2(service) * 16
		check(not room.path_to(Vector2(104,272), target).is_empty(), "Validated service stand reachable in runtime navigation")
	state = domain.apply(state, {"id": "presentation-dealer", "revision": state.revision, "kind": "dealer", "args": {"uid": uid}}).state
	room.sync(state, domain.catalog.data, Layout.defaults(), true)
	check(not room.items.has(uid) and not room.shelf_mapping.has(uid), "Sold instance and socket mapping removed")
	state = domain.apply(state, {"id": "presentation-visit", "revision": state.revision, "kind": "visit_lot", "args": {}}).state
	room.sync(state, domain.catalog.data, Layout.defaults(), true)
	check(room.items.size() == 6, "Auction binds six authored lot instances")
	for index in range(3, 6):
		var covered_uid := str(state.lot.items[index].uid)
		check(room.items[covered_uid].public_label == "Covered package", "Covered identity remains redacted")
		check(room.items[covered_uid].sprite.texture.resource_path.ends_with("covered.png"), "Covered sprite hides concealed identity")
	check(room.public_hit_targets().size() == 4, "Inspection has exactly four scene hotspots")
	room.sync(state,domain.catalog.data,Layout.defaults(),false)
	room.public_reactions.append("player bid40")
	room.play_effect("sparkle",Vector2(100,150))
	room.skip_reactions()
	await process_frame
	check(room.public_reactions.is_empty() and room.effects.get_child_count() == 0, "Skip reactions clears public queue and effects")
	room.sync(state,domain.catalog.data,Layout.defaults(),true)
	for actor in room.actors.values(): check(not actor.sprite.is_playing(), "Reduced motion stops bidder sprites")
	var rounds := 0
	while state.screen in ["inspect","auction"] and rounds < 25:
		var amount: int = 40 if int(state.lot.auction.bid) == 0 else int(state.lot.auction.bid) + 10
		state = domain.apply(state,{"id":"scene-bid%d" % rounds,"revision":state.revision,"kind":"bid","args":{"amount":amount}}).state
		rounds += 1
	room.sync(state,domain.catalog.data,Layout.defaults(),true)
	var wrapped_uid := str(state.lot.items[3].uid)
	var before_wrapping := JSON.stringify(state)
	check(room.open_package(wrapped_uid), "Owned won package can open cosmetically")
	check(room.items[wrapped_uid].public_label == "Covered package" and not room.items[wrapped_uid].sprite.visible, "Opened unverified package keeps identity concealed")
	check(JSON.stringify(state) == before_wrapping, "Package opening changes no economic state or ownership")
	check(not room.open_package("foreign-uid"), "Cannot open a non-owned package")
	check(room.open_package(wrapped_uid) and room.opened_packages.size() == 1, "Repeated wrapping view is idempotent")
	state = domain.apply(state,{"id":"scene-appraise","revision":state.revision,"kind":"appraise","args":{}}).state
	room.sync(state,domain.catalog.data,Layout.defaults(),true)
	check(room.items[wrapped_uid].sprite.visible and room.items[wrapped_uid].sprite.texture.resource_path.ends_with("tools.hand_drill.png"), "Legal batch appraisal replaces wrapping with the real owned good")
	state = domain.apply(state,{"id":"scene-return","revision":state.revision,"kind":"return_shop","args":{}}).state
	for item in state.inventory.duplicate():
		if domain.shelves(state) < 6:
			state = domain.apply(state,{"id":"scene-stock"+str(item.uid),"revision":state.revision,"kind":"stock","args":{"uid":item.uid}}).state
	room.sync(state,domain.catalog.data,Layout.defaults(),true)
	check(room.shelf_mapping.size() == 6,"Six actual goods occupy six functional sockets")
	for stocked_uid in room.shelf_mapping:
		var index: int = room.shelf_mapping[stocked_uid]
		var view: Node2D = room.items[stocked_uid]
		var fixture: Node2D = room.fixtures["shelf%d" % index]
		check(view.position + view.visual_offset == Layout.fixture_positions(Layout.defaults())[index],"Every stocked sprite sits on its own shelf surface")
		check(view.position == fixture.position and view.get_index() > fixture.get_index(),"Every stocked sprite draws above its own shelf with matching Y-sort foot")
	room.queue_free()
	await process_frame

