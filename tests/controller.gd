extends SceneTree

# Run with -- --startup-smoke. Every fixture stays under build/, never user saves.
const Main = preload("res://scripts/ui/main.gd")
var ui: Control
var checks := 0
var failed := false

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failed = true
		push_error("CONTROLLER_FAIL: " + message)

func find_button(prefix: String) -> Button:
	var parent: Node = ui.modal if ui.modal.visible else ui
	for node in parent.find_children("*", "Button", true, false):
		if node.is_visible_in_tree() and node.text.begins_with(prefix): return node
	return null

func press(prefix: String) -> void:
	await create_timer(0.46).timeout
	var control := find_button(prefix)
	check(control != null and not control.disabled, "Reachable enabled button: " + prefix)
	if control != null and not control.disabled:
		control.pressed.emit()
	for _frame in range(3): await process_frame

func run() -> void:
	if not "--startup-smoke" in OS.get_cmdline_user_args():
		push_error("Run controller tests with -- --startup-smoke to isolate saves")
		quit(2)
		return
	ui = Main.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	for _frame in range(5): await process_frame
	check(ui.game.state.coins == 360 and ui.game.state.inventory.size() == 3, "Fresh isolated fixture")
	await test_keyboard_and_cancelled_touch()
	var persistent_room: Node = ui.room
	await press("Stock shelf")
	check(ui.game.state.inventory[0].shelf and ui.game.state.coins == 360, "Dock stocks correct starter without charge")
	check(ui.room == persistent_room, "Stock leaves room persistent")
	check(ui.visual_save.load_sockets().has("starter-0"), "Stock mapping persisted")
	await test_fixture_editor()
	await press("Details")
	var price: SpinBox = ui.sheet.find_children("*", "SpinBox", true, false)[0]
	price.value = 35
	var revision := int(ui.game.state.revision)
	await process_frame
	check(ui.game.state.revision == revision, "Editing price field alone cannot commit")
	await press("Set price")
	check(ui.game.state.inventory[0].ask == 35, "Set price button commits exact amount")
	await press("Menu")
	await press("Sort · earn 40")
	check(ui.game.state.coins == 400, "Commission binding pays exact40")
	await press("Menu")
	var rapid := find_button("Sort · earn 40")
	await create_timer(0.46).timeout
	rapid.pressed.emit()
	rapid.pressed.emit()
	for _frame in range(3): await process_frame
	check(ui.game.state.coins == 440, "Rapid duplicate button activation commits commission once")
	await press("Yard")
	check(ui.game.state.screen == "inspect" and ui.game.state.coins == 440, "Yard entry has no fee")
	await press("Inspect / read")
	await press("Inspect · use one clue")
	check(ui.game.state.lot.inspections == [0], "Inspection button targets selected hotspot")
	ui.select_at(ui.room.LOT_SOCKETS[3] - Vector2(0,10))
	await press("Inspect / read")
	await press("Inspect · use one clue")
	check(ui.game.state.lot.inspections == [0,3], "Second selected hotspot inspection")
	ui.select_at(ui.room.LOT_SOCKETS[1] - Vector2(0,10))
	await press("Inspect / read")
	check(find_button("Inspect · use one clue").disabled, "Third unread inspection disabled at quota")
	await press("Close")
	ui.select_at(ui.room.LOT_SOCKETS[0] - Vector2(0,10))
	await press("Inspect / read")
	await press("Read clue")
	check(ui.game.state.lot.inspections == [0,3], "Known clue reread never consumes another inspection")
	for target in ui.room.public_hit_targets():
		check(not "tram" in str(target.label).to_lower() and not "bowl" in str(target.label).to_lower(), "Concealed hotspot labels remain neutral")
	await press("Bids / leave")
	await press("Bid 40 ·")
	check(ui.game.state.screen in ["auction", "reveal"], "Bid button advances committed auction")
	var turns := 0
	while ui.game.state.screen == "auction" and turns < 30:
		await press("Choose bid")
		await press("Bid %d ·" % (int(ui.game.state.lot.auction.bid) + 10))
		turns += 1
	check(ui.game.state.screen == "reveal", "Button-driven auction wins fixture")
	check(ui.game.state.inventory.size() == 9, "All six goods transferred atomically")
	var paid := int(ui.game.state.coins)
	await press("Appraise all · free")
	check(ui.game.state.coins == paid and ui.game.state.discoveries.size() == 6, "Batch appraisal free and verifies all six discoveries")
	await press("Return to shop")
	await press("Menu")
	await press("Open shop · six visitors")
	check(ui.game.state.screen == "customers", "Menu starts paused customer wave")
	await press("Offer")
	var offer: Dictionary = ui.game.state.visits[0].offer.duplicate()
	check(not offer.is_empty() and ui.modal.visible, "Offer opens sale confirmation")
	var totals_visible := false
	for label in ui.sheet.find_children("*", "Label", true, false):
		if label.text == "Gross %d − handling fee %d = net %d" % [offer.gross, offer.fee, int(offer.gross) - int(offer.fee)]: totals_visible = true
	check(totals_visible, "Sale confirmation exposes exact gross fee and net")
	await create_timer(0.46).timeout
	var confirm := find_button("Confirm sale · receive")
	check(confirm != null and not confirm.disabled, "Sale confirmation enabled")
	confirm.pressed.emit()
	confirm.pressed.emit()
	for _frame in range(3): await process_frame
	check(ui.game.state.coins == paid + int(offer.gross) - int(offer.fee), "Confirm sale commits exact displayed net")
	check(ui.game.state.visitor == 1 and not ui.room.items.has("starter-0"), "Sale removes actual sprite and advances once")
	check(ui.game.state.visits[1].offer.is_empty(), "Double-tap sale cannot offer to next customer")
	for _visitor in range(5): await press("Skip visitor")
	check(ui.game.state.screen == "receipt" and ui.game.state.shop_sessions == 1, "Queue ends once with receipt")
	await press("Return to shop")
	var healthy_saves = ui.game.saves
	var blocked: String = ui.game.saves.directory.path_join("blocked")
	var file := FileAccess.open(blocked, FileAccess.WRITE)
	file.store_string("deliberate directory failure fixture")
	file.close()
	ui.game.saves = ui.Game.Saves.new(blocked.path_join("child"))
	await press("Menu")
	var before: Dictionary = ui.game.state.duplicate(true)
	await press("Sort · earn 40")
	check(ui.game.state == before and not ui.game.pending.is_empty(), "Save failure keeps committed economy and pending action")
	check(ui.modal.visible and ui.primary.disabled and find_button("Paused").disabled, "Save barrier visibly blocks economic controls and close")
	ui.primary.pressed.emit()
	await process_frame
	check(ui.game.state == before, "Press behind barrier cannot issue command")
	ui.game.saves = healthy_saves
	await press("Retry save")
	check(ui.game.pending.is_empty() and ui.game.state.coins == before.coins + 40 and not ui.modal.visible, "Retry commits retained action exactly once")
	check(healthy_saves.load_latest() == ui.game.state, "Retry durable state matches visible state")
	print("CONTROLLER_TEST_RESULT: %d checks; %s" % [checks, "FAILED" if failed else "PASS"])
	ui.queue_free()
	await process_frame
	quit(1 if failed else 0)

