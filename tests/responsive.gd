extends SceneTree

# Actual renderer matrix; only isolated fixture saves under build/ are opened.
const Main = preload("res://scripts/ui/main.gd")
var ui: Control
var checks := 0
var failed := false
var context := ""
var evidence := "res://build/visual-overhaul-evidence/responsive"

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failed = true
		push_error("RESPONSIVE_FAIL [%s]: %s" % [context,description])

func settle(count := 5) -> void:
	for _frame in range(count): await process_frame

func within(control: Control, area: Rect2) -> bool:
	var rect := control.get_global_rect()
	return rect.position.x >= area.position.x - 1 and rect.position.y >= area.position.y - 1 and rect.end.x <= area.end.x + 1 and rect.end.y <= area.end.y + 1

func capture(name_text: String, extent: Vector2i) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	var path := evidence.path_join("%dx%d" % [extent.x,extent.y])
	DirAccess.make_dir_recursive_absolute(path)
	root.get_texture().get_image().save_png(path.path_join(name_text + ".png"))

func show_control(control: Control) -> void:
	ui.sheet_scroll.ensure_control_visible(control)
	await settle()
	check(within(control,ui.sheet_scroll.get_global_rect()),"Scrolled control is fully reachable: " + control.name)
	check(within(control,Rect2(Vector2.ZERO,Vector2(root.size))),"Scrolled control stays inside actual window: " + control.name)

func test_modal() -> void:
	var window_rect := Rect2(Vector2.ZERO,Vector2(root.size))
	check(within(ui.modal.get_node("SheetPanel"),window_rect),"Modal panel stays inside window: panel=%s window=%s ui=%s" % [ui.modal.get_node("SheetPanel").get_global_rect(),window_rect,ui.size])
	check(ui.sheet.get_global_rect().position.x >= 0 and ui.sheet.get_global_rect().end.x <= root.size.x + 1,"Modal content has no horizontal overflow")
	for control in ui.sheet.find_children("*","Button",true,false):
		await show_control(control)

func run() -> void:
	if not "--startup-smoke" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		push_error("Responsive suite requires actual rendering and -- --startup-smoke")
		quit(2)
		return
	ui = Main.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	await settle()
	for extent in [Vector2i(360,640),Vector2i(320,568),Vector2i(393,852)]:
		root.content_scale_size = extent
		root.size = extent
		DisplayServer.window_set_size(extent)
		await settle(10)
		check(DisplayServer.window_get_size() == extent,"Actual window matches requested size")
		await test_world_pointer()
		for scale_value in [1.0,1.5,2.0]:
			context = "%dx%d text%d" % [extent.x,extent.y,int(scale_value*100)]
			ui.settings.text_scale = scale_value
			ui.refresh()
			await settle()
			var window_rect := Rect2(Vector2.ZERO,Vector2(extent))
			check(within(ui.top,window_rect),"Top status stays inside window")
			check(within(ui.dock,window_rect),"Dock stays inside window")
			check(within(ui.primary,window_rect),"Primary action stays inside window")
			for control in ui.nav.get_children(): check(within(control,window_rect),"Navigation remains reachable: " + control.text)
			if extent == Vector2i(320,568) and scale_value == 1.0: await capture("16-short-phone",extent)
			ui.open_item("starter-0")
			await settle()
			var field: SpinBox = ui.sheet.find_children("*","SpinBox",true,false)[0]
			field.value = 100000
			await test_modal()
			await show_control(field)
			var line := field.get_line_edit()
			check(line.text == "100000","Price field retains six-digit maximum")
			var width := line.get_theme_font("font").get_string_size(line.text,HORIZONTAL_ALIGNMENT_LEFT,-1,line.get_theme_font_size("font_size")).x
			check(line.size.x >= width + 10,"Price100000 fits line edit without hiding leading digits")
			if scale_value == 2.0: await capture("21-price-100000-200",extent)
			ui.close_sheet()
			ui.fixture_command("stock",{"uid":"starter-0"})
			ui.fixture_command("customers")
			ui.fixture_command("offer",{"uid":"starter-0"})
			ui.open_sale()
			await settle()
			await test_modal()
			var offer: Dictionary = ui.game.state.visits[0].offer
			var totals: Label
			var confirm: Button
			for control in ui.sheet.get_children():
				if control is Label and control.text.begins_with("Gross"): totals = control
				if control is Button and control.text.begins_with("Confirm sale"): confirm = control
			check(totals.text == "Gross %d − handling fee %d = net %d" % [offer.gross,offer.fee,int(offer.gross)-int(offer.fee)],"Sale totals are exact and present")
			await show_control(totals)
			if scale_value == 2.0: await capture("22-sale-200-totals",extent)
			await show_control(confirm)
			if scale_value == 2.0: await capture("22-sale-200",extent)
			ui.close_sheet()
			for _visitor in range(6): ui.fixture_command("skip")
			ui.fixture_command("return_shop")
			ui.fixture_command("stock",{"uid":"starter-0"})
	print("RESPONSIVE_TEST_RESULT: %d checks; %s" % [checks,"FAILED" if failed else "PASS"])
	ui.room.skip_reactions()
	ui.queue_free()
	await settle(3)
	quit(1 if failed else 0)

func test_world_pointer() -> void:
	ui.settings.text_scale = 1.0
	ui.refresh()
	await settle()
	context = "%dx%d pointer100" % [root.size.x,root.size.y]
	ui.camera.position = Vector2(104,220)
	ui.clamp_camera()
	await settle()
	var target: Dictionary
	for hit in ui.room.public_hit_targets():
		if hit.id == "starter-1": target = hit
	var viewport_point: Vector2 = ui.world_viewport.get_canvas_transform() * target.world_position
	var local: Vector2 = ui.world_texture.position + viewport_point / Vector2(ui.world_viewport.size) * ui.world_texture.size
	check(Rect2(Vector2.ZERO,ui.world_frame.size).has_point(local),"Pointer fixture lies inside displayed room after camera pan")
	var press_event := InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.position = local
	press_event.pressed = true
	ui.world_input(press_event)
	var release_event := InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.position = local
	release_event.pressed = false
	ui.world_input(release_event)
	check(ui.selected == "starter-1","Transformed actual pointer events select correct world uid")
	ui.selected = "starter-0"
	press_event.position = local + Vector2(20,0)
	ui.world_input(press_event)
	var motion := InputEventMouseMotion.new()
	motion.position = local
	motion.relative = Vector2(-20,0)
	ui.world_input(motion)
	ui.world_input(release_event)
	check(ui.selected == "starter-0" and not ui.pointer_down,"Pan release over good cannot select or issue intent")
	ui.camera.position = Vector2(104,144)
	ui.clamp_camera()
	ui.refresh_dock()

