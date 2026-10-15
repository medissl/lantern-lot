extends SceneTree

# Visible twenty-second demonstration. --profile-only measures uncaptured desktop frames.
const Main = preload("res://scripts/ui/main.gd")
var ui: Control
var metrics: Dictionary = {}

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if not "--startup-smoke" in OS.get_cmdline_user_args():
		push_error("Recording/profile requires -- --startup-smoke for save isolation")
		quit(2)
		return
	ui = Main.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	for _frame in range(5): await process_frame
	if "--profile-only" in OS.get_cmdline_user_args():
		await profile()
	else:
		await demo()
	await ui.prepare_shutdown()
	quit()

func frames(count: int) -> void:
	for _frame in range(count): await process_frame

func demo() -> void:
	# Frames are fixed at30 only by the recording command, preserving visible real-time motion.
	ui.room.move_player(Vector2(120,160))
	await frames(90)
	ui.selected = "starter-0"
	ui.fixture_command("stock", {"uid": "starter-0"})
	ui.room.move_player(Vector2(80,128))
	await frames(45)
	ui.fixture_command("visit_lot")
	ui.fixture_command("inspect", {"target": 0})
	ui.room.player.react("interact")
	await frames(30)
	ui.fixture_command("inspect", {"target": 3})
	await frames(15)
	var turns := 0
	while ui.game.state.screen in ["inspect", "auction"] and turns < 20:
		var amount: int = 40 if int(ui.game.state.lot.auction.bid) == 0 else int(ui.game.state.lot.auction.bid) + 10
		ui.fixture_command("bid", {"amount": amount})
		await frames(15)
		turns += 1
	if ui.game.state.screen != "reveal":
		push_error("Demonstration fixture did not win expected auction")
		return
	await frames(30)
	ui.room.open_package(str(ui.game.state.lot.items[3].uid))
	await frames(15)
	ui.fixture_command("appraise")
	ui.selected = str(ui.game.state.lot.items[0].uid)
	ui.open_item(ui.selected)
	await frames(30)
	ui.close_sheet()
	ui.fixture_command("return_shop")
	for item in ui.game.state.inventory.duplicate():
		if not item.shelf and ui.game.domain.shelves(ui.game.state) < 6:
			ui.fixture_command("stock", {"uid": item.uid})
	ui.room.move_player(Vector2(104,112))
	await frames(60)
	ui.fixture_command("customers")
	ui.selected = "starter-0"
	ui.refresh_dock()
	await frames(30)
	ui.fixture_command("offer", {"uid": "starter-0"})
	ui.open_sale()
	await frames(30)
	ui.fixture_command("accept")
	ui.close_sheet()
	ui.room.move_player(Vector2(136,176))
	# Hold to exactly20s including initial five frames and auction-dependent frame count.
	var used := 5 + 90 + 45 + 30 + 15 + turns * 15 + 30 + 15 + 30 + 60 + 30 + 30
	await frames(maxi(30, 600 - used))
	print("RECORDING_RESULT: 600 frames at30fps; shelf placement, walking, inspection, bidding, appraisal and sale; cosmetic motion never commits commands")

func sample(label: String) -> void:
	await frames(20)
	var samples: Array[float] = []
	var started := Time.get_ticks_usec()
	var previous := started
	for _frame in range(120):
		await process_frame
		var now := Time.get_ticks_usec()
		samples.append(float(now - previous) / 1000.0)
		previous = now
	var elapsed := float(Time.get_ticks_usec() - started) / 1000000.0
	samples.sort()
	metrics[label] = {"frames": 120, "elapsed_seconds": elapsed, "fps_wall_clock": 120.0 / elapsed, "frame_ms_median": samples[60], "frame_ms_p95": samples[114], "static_memory_bytes": OS.get_static_memory_usage(), "static_memory_peak_bytes": OS.get_static_memory_peak_usage(), "actor_nodes": ui.room.actors.size() + 1, "item_nodes": ui.room.items.size()}

func profile() -> void:
	ui.fixture_command("visit_lot")
	while ui.game.state.screen in ["inspect", "auction"]:
		ui.fixture_command("bid", {"amount": 40 if int(ui.game.state.lot.auction.bid) == 0 else int(ui.game.state.lot.auction.bid) + 10})
	ui.fixture_command("appraise")
	ui.fixture_command("return_shop")
	for item in ui.game.state.inventory.duplicate():
		if ui.game.domain.shelves(ui.game.state) < 6: ui.fixture_command("stock", {"uid": item.uid})
	ui.fixture_command("customers")
	await sample("populated_shop")
	for _visitor in range(6): ui.fixture_command("skip")
	ui.fixture_command("return_shop")
	ui.fixture_command("visit_lot")
	ui.fixture_command("bid", {"amount": 40})
	await sample("populated_auction")
	metrics["context"] = {"os": OS.get_name(), "os_version": OS.get_version(), "processor": OS.get_processor_name(), "renderer": RenderingServer.get_video_adapter_name(), "resolution": str(DisplayServer.window_get_size()), "renderer_method": ProjectSettings.get_setting("rendering/renderer/rendering_method"), "recording": false, "note": "120 actual rendered desktop frames per room; static engine allocations are not total process RSS; mobile untested"}
	var path := "res://build/visual-overhaul-evidence/desktop-profile.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(metrics, "  "))
	file.close()
	print("PROFILE_RESULT: ", JSON.stringify(metrics))