func key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func test_fixture_editor() -> void:
	var economic_before: Dictionary = ui.game.state.duplicate(true)
	await press("Layout")
	await press("Display 1")
	ui.select_at(Vector2(24,104))
	check(ui.preview_valid,"Valid shelf preview has reachable service position")
	await press("Place here")
	check(ui.layout_editor.draft.fixtures.shelf0.row == 2,"Shelf placement updates editable draft")
	await press("Done")
	check(not ui.editing_layout and ui.visual_save.load_layout().fixtures.shelf0.row == 2,"Done atomically persists relocated fixture")
	check(ui.game.state == economic_before,"Moving fixtures cannot change economy or stock")
	check(ui.room.items["starter-0"].destination + ui.room.items["starter-0"].visual_offset == Vector2(32,104),"Same shelved uid follows relocated fixture")
	await press("Layout")
	await press("Display 2")
	ui.select_at(Vector2(184,104))
	await press("Place here")
	var healthy_visual = ui.visual_save
	var blocker_path: String = healthy_visual.directory.path_join("blocked")
	var file := FileAccess.open(blocker_path,FileAccess.WRITE)
	file.store_string("visual failure fixture")
	file.close()
	ui.visual_save = ui.VisualSave.new(blocker_path.path_join("child"))
	var draft: Dictionary = ui.layout_editor.draft.duplicate(true)
	await press("Done")
	check(ui.editing_layout and ui.layout_editor.draft == draft,"Failed visual save retains edit mode and draft")
	check(find_button("Retry layout save") != null and find_button("Cancel edits") != null,"Failed visual save exposes Retry and Cancel")
	ui.visual_save = healthy_visual
	await press("Retry layout save")
	check(not ui.editing_layout and healthy_visual.load_layout() == draft,"Retry saves retained fixture draft")
	check(ui.game.state == economic_before,"Visual failure/retry cannot alter business state")

func test_keyboard_and_cancelled_touch() -> void:
	var cancelled_target: Dictionary = {}
	for target in ui.room.public_hit_targets():
		if target.id == "starter-1": cancelled_target = target
	var viewport_point: Vector2 = ui.world_viewport.get_canvas_transform() * cancelled_target.world_position
	var local_point: Vector2 = ui.world_texture.position + viewport_point / Vector2(ui.world_viewport.size) * ui.world_texture.size
	var touch := InputEventScreenTouch.new()
	touch.index = 7
	touch.position = local_point
	touch.pressed = true
	ui.world_input(touch)
	var cancel := InputEventScreenTouch.new()
	cancel.index = 7
	cancel.position = local_point
	cancel.pressed = false
	cancel.canceled = true
	ui.world_input(cancel)
	check(ui.selected == "starter-0" and not ui.pointer_down,"Canceled real world touch cannot select another object")
	ui.primary.grab_focus()
	await process_frame
	check(root.gui_get_focus_owner() == ui.primary,"Dock primary receives keyboard focus")
	await key(KEY_SPACE,true)
	await key(KEY_SPACE,false)
	for _frame in range(3): await process_frame
	check(ui.game.state.inventory[0].shelf,"Keyboard Space activates focused stock button")
	await create_timer(0.46).timeout
	await key(KEY_SPACE,true)
	await key(KEY_SPACE,false)
	for _frame in range(3): await process_frame
	check(not ui.game.state.inventory[0].shelf,"Keyboard release permits next deliberate stock toggle")
	ui.menu_button.grab_focus()
	await key(KEY_SPACE,true)
	await key(KEY_SPACE,false)
	check(ui.modal.visible,"Keyboard can open menu sheet")
	await process_frame
	var focused := root.gui_get_focus_owner()
	check(focused != null and focused.text == "Close","Modal receives focused reachable Close button")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	for _frame in range(3): await process_frame
	check(not ui.modal.visible and root.gui_get_focus_owner() == ui.menu_button,"Escape closes modal and restores originating keyboard focus")

