extends Control

const Game = preload("res://scripts/services/game_session.gd")
const Value = preload("res://scripts/domain/valuation.gd")
const Room = preload("res://scripts/presentation/room_view.gd")
const Layout = preload("res://scripts/presentation/layout_controller.gd")
const VisualSave = preload("res://scripts/services/presentation_save.gd")
const StatusHUD = preload("res://scenes/ui/status_hud.tscn")
const ContextDock = preload("res://scenes/ui/context_dock.tscn")
const PAPER := Color("f7e9cc")
const INK := Color("282522")
const TEAL := Color("245b59")
const IVORY := Color("fff1d6")
var game := Game.new()
var visual_save := VisualSave.new()
var layout_editor := Layout.new()
var layout: Dictionary = {}
var settings: Dictionary = {}
var world_frame: Control
var world_texture: TextureRect
var world_viewport: SubViewport
var camera: Camera2D
var room: Node2D
var room_location := ""
var top: PanelContainer
var cash_label: Label
var status_label: Label
var dock: PanelContainer
var context_label: Label
var detail_label: Label
var primary: Button
var secondary: Button
var nav: HBoxContainer
var modal: Control
var sheet: VBoxContainer
var sheet_scroll: ScrollContainer
var modal_focus: Control
var menu_button: Button
var selected := "starter-0"
var busy := false
var release_lock := false
var cooldown_until := 0
var pointer_down := false
var pointer_id := -2
var pointer_start := Vector2.ZERO
var pointer_last := Vector2.ZERO
var panning := false
var editing_layout := false
var layout_choice := "planter"
var world_scale := 2
var smoke := false
var evidence_directory := ""
var sfx: AudioStreamPlayer
var ambience: AudioStreamPlayer
var sockets: Dictionary = {}
var visual_recovery := ""
var preview_col := 0
var preview_row := 0
var preview_valid := true
var placement_message := ""
var safe_area_fixture := Vector4.ZERO
var quitting := false
var frame_room_on_resize := true
var last_feedback := ""

func _ready() -> void:
	get_tree().auto_accept_quit = false
	# World texture rectangles are snapped in physical pixels below. Logical GUI
	# snapping would move those fractional UI coordinates after stretch (e.g.3×).
	get_viewport().gui_snap_controls_to_pixels = false
	smoke = "--ui-smoke" in OS.get_cmdline_user_args() or "--startup-smoke" in OS.get_cmdline_user_args()
	if smoke:
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--capture-size="):
				var dimensions := argument.trim_prefix("--capture-size=").split("x")
				if dimensions.size() == 2 and dimensions[0].is_valid_int() and dimensions[1].is_valid_int():
					DisplayServer.window_set_size(Vector2i(clampi(int(dimensions[0]), 240, 2160), clampi(int(dimensions[1]), 320, 3840)))
	if smoke:
		var scratch := ProjectSettings.globalize_path("res://build/visual-overhaul-evidence/scratch-%d" % Time.get_ticks_usec())
		game.saves = Game.Saves.new(scratch + "/economy")
		visual_save = VisualSave.new(scratch + "/visual")
	layout = visual_save.load_layout()
	visual_recovery = visual_save.recovery_message
	settings = visual_save.load_settings()
	if visual_save.recovery_message != "": visual_recovery += " " + visual_save.recovery_message
	sockets = visual_save.load_sockets()
	if visual_save.recovery_message != "": visual_recovery += " " + visual_save.recovery_message
	game.boot()
	build_ui()
	build_audio()
	refresh()
	if not is_instance_valid(room) and not game.state.is_empty():
		push_error("Room presentation failed to initialize.")
		get_tree().quit(1)
		return
	resized.connect(resize_ui)
	top.minimum_size_changed.connect(resize_ui.call_deferred)
	dock.minimum_size_changed.connect(resize_ui.call_deferred)
	resize_ui.call_deferred()
	if "--ui-smoke" in OS.get_cmdline_user_args(): smoke_capture.call_deferred()

func style(color: Color, border: Color = INK) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.border_color = border
	result.set_border_width_all(2)
	result.content_margin_left = 10
	result.content_margin_right = 10
	result.content_margin_top = 6
	result.content_margin_bottom = 6
	return result

func raster_style(identity: String) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = load("res://assets/pixel/ui/%s.png" % identity)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		result.set_texture_margin(side, 8)
		result.set_content_margin(side, 12 if side in [SIDE_LEFT, SIDE_RIGHT] else 8)
	return result

func apply_theme() -> void:
	var ui := Theme.new()
	ui.default_font_size = roundi(16 * float(settings.text_scale))
	if ResourceLoader.exists("res://assets/fonts/AtkinsonHyperlegibleNext-Regular.ttf"):
		ui.default_font = load("res://assets/fonts/AtkinsonHyperlegibleNext-Regular.ttf")
	ui.set_color("font_color", "Label", INK)
	for key in ["font_color", "font_hover_color", "font_pressed_color"]: ui.set_color(key, "Button", IVORY)
	ui.set_color("font_disabled_color", "Button", IVORY)
	ui.set_stylebox("normal", "Button", raster_style("teal_button"))
	ui.set_stylebox("hover", "Button", raster_style("teal_button_hover"))
	ui.set_stylebox("pressed", "Button", raster_style("teal_button_pressed"))
	ui.set_stylebox("disabled", "Button", raster_style("teal_button_disabled"))
	ui.set_stylebox("focus", "Button", raster_style("focus_ring"))
	ui.set_stylebox("panel", "PanelContainer", raster_style("paper_panel"))
	ui.set_constant("separation", "VBoxContainer", 8)
	ui.set_constant("separation", "HBoxContainer", 8)
	theme = ui
	for label in find_children("*", "Label", true, false):
		if label.has_meta("base_font_size"):
			label.add_theme_font_size_override("font_size", roundi(float(label.get_meta("base_font_size")) * float(settings.text_scale)))

func build_ui() -> void:
	apply_theme()
	var background := ColorRect.new()
	background.color = Color("3f3029")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	world_frame = Control.new()
	world_frame.clip_contents = true
	world_frame.mouse_filter = Control.MOUSE_FILTER_STOP
	world_frame.gui_input.connect(world_input)
	add_child(world_frame)
	world_texture = TextureRect.new()
	world_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	world_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	world_texture.stretch_mode = TextureRect.STRETCH_SCALE
	world_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world_frame.add_child(world_texture)
	world_viewport = SubViewport.new()
	world_viewport.disable_3d = true
	world_viewport.size = Vector2i(180, 224)
	world_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	world_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	world_texture.add_child(world_viewport)
	world_texture.texture = world_viewport.get_texture()
	camera = Camera2D.new()
	camera.position = Vector2(104, 144)
	camera.position_smoothing_enabled = false
	world_viewport.add_child(camera)
	top = StatusHUD.instantiate()
	top.add_theme_stylebox_override("panel", raster_style("paper_panel"))
	add_child(top)
	cash_label = top.get_node("Row/Amounts/Cash")
	cash_label.add_theme_font_override("font", load("res://assets/fonts/AtkinsonHyperlegibleNext-Semibold.ttf"))
	status_label = top.get_node("Row/Amounts/Status")
	menu_button = top.get_node("Row/Menu")
	menu_button.pressed.connect(open_menu)
	menu_button.custom_minimum_size.x = 72
	menu_button.autowrap_mode = TextServer.AUTOWRAP_OFF
	menu_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	dock = ContextDock.instantiate()
	dock.add_theme_stylebox_override("panel", raster_style("paper_panel"))
	add_child(dock)
	context_label = dock.get_node("Content/Selection")
	context_label.add_theme_font_override("font", load("res://assets/fonts/AtkinsonHyperlegibleNext-Semibold.ttf"))
	detail_label = dock.get_node("Content/Detail")
	primary = dock.get_node("Content/Actions/Primary")
	secondary = dock.get_node("Content/Actions/Secondary")
	primary.pressed.connect(activate_primary)
	secondary.pressed.connect(activate_secondary)
	secondary.add_theme_stylebox_override("normal", raster_style("paper_panel"))
	secondary.add_theme_color_override("font_color", INK)
	nav = dock.get_node("Content/Navigation")
	button("Stock", func():
		if editing_layout: open_layout_sheet()
		else: open_stock(), nav)
	button("Yard", func():
		if editing_layout: layout_editor.undo(); refresh()
		elif not game.state.is_empty() and game.state.screen == "shop": dispatch("visit_lot"), nav)
	button("Book", func():
		if editing_layout: cancel_layout()
		else: open_notebook(), nav)
	button("Layout", func():
		if editing_layout: save_layout()
		else: open_layout(), nav)
	for control in nav.get_children():
		var tab := raster_style("timber_tab")
		tab.content_margin_left = 6
		tab.content_margin_right = 6
		control.add_theme_stylebox_override("normal", tab)
		var pressed_tab := raster_style("timber_tab_pressed")
		pressed_tab.content_margin_left = 6
		pressed_tab.content_margin_right = 6
		control.add_theme_stylebox_override("pressed", pressed_tab)
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.hide()
	add_child(modal)

func text(value: String, parent: Node, font_size: int = 16) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", roundi(font_size * float(settings.text_scale)))
	label.set_meta("base_font_size", font_size)
	parent.add_child(label)
	return label

func button(value: String, callback: Callable, parent: Node, disabled: bool = false) -> Button:
	var result := Button.new()
	result.text = value
	result.custom_minimum_size = Vector2(48, 48)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.disabled = disabled
	result.pressed.connect(callback)
	parent.add_child(result)
	return result

func action(value: String, kind: String, args: Dictionary = {}, disabled: bool = false) -> Button:
	return button(value, func(): dispatch(kind, args), sheet, disabled)

func resize_ui() -> void:
	if not is_instance_valid(world_frame): return
	var inset := safe_insets()
	var usable := size - Vector2(inset.x + inset.z, inset.y + inset.w)
	var scale_text := float(settings.text_scale)
	var header_height := 56.0 if scale_text <= 1.0 else (76.0 if scale_text < 2.0 else 104.0)
	var dock_height := 148.0 if scale_text <= 1.0 else (202.0 if scale_text < 2.0 else 262.0)
	menu_button.custom_minimum_size.x = 72 * minf(scale_text, 1.8)
	header_height = maxf(header_height, top.get_combined_minimum_size().y)
	dock_height = maxf(dock_height, dock.get_combined_minimum_size().y)
	top.position = Vector2(inset.x, inset.y)
	top.size = Vector2(usable.x, header_height)
	dock.position = Vector2(inset.x, size.y - inset.w - dock_height)
	dock.size = Vector2(usable.x, dock_height)
	world_frame.position = Vector2(0, inset.y + header_height)
	world_frame.size = Vector2(size.x, maxf(100, dock.position.y - world_frame.position.y))
	var viewport_extent := get_viewport_rect().size.max(Vector2.ONE)
	var window_extent := Vector2(DisplayServer.window_get_size())
	if window_extent.x <= 0 or window_extent.y <= 0: window_extent = viewport_extent
	var physical_ratio := window_extent / viewport_extent
	world_frame.position = (world_frame.position * physical_ratio).ceil() / physical_ratio
	world_frame.size.y = maxf(1, dock.position.y - world_frame.position.y)
	world_scale = maxi(2, floori(world_frame.size.x * physical_ratio.x / 180.0))
	var physical_extent := (world_frame.size * physical_ratio).floor()
	world_viewport.size = Vector2i(maxi(1, floori(physical_extent.x / world_scale)), maxi(1, floori(physical_extent.y / world_scale)))
	world_texture.size = Vector2(world_viewport.size) * world_scale / physical_ratio
	world_texture.position = (((world_frame.size - world_texture.size) * 0.5) * physical_ratio).floor() / physical_ratio
	if frame_room_on_resize:
		if room_location == "shop":
			camera.position = Vector2(120 if world_viewport.size.x < 180 else 108, maxf(144, 252 - world_viewport.size.y * 0.5))
		else: camera.position = Vector2(104, maxf(144, 260 - world_viewport.size.y * 0.5))
		frame_room_on_resize = false
	clamp_camera()
	if modal.visible: position_sheet()

func safe_insets() -> Vector4:
	if smoke and safe_area_fixture != Vector4.ZERO: return safe_area_fixture
	if OS.get_name() not in ["Android", "iOS"]: return Vector4.ZERO
	var safe := DisplayServer.get_display_safe_area()
	var window := Rect2i(DisplayServer.window_get_position(), DisplayServer.window_get_size())
	if not safe.has_area() or not window.has_area(): return Vector4.ZERO
	var intersection := window.intersection(safe)
	var ratio := size / Vector2(window.size)
	return Vector4(maxi(0, intersection.position.x - window.position.x) * ratio.x, maxi(0, intersection.position.y - window.position.y) * ratio.y, maxi(0, window.end.x - intersection.end.x) * ratio.x, maxi(0, window.end.y - intersection.end.y) * ratio.y)

func clamp_camera() -> void:
	var half := Vector2(world_viewport.size) * 0.5
	for axis in range(2):
		var extent: float = 208.0 if axis == 0 else 288.0
		camera.position[axis] = roundf(clampf(camera.position[axis], half[axis], extent - half[axis])) if half[axis] * 2 < extent else extent * 0.5

func world_position(local: Vector2) -> Vector2:
	var uv := (local - world_texture.position) / world_texture.size
	return world_viewport.get_canvas_transform().affine_inverse() * (uv * Vector2(world_viewport.size))

func world_input(event: InputEvent) -> void:
	if modal.visible or busy: return
	var at := Vector2.ZERO
	var pressed := false
	var released := false
	var moving := false
	var identity := -1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		at = event.position
		pressed = event.pressed
		released = not event.pressed
	elif event is InputEventMouseMotion:
		at = event.position
		moving = true
	elif event is InputEventScreenTouch:
		if event.canceled:
			pointer_down = false
			panning = false
			pointer_id = -2
			world_frame.accept_event()
			return
		at = event.position
		identity = event.index
		pressed = event.pressed
		released = not event.pressed or event.canceled
	elif event is InputEventScreenDrag:
		at = event.position
		identity = event.index
		moving = true
	else: return
	if pressed and not pointer_down:
		pointer_down = true
		pointer_id = identity
		pointer_start = at
		pointer_last = at
		panning = false
	elif pointer_down and identity == pointer_id:
		if moving:
			if at.distance_to(pointer_start) >= 10: panning = true
			if panning:
				camera.position -= (at - pointer_last) * Vector2(world_viewport.size) / world_texture.size
				clamp_camera()
			pointer_last = at
		elif released:
			pointer_down = false
			if not panning and Rect2(world_texture.position, world_texture.size).has_point(at): select_at(world_position(at))
			panning = false
	world_frame.accept_event()

func select_at(at: Vector2) -> void:
	if editing_layout:
		preview_col = floori((at.x - 8) / 32)
		preview_row = floori((at.y - 24) / 32)
		update_layout_preview()
		return
	var best := ""
	var distance := INF
	for target in room.public_hit_targets():
		var d: float = at.distance_to(target.world_position)
		var radius := maxf(float(target.radius), 24 * Vector2(world_viewport.size).x / world_texture.size.x)
		if d <= radius and d < distance:
			best = str(target.id)
			distance = d
	if best != "":
		last_feedback = ""
		selected = best
		room.select(selected)
		play_sound("select")
		refresh_dock()
	else: room.move_player(at)

func refresh() -> void:
	apply_theme()
	if not game.state.is_empty():
		var state: Dictionary = game.state
		var location := "yard" if state.screen in ["inspect", "auction", "result"] else ("reveal" if state.screen == "reveal" else "shop")
		if location != room_location:
			if is_instance_valid(room):
				world_viewport.remove_child(room)
				room.queue_free()
			room = Room.new()
			room.room_kind = location
			if location == "shop": room.shelf_mapping = sockets.duplicate()
			world_viewport.add_child(room)
			room_location = location
			frame_room_on_resize = true
			camera.position = Vector2(104, 144)
			selected = "inspect:0" if location == "yard" else (str(state.inventory[0].uid) if not state.inventory.is_empty() else "counter")
			if location == "reveal" and not state.lot.items.is_empty(): selected = str(state.lot.items[0].uid)
		room.sync(state, game.domain.catalog.data, layout_editor.draft if editing_layout else layout, bool(settings.reduced_motion))
		room.select(selected)
		if location == "shop" and room.shelf_mapping != sockets:
			sockets = room.shelf_mapping.duplicate()
			if not visual_save.save_sockets(sockets): visual_recovery = visual_save.error
		if room.has_method("set_layout_preview"): room.set_layout_preview(editing_layout, layout_choice, preview_col, preview_row, preview_valid)
		cash_label.text = "%d coins" % state.coins
		status_label.text = "Stock %d/%d · Display %d/6" % [state.inventory.size(), state.capacity, game.domain.shelves(state)]
		if state.screen in ["inspect", "auction"]: status_label.text = "Clues %d/2 · Ceiling %d" % [state.lot.inspections.size(), state.lot.auction.limits.player]
		if state.screen == "customers": status_label.text = "Visitor %d/6 · Display %d/6" % [int(state.visitor) + 1, game.domain.shelves(state)]
	refresh_dock()
	resize_ui.call_deferred()
	if not game.pending.is_empty() or game.state.is_empty(): open_save_barrier()

func selected_item() -> Dictionary:
	return game.domain.owned(game.state, selected) if not game.state.is_empty() else {}

func item_name(item: Dictionary) -> String:
	return str(game.domain.catalog.definition(item.definition_id).name) if item.get("verified", false) else "Unidentified consignment"

func refresh_dock() -> void:
	if game.state.is_empty():
		context_label.text = "Save needs attention"
		primary.disabled = true
		secondary.disabled = true
		return
	var state: Dictionary = game.state
	var item := selected_item()
	context_label.text = item_name(item) if not item.is_empty() else "Your harbor shop"
	detail_label.text = "Select a good or fixture"
	primary.text = "Open shop"
	secondary.text = "Details"
	primary.disabled = busy or not game.pending.is_empty()
	secondary.disabled = primary.disabled
	if editing_layout:
		context_label.text = "Layout · " + layout_choice.capitalize()
		detail_label.text = placement_message if placement_message != "" else "Tap a cell · aisle stays clear"
		primary.text = "Place here"
		secondary.text = "Done"
	else:
		match state.screen:
			"shop":
				if not item.is_empty():
					detail_label.text = ("On display · ask %d" % item.ask) if item.shelf else "In stock tray · not displayed"
					primary.text = "Appraise all · free" if not item.verified else ("Unstock" if item.shelf else "Stock shelf")
					primary.disabled = primary.disabled or (item.verified and not item.shelf and game.domain.shelves(state) >= 6)
				elif selected == "bench": primary.text = "Appraise all · free"
				elif selected == "stock": primary.text = "Open stock drawer"
				elif selected == "door":
					primary.text = "Visit yard"
					if int(state.coins) < 80 or int(state.capacity) - state.inventory.size() < 6:
						primary.disabled = true
						detail_label.text = "Yard needs 80 coins and six free stock slots"
			"inspect", "auction":
				var auction: Dictionary = state.lot.auction
				context_label.text = "Bid %d · %s" % [auction.bid, "No leader" if auction.leader == "" else ("You lead" if auction.leader == "player" else str(auction.leader).capitalize() + " leads")]
				var index := int(selected.trim_prefix("inspect:")) if selected.begins_with("inspect:") else 0
				detail_label.text = hotspot_name(index) if state.screen == "inspect" else "Ceiling %d · decisions paused" % auction.limits.player
				if state.screen == "auction" and not auction.log.is_empty(): detail_label.text = str(auction.log.back())
				primary.text = "Inspect / read" if state.screen == "inspect" else "Choose bid"
				secondary.text = "Bids / leave" if state.screen == "inspect" else "Pass"
			"reveal":
				context_label.text = "Won for %d · six in stock" % state.lot.auction.bid
				detail_label.text = "No transport fee"
				primary.text = "Appraise all · free"
				secondary.text = "Return to shop"
			"result":
				context_label.text = "Auction ended · no charge"
				detail_label.text = state.notice
				primary.text = "Return to shop"
				secondary.text = "Bid ledger"
			"customers":
				var customer: Dictionary = game.domain.catalog.data.customers[int(state.visitor)]
				var visit: Dictionary = state.visits[int(state.visitor)]
				context_label.text = str(customer.name) + " · browsing"
				detail_label.text = ("a bargain" if customer.preferences.is_empty() else ", ".join(customer.preferences)) + (" · modest budget" if int(visit.budget) <= 100 else " · comfortable budget")
				primary.text = "Choose shelf item"
				if not visit.offer.is_empty():
					context_label.text = str(customer.name) + " · sale offer"
					detail_label.text = "%d gross − %d fee = %d net" % [visit.offer.gross, visit.offer.fee, int(visit.offer.gross) - int(visit.offer.fee)]
					primary.text = "Review sale"
				elif not item.is_empty() and item.shelf:
					primary.text = "Offer · ask %d" % item.ask
					primary.disabled = primary.disabled or visit.considered
				secondary.text = "Skip visitor"
			"receipt":
				context_label.text = "The shop is quiet again"
				detail_label.text = "Session %d completed" % state.shop_sessions
				primary.text = "Return to shop"
				secondary.text = "Receipt"
	if last_feedback != "" and game.error == "": detail_label.text = last_feedback
	if game.error != "": detail_label.text = game.error
	primary.accessibility_name = primary.text
	secondary.accessibility_name = secondary.text
	context_label.accessibility_name = context_label.text
	detail_label.accessibility_name = detail_label.text
	var nav_index := 0
	for child in nav.get_children():
		child.text = (["Choose", "Undo", "Cancel", "Finish"] if editing_layout else ["Stock", "Yard", "Book", "Layout"])[nav_index]
		child.disabled = busy or not game.pending.is_empty()
		if child.text in ["Yard", "Layout"]: child.disabled = child.disabled or state.screen != "shop"
		if child.text == "Yard":
			child.disabled = child.disabled or int(state.coins) < 80 or int(state.capacity) - state.inventory.size() < 6
			child.tooltip_text = "Needs 80 coins and six free stock slots; no entry fee."
		nav_index += 1

func activate_primary() -> void:
	if editing_layout: place_layout(); return
	if game.state.is_empty(): return
	var state: Dictionary = game.state
	var item := selected_item()
	match state.screen:
		"shop":
			if not item.is_empty():
				if item.verified: dispatch("stock", {"uid": selected})
				else: dispatch("appraise")
			elif selected == "bench": dispatch("appraise")
			elif selected == "door": dispatch("visit_lot")
			elif selected == "stock": open_stock()
			else: dispatch("customers")
		"inspect": open_clue()
		"auction": open_bids()
		"reveal": dispatch("appraise")
		"result", "receipt": dispatch("return_shop")
		"customers":
			var visit: Dictionary = state.visits[int(state.visitor)]
			if not visit.offer.is_empty(): open_sale()
			elif not item.is_empty() and item.shelf: dispatch("offer", {"uid": selected})
			else: open_stock()

func activate_secondary() -> void:
	if editing_layout: save_layout(); return
	if game.state.is_empty(): return
	match game.state.screen:
		"shop": open_item(selected)
		"inspect": open_bids()
		"auction": confirm_pass()
		"reveal": dispatch("return_shop")
		"customers": dispatch("skip")
		"result": open_ledger()
		"receipt": open_receipts()

func dispatch(kind: String, args: Dictionary = {}) -> void:
	if busy or release_lock or Time.get_ticks_msec() < cooldown_until or not game.pending.is_empty(): return
	busy = true
	release_lock = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept") or pointer_down
	cooldown_until = Time.get_ticks_msec() + 450
	perform.call_deferred(kind, args.duplicate(true))

func perform(kind: String, args: Dictionary) -> void:
	var before: Dictionary = game.state.duplicate(true)
	var success := game.command(kind, args)
	busy = false
	if success:
		close_sheet()
		last_feedback = ""
		play_sound("register" if kind in ["accept", "dealer"] else ("bid" if kind == "bid" else ("paper" if kind == "appraise" else "stock")))
		if kind in ["accept", "dealer"]: last_feedback = game.state.notice
		if kind == "return_shop": last_feedback = "Stock arrived · no transport fee" if not game.state.lot.is_empty() else "Back at the shop"
		if kind in ["bid", "pass"] and game.state.screen in ["reveal", "result"]: play_sound("auction_close")
	else: play_sound("invalid")
	refresh()
	if success and kind == "stock": frame_selected_target()
	if success and is_instance_valid(room) and room.has_method("present_commit"): room.present_commit(kind, args, before, game.state)
	if success and kind == "offer": open_sale()
	elif not success and game.pending.is_empty(): open_message("Action unavailable", game.error)

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed) or (event is InputEventKey and not event.pressed): release_lock = false
	if event.is_action_pressed("ui_cancel"):
		if modal.visible: close_sheet(); get_viewport().set_input_as_handled()
		elif editing_layout: cancel_layout(); get_viewport().set_input_as_handled()

func open_sheet(title: String) -> void:
	if not modal.visible: modal_focus = get_viewport().gui_get_focus_owner()
	for child in modal.get_children():
		modal.remove_child(child)
		child.queue_free()
	var shade := ColorRect.new()
	shade.color = Color(0.15, 0.13, 0.1, 0.65)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.add_child(shade)
	var panel := PanelContainer.new()
	panel.name = "SheetPanel"
	panel.add_theme_stylebox_override("panel", raster_style("paper_panel"))
	panel.minimum_size_changed.connect(position_sheet.call_deferred)
	modal.add_child(panel)
	var content := VBoxContainer.new()
	panel.add_child(content)
	var heading := HBoxContainer.new()
	content.add_child(heading)
	if float(settings.text_scale) < 2.0:
		var title_label := text(title, heading, 16 if title == "Lantern Lot" else 20)
		if title == "Lantern Lot": title_label.add_theme_font_override("font", load("res://assets/fonts/Silkscreen-Regular.ttf"))
	else:
		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		heading.add_child(spacer)
	var close := button("Close", close_sheet, heading)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.custom_minimum_size.x = 72 if float(settings.text_scale) <= 1.0 else 108
	close.autowrap_mode = TextServer.AUTOWRAP_OFF
	sheet_scroll = ScrollContainer.new()
	sheet_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sheet_scroll.follow_focus = true
	sheet_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(sheet_scroll)
	sheet = VBoxContainer.new()
	sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sheet_scroll.add_child(sheet)
	if float(settings.text_scale) >= 2.0: text(title, sheet, 20)
	modal.show()
	position_sheet()
	position_sheet.call_deferred()
	close.grab_focus.call_deferred()
	set_world_focus(false)

func position_sheet() -> void:
	var panel: Control = modal.get_node_or_null("SheetPanel")
	if panel == null: return
	var inset := safe_insets()
	var edge := maxf(inset.y + 8, top.position.y + top.size.y + 36)
	panel.position = Vector2(inset.x + 8, edge)
	panel.size = Vector2(maxf(100, size.x - inset.x - inset.z - 16), maxf(100, size.y - edge - inset.w - 8))

func set_world_focus(enabled: bool) -> void:
	for parent in [top, dock]:
		for control in parent.find_children("*", "Button", true, false): control.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func close_sheet() -> void:
	if not game.pending.is_empty() or game.state.is_empty(): return
	modal.hide()
	set_world_focus(true)
	if is_instance_valid(modal_focus) and modal_focus.is_inside_tree() and modal_focus.focus_mode != Control.FOCUS_NONE: restore_focus.call_deferred(modal_focus)
	else: restore_focus.call_deferred(primary)
	pointer_down = false
	panning = false

func restore_focus(control: Control) -> void:
	if not modal.visible and is_instance_valid(control) and control.focus_mode != Control.FOCUS_NONE and control.is_visible_in_tree(): control.grab_focus()

func open_message(title: String, message: String) -> void:
	open_sheet(title)
	text(message, sheet)

func open_save_barrier() -> void:
	open_sheet("Save needs attention")
	for control in modal.find_children("*", "Button", true, false):
		if control.text == "Close":
			control.disabled = true
			control.text = "Paused"
	text(game.error, sheet)
	text("Economic actions are paused. Your previous save files are retained.", sheet)
	if not game.pending.is_empty():
		button("Retry save", func():
			if game.retry():
				last_feedback = "Saved · action committed"
				close_sheet()
			refresh(), sheet)
	else: text("Close the game and back up your save folder before manual recovery. No automatic reset is performed.", sheet)

func open_menu() -> void:
	if not game.pending.is_empty() or game.state.is_empty(): open_save_barrier(); return
	open_sheet("Lantern Lot")
	button("Objects and fixtures", open_targets, sheet)
	button("Settings", open_settings, sheet)
	button("Receipts", open_receipts, sheet)
	button("Help", open_help, sheet)
	if game.state.screen == "shop":
		action("Open shop · six visitors", "customers")
		action("Appraise all · free", "appraise")
		action("Sort · earn 40", "commission")
		if int(game.state.rack_count) < 2:
			var cost := 120 if int(game.state.rack_count) == 0 else 180
			action("Add six stock slots · %d coins" % cost, "rack", {}, int(game.state.coins) < cost)
	if game.state.screen in ["inspect", "auction"]:
		button("Clue notebook", open_clues, sheet)
		button("Tighten ceiling", open_ceiling, sheet)
		button("Bid ledger", open_ledger, sheet)
		button("Pass permanently", confirm_pass, sheet)
		if room.has_method("skip_reactions"): button("Skip bidder reactions", func(): room.skip_reactions(); close_sheet(), sheet)
	text("Local save is healthy. Every acknowledged action is saved.", sheet, 14)
	if visual_recovery != "": text(visual_recovery, sheet)

func open_help() -> void:
	open_sheet("How to play")
	text("Select a practice object on the tray, stock its shelf, then open shop from Menu or the counter. Offer a displayed object and review the gross, fee and net before confirming.", sheet)
	text("At the yard, inspect two of four hotspots. Set a ceiling and bid exact totals. Passing is permanent. Winners already own all six objects; appraisal is free and identifies every owned object.", sheet)
	text("Tap selects; the labeled button acts. Drag the room to pan. Tap empty floor to walk. Stock and Objects provide equivalent lists. Tab moves focus; Enter activates; Escape closes sheets. Decisions wait for you.", sheet)
	text("This prototype repeats one authored household fixture. Transport and free decor change presentation only. No background income.", sheet)

func open_targets() -> void:
	open_sheet("Objects and fixtures")
	for target in room.public_hit_targets():
		var key := str(target.id)
		button(str(target.label), func(): selected = key; room.select(key); close_sheet(); refresh_dock(), sheet)
	if game.state.screen in ["inspect", "auction"]: button("Clue notebook", open_clues, sheet)

func open_stock() -> void:
	if game.state.is_empty(): return
	open_sheet("Stock · %d/%d" % [game.state.inventory.size(), game.state.capacity])
	for item in game.state.inventory:
		var uid := str(item.uid)
		var row := HBoxContainer.new()
		sheet.add_child(row)
		thumbnail(item, row)
		button(item_name(item) + (" · displayed" if item.shelf else " · in tray"), func(): selected = uid; room.select(uid); close_sheet(); refresh_dock(); open_item(uid), row)
	if game.state.inventory.is_empty(): text("Your stock tray is empty. Sorting earns 40 coins.", sheet)

func thumbnail(item: Dictionary, parent: Node, closeup: bool = false) -> void:
	var image := TextureRect.new()
	var ratio := Vector2(DisplayServer.window_get_size()) / get_viewport_rect().size.max(Vector2.ONE)
	if ratio.x <= 0 or ratio.y <= 0: ratio = Vector2.ONE
	var intended := 128.0 if closeup else 48.0
	var native := 64.0 if closeup and item.get("verified", false) else 24.0
	var integer_scale := maxi(1, floori(intended * ratio.y / native))
	image.custom_minimum_size = Vector2(native, native) * integer_scale / ratio
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var asset := "res://assets/pixel/goods/%s.png" % item.definition_id if item.get("verified", false) else "res://assets/pixel/goods/covered.png"
	var crop := "res://assets/pixel/inspect/%s.png" % item.get("definition_id", "")
	if closeup and item.get("verified", false) and ResourceLoader.exists(crop): asset = crop
	if ResourceLoader.exists(asset): image.texture = load(asset)
	parent.add_child(image)

func open_item(uid: String) -> void:
	var item: Dictionary = game.domain.owned(game.state, uid)
	if item.is_empty(): open_targets(); return
	selected = uid
	room.select(uid)
	frame_selected_target()
	open_sheet(item_name(item))
	thumbnail(item, sheet, true)
	if not item.verified:
		text("Wrapped consignment · identity and reference unknown", sheet)
		if game.state.screen == "reveal" and room.has_method("open_package"):
			button("View wrapping · no transaction", func(): room.open_package(uid); close_sheet(), sheet)
		if game.state.screen in ["shop", "reveal"]: action("Appraise all · free", "appraise")
		return
	var definition: Dictionary = game.domain.catalog.definition(item.definition_id)
	text("%s · reference %d · cost %d" % ["Excellent" if int(item.condition) == 10000 else ("Good" if int(item.condition) == 8500 else "Worn"), Value.reference_value(item), item.cost], sheet)
	if definition.has("clue"): text(str(definition.clue), sheet)
	if game.state.screen == "shop":
		text("Asking price · commits only with Set price", sheet)
		var price := numeric(1, 100000, int(item.ask) if int(item.ask) > 0 else maxi(5, Value.rounded(Value.reference_value(item), 5) * 5))
		button("Set price", func(): dispatch("price", {"uid": uid, "amount": int(price.value)}), sheet)
		action("Unstock" if item.shelf else "Stock shelf", "stock", {"uid": uid}, not item.shelf and game.domain.shelves(game.state) >= 6)
		var dealer := Value.rounded(Value.reference_value(item) * int(game.domain.config.dealer_bp))
		button("Sell to dealer · %d net" % dealer, func():
			open_sheet("Confirm dealer sale")
			text("%s leaves stock permanently. Gross %d · fee 0 · net %d." % [item_name(item), dealer, dealer], sheet)
			action("Confirm · receive %d" % dealer, "dealer", {"uid": uid}), sheet)
	elif game.state.screen == "customers" and item.shelf:
		var visit: Dictionary = game.state.visits[int(game.state.visitor)]
		action("Offer · ask %d" % item.ask, "offer", {"uid": uid}, visit.considered)

func frame_selected_target() -> void:
	if not is_instance_valid(room) or modal.visible: return
	for target in room.public_hit_targets():
		if str(target.id) != selected: continue
		var point: Vector2 = target.world_position
		var half := Vector2(world_viewport.size) * 0.5
		for axis in range(2):
			camera.position[axis] = clampf(camera.position[axis], point[axis] - half[axis] + 14, point[axis] + half[axis] - 14)
		clamp_camera()
		return

func numeric(minimum: int, maximum: int, value: int) -> SpinBox:
	var field := SpinBox.new()
	field.min_value = minimum
	field.max_value = maximum
	field.step = 1
	field.value = value
	field.custom_minimum_size = Vector2(140, 48)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.accessibility_name = "Whole-number value"
	field.get_line_edit().expand_to_text_length = true
	sheet.add_child(field)
	var steps := HBoxContainer.new()
	sheet.add_child(steps)
	button("−1", func(): field.value -= 1, steps)
	button("+1", func(): field.value += 1, steps)
	button("+5", func(): field.value += 5, steps)
	return field

func hotspot_name(index: int) -> String:
	return ["Kettle · maker mark", "Folding seat · condition", "Fan · material", "Covered crate · packing label"][clampi(index, 0, 3)]

func open_clue() -> void:
	var index := int(selected.trim_prefix("inspect:")) if selected.begins_with("inspect:") else 0
	index = clampi(index, 0, 3)
	open_sheet(hotspot_name(index))
	var seen: bool = index in game.state.lot.inspections
	if seen: text(str(game.domain.catalog.data.items[index].clue), sheet)
	else: text("Close inspection uses one of your two clues. Covered identities stay unknown.", sheet)
	if game.state.screen == "inspect": action("Read clue" if seen else "Inspect · use one clue", "inspect", {"target": index}, not seen and game.state.lot.inspections.size() >= 2)
	button("All four targets", open_clues, sheet)

func open_clues() -> void:
	open_sheet("Clues · %d/2 used" % game.state.lot.inspections.size())
	for index in range(4):
		var target := index
		var seen: bool = target in game.state.lot.inspections
		button(("✓ " if seen else "") + hotspot_name(target), func(): selected = "inspect:%d" % target; room.select(selected); open_clue(), sheet, not seen and game.state.screen != "inspect")
	button("Tighten ceiling", open_ceiling, sheet)

func open_ceiling() -> void:
	open_sheet("Tighten ceiling")
	var auction: Dictionary = game.state.lot.auction
	text("Ceilings only decrease. Reserve at least 40 coins; a leading bid remains binding.", sheet)
	var ceiling := numeric(int(auction.bid) if auction.leader == "player" else 40, int(auction.limits.player), int(auction.limits.player))
	button("Tighten ceiling", func(): dispatch("ceiling", {"amount": int(ceiling.value)}), sheet)

func open_bids() -> void:
	open_sheet("Exact bid · binding if won")
	var auction: Dictionary = game.state.lot.auction
	text("Current %d · ceiling %d · cash %d" % [auction.bid, auction.limits.player, game.state.coins], sheet)
	for step in ([40] if int(auction.bid) == 0 else [10, 20, 40]):
		var amount := int(auction.bid) + int(step)
		var above := amount > int(auction.limits.player)
		action("Bid %d · %d coins remain%s" % [amount, int(game.state.coins) - amount, " · above ceiling" if above else ""], "bid", {"amount": amount}, above)
	button("Tighten ceiling", open_ceiling, sheet)
	button("Leave freely" if int(auction.bid) == 0 else "Pass permanently", confirm_pass, sheet)
	button("Bid ledger", open_ledger, sheet)

func confirm_pass() -> void:
	open_sheet("Leave this auction")
	text("Passing is permanent. Your existing binding bid remains subject to the auction rules.", sheet)
	action("Pass permanently", "pass")

func open_ledger() -> void:
	open_sheet("Public bid ledger")
	for entry in game.state.lot.get("auction", {}).get("log", []): text(str(entry), sheet)
	if sheet.get_child_count() == 0: text("No bids yet.", sheet)

func open_sale() -> void:
	var visit: Dictionary = game.state.visits[int(game.state.visitor)]
	if visit.offer.is_empty(): return
	var offer: Dictionary = visit.offer
	var item: Dictionary = game.domain.owned(game.state, str(offer.uid))
	open_sheet("Confirm sale")
	thumbnail(item, sheet, true)
	text(item_name(item), sheet, 20)
	text("Gross %d − handling fee %d = net %d" % [offer.gross, offer.fee, int(offer.gross) - int(offer.fee)], sheet, 22)
	text(game.state.notice, sheet)
	action("Confirm sale · receive %d" % (int(offer.gross) - int(offer.fee)), "accept")
	action("Decline / skip · no penalty", "skip")

func open_receipts() -> void:
	open_sheet("Receipts")
	for receipt in game.state.receipts.slice(maxi(0, game.state.receipts.size() - 20)):
		if receipt.kind == "sale": text("%s · gross %d − fee %d = net %d" % [receipt.buyer, receipt.gross, receipt.fee, receipt.net], sheet)
		else: text("%s · %s · bid %d" % [receipt.lot_id, str(receipt.winner).capitalize(), receipt.bid], sheet)
	if game.state.receipts.is_empty(): text("Your first receipt will appear here.", sheet)

func open_notebook() -> void:
	if game.state.is_empty(): return
	open_sheet("Notebook · %d/6 discovered" % game.state.discoveries.size())
	for definition in game.domain.catalog.data.items:
		var discovered: bool = definition.id in game.state.discoveries
		var owned := false
		for item in game.state.inventory:
			if item.definition_id == definition.id: owned = true
		if discovered:
			thumbnail({"definition_id": definition.id, "verified": true}, sheet)
			text(str(definition.name) + " · Discovered" + (" · Owned" if owned else " · No copy owned"), sheet)
			text(str(definition.clue), sheet, 14)
		else: text("Unknown consignment · not discovered", sheet)

func open_settings() -> void:
	open_sheet("Settings")
	text("Text size", sheet)
	for scale_value in [1.0, 1.5, 2.0]:
		var option: float = scale_value
		button("%d%%" % roundi(option * 100), func(): settings.text_scale = option; save_settings(); refresh(); open_settings(), sheet)
	button("Reduced motion · " + ("on" if settings.reduced_motion else "off"), func(): settings.reduced_motion = not settings.reduced_motion; save_settings(); refresh(); open_settings(), sheet)
	button("Sound · " + ("on" if settings.sound else "off"), func(): settings.sound = not settings.sound; save_settings(); update_audio(); open_settings(), sheet)
	for channel in ["sfx_volume", "ambience_volume"]:
		var key := str(channel)
		text("Effects level" if key == "sfx_volume" else "Ambience level", sheet)
		var volume := HSlider.new()
		volume.min_value = 0
		volume.max_value = 1
		volume.step = 0.05
		volume.value = float(settings.get(key, 0.3))
		volume.custom_minimum_size = Vector2(48, 48)
		volume.value_changed.connect(func(value: float): settings[key] = value; update_audio())
		volume.drag_ended.connect(func(_changed: bool): save_settings())
		volume.focus_exited.connect(save_settings)
		sheet.add_child(volume)
	text("Haptics off · no device vibration requested", sheet, 14)

func save_settings() -> void:
	if not visual_save.save_settings(settings):
		last_feedback = "Settings could not save: " + visual_save.error
		if modal.visible: text(last_feedback, sheet)

func open_layout() -> void:
	if game.state.is_empty() or game.state.screen != "shop": return
	if not editing_layout:
		layout_editor.begin(layout)
		editing_layout = true
	var placement: Dictionary = layout_editor.draft.fixtures[layout_choice] if layout_choice.begins_with("shelf") else layout_editor.draft.placements[layout_choice]
	preview_col = int(placement.col)
	preview_row = int(placement.row)
	placement_message = ""
	refresh()
	open_layout_sheet()

func open_layout_sheet() -> void:
	open_sheet("Free shop decoration")
	text("Choose a piece, then tap a room cell. Place here commits the preview; Done saves your layout.", sheet)
	var choices := GridContainer.new()
	choices.columns = 2
	sheet.add_child(choices)
	for asset in ["rug", "planter", "wall_clock", "harbor_print", "stool", "lamp", "shelf0", "shelf1", "shelf2", "shelf3", "shelf4", "shelf5"]:
		var key := str(asset)
		var name_text := "Display %d" % (int(key.trim_prefix("shelf")) + 1) if key.begins_with("shelf") else key.replace("_", " ").capitalize()
		button(name_text, func():
			layout_choice = key
			var placement: Dictionary = layout_editor.draft.fixtures[key] if key.begins_with("shelf") else layout_editor.draft.placements[key]
			preview_col = int(placement.col)
			preview_row = int(placement.row)
			close_sheet()
			update_layout_preview(), choices)
	text("Place " + layout_choice.replace("_", " ") + ". Columns 0–5, rows 0–7. Wall pieces use row 0.", sheet)
	text("Column", sheet, 14)
	var column := numeric(0, 5, preview_col)
	column.accessibility_name = "Decoration column"
	text("Row", sheet, 14)
	var row := numeric(0, 7, preview_row)
	row.accessibility_name = "Decoration row"
	column.value_changed.connect(func(value: float): preview_col = int(value); update_layout_preview())
	row.value_changed.connect(func(value: float): preview_row = int(value); update_layout_preview())
	button("Preview in room", close_sheet, sheet)
	button("Place here", place_layout, sheet)
	button("Undo last edit", func(): layout_editor.undo(); refresh(); open_layout_sheet(), sheet)
	button("Done · save layout", save_layout, sheet)
	button("Cancel all edits", cancel_layout, sheet)
	if placement_message != "": text(placement_message, sheet)

func update_layout_preview() -> void:
	var candidate: Dictionary = layout_editor.draft.duplicate(true)
	if layout_choice.begins_with("shelf"): candidate.fixtures[layout_choice] = {"col": preview_col, "row": preview_row}
	else: candidate.placements[layout_choice] = {"col": preview_col, "row": preview_row}
	var result: Dictionary = Layout.validate(candidate)
	preview_valid = result.ok
	placement_message = "✓ Column %d · row %d" % [preview_col, preview_row] if result.ok else "× " + str(result.message)
	if room.has_method("set_layout_preview"): room.set_layout_preview(true, layout_choice, preview_col, preview_row, preview_valid)
	refresh_dock()

func place_layout() -> void:
	var result: Dictionary = layout_editor.place(layout_choice, preview_col, preview_row)
	preview_valid = result.ok
	placement_message = "✓ Placement applied · Done to save" if result.ok else "× " + str(result.message)
	last_feedback = ""
	close_sheet()
	refresh()

func save_layout() -> void:
	var result: Dictionary = Layout.validate(layout_editor.draft)
	if not result.ok: open_message("Placement rejected", result.message); return
	if not visual_save.save_layout(layout_editor.draft):
		open_message("Layout could not save", visual_save.error + " Your draft is retained.")
		button("Retry layout save", save_layout, sheet)
		button("Cancel edits", cancel_layout, sheet)
		return
	layout = layout_editor.draft.duplicate(true)
	editing_layout = false
	last_feedback = "Layout saved · economy unchanged"
	close_sheet()
	refresh()

func cancel_layout() -> void:
	layout_editor.cancel()
	editing_layout = false
	last_feedback = "Layout edits cancelled"
	close_sheet()
	refresh()

func build_audio() -> void:
	for bus in ["Music", "Ambience", "SFX"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	sfx = AudioStreamPlayer.new()
	sfx.bus = "SFX"
	add_child(sfx)
	ambience = AudioStreamPlayer.new()
	ambience.bus = "Ambience"
	add_child(ambience)
	if ResourceLoader.exists("res://assets/audio/room_ambience.wav"):
		var loop: AudioStreamWAV = load("res://assets/audio/room_ambience.wav").duplicate()
		loop.loop_begin = 0
		loop.loop_end = roundi(loop.mix_rate * loop.get_length())
		loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
		ambience.stream = loop
		if DisplayServer.get_name() != "headless": ambience.play()
	update_audio()

func update_audio() -> void:
	for entry in [["SFX", "sfx_volume"], ["Ambience", "ambience_volume"]]:
		var index := AudioServer.get_bus_index(entry[0])
		var volume := float(settings.get(entry[1], 0.3))
		AudioServer.set_bus_mute(index, not bool(settings.sound) or volume <= 0)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume * 0.5, 0.001)))

func play_sound(identity: String) -> void:
	if not is_instance_valid(sfx) or not bool(settings.sound) or DisplayServer.get_name() == "headless": return
	var asset := "res://assets/audio/%s.wav" % identity
	if ResourceLoader.exists(asset):
		sfx.stream = load(asset)
		sfx.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: quit_cleanly.call_deferred()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		pointer_down = false
		panning = false
		release_lock = false
		if is_instance_valid(ambience): ambience.stop()
		if is_instance_valid(world_viewport): world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		if is_instance_valid(world_viewport): world_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		resize_ui.call_deferred()
		if is_instance_valid(ambience) and ambience.stream != null: ambience.play()

func _exit_tree() -> void:
	if is_instance_valid(sfx):
		sfx.stop()
		sfx.stream = null
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null

func prepare_shutdown() -> void:
	if is_instance_valid(room): room.skip_reactions()
	if is_instance_valid(sfx):
		sfx.stop()
		sfx.stream = null
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null
	# Give the audio mixer and queued presentation frees time to release playback.
	await get_tree().create_timer(0.05).timeout
	for _frame in range(3): await get_tree().process_frame

func quit_cleanly() -> void:
	if quitting: return
	quitting = true
	busy = true
	await prepare_shutdown()
	get_tree().quit()

func fixture_command(kind: String, args: Dictionary = {}) -> void:
	var before: Dictionary = game.state.duplicate(true)
	var success := game.command(kind, args)
	if not success:
		push_error("UI smoke command failed: %s: %s" % [kind, game.error])
		get_tree().quit(1)
		return
	last_feedback = ""
	refresh()
	if success and is_instance_valid(room) and room.has_method("present_commit"): room.present_commit(kind, args, before, game.state)

func capture(identity: String) -> void:
	await get_tree().create_timer(0.4).timeout
	for _frame in range(3): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := evidence_directory.path_join(identity + ".png")
	get_viewport().get_texture().get_image().save_png(path)
	var ratio := Vector2(DisplayServer.window_get_size()) / get_viewport_rect().size.max(Vector2.ONE)
	var origin := (world_frame.position + world_texture.position) * ratio
	var extent := world_texture.size * ratio
	var metadata := {"window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "world_rect_physical": [roundi(origin.x), roundi(origin.y), roundi(extent.x), roundi(extent.y)], "world_viewport": [world_viewport.size.x, world_viewport.size.y], "integer_world_scale": world_scale, "domain_screen": game.state.screen, "coins": game.state.coins, "stock_count": game.state.inventory.size(), "display_count": game.domain.shelves(game.state), "text_scale": settings.text_scale, "simulated_safe_area": safe_area_fixture != Vector4.ZERO}
	var info := FileAccess.open(evidence_directory.path_join(identity + ".json"), FileAccess.WRITE)
	info.store_string(JSON.stringify(metadata, "  "))
	info.close()
	print("UI_SMOKE_CAPTURE:", path)

func smoke_capture() -> void:
	var window := DisplayServer.window_get_size()
	evidence_directory = ProjectSettings.globalize_path("res://build/visual-overhaul-evidence/%dx%d" % [window.x, window.y])
	DirAccess.make_dir_recursive_absolute(evidence_directory)
	await capture("01-shop-sparse")
	fixture_command("stock", {"uid": "starter-0"})
	fixture_command("visit_lot")
	fixture_command("inspect", {"target": 0})
	fixture_command("inspect", {"target": 3})
	await capture("03-yard-inspect")
	fixture_command("bid", {"amount": 40})
	await capture("04-auction-bid")
	var turns := 0
	while game.state.screen in ["inspect", "auction"] and turns < 40:
		var auction: Dictionary = game.state.lot.auction
		var amount := int(auction.bid) + 10
		if amount > int(auction.limits.player): fixture_command("pass"); break
		fixture_command("bid", {"amount": amount})
		turns += 1
	if game.state.screen == "reveal":
		await capture("05-won-storage")
		fixture_command("appraise")
		selected = str(game.state.lot.items[0].uid)
		open_item(selected)
		await capture("06-appraisal")
		close_sheet()
		fixture_command("return_shop")
		last_feedback = "Stock arrived · no transport fee"
		refresh_dock()
		await capture("07-transport")
		for item in game.state.inventory.duplicate():
			if game.domain.shelves(game.state) < 6 and not item.shelf: fixture_command("stock", {"uid": item.uid})
	else: fixture_command("return_shop")
	layout_editor.begin(layout)
	layout_editor.place("planter", 0, 4)
	layout = layout_editor.draft.duplicate(true)
	refresh()
	room.skip_reactions()
	await capture("02-shop-stocked")
	fixture_command("customers")
	selected = "starter-0"
	refresh_dock()
	await capture("08-customer-browse")
	fixture_command("offer", {"uid": "starter-0"})
	open_sale()
	await capture("09-sale-confirm")
	fixture_command("accept")
	close_sheet()
	await capture("10-sold")
	for _visitor in range(5): fixture_command("skip")
	await capture("20-receipt")
	open_notebook()
	await capture("11-notebook")
	close_sheet()
	fixture_command("return_shop")
	open_layout()
	close_sheet()
	update_layout_preview()
	await capture("12-layout-valid")
	preview_col = 2
	preview_row = 4
	update_layout_preview()
	await capture("13-layout-invalid")
	cancel_layout()
	var original_saves = game.saves
	var barrier := evidence_directory.path_join("blocked-save")
	var blocker := FileAccess.open(barrier, FileAccess.WRITE)
	blocker.store_string("fixture blocks directory creation")
	blocker.close()
	game.saves = Game.Saves.new(barrier + "/child")
	game.command("commission")
	refresh()
	await capture("14-save-failure")
	game.saves = original_saves
	game.retry()
	close_sheet()
	settings.text_scale = 2.0
	refresh()
	open_item(str(game.state.inventory[0].uid))
	await capture("15-large-text-200")
	settings.text_scale = 1.0
	close_sheet()
	refresh()
	safe_area_fixture = Vector4(0, 28, 0, 24)
	resize_ui()
	await capture("17-notch-safe-area-simulated")
	safe_area_fixture = Vector4.ZERO
	resize_ui()
	room.player.walk_path(PackedVector2Array())
	room.player.position = Vector2(32, 112)
	await capture("18-depth-front")
	room.player.position = Vector2(32, 92)
	await capture("19-depth-behind")
	print("UI_SMOKE: integrated full loop; %d coins; %d stock; %d discoveries" % [game.state.coins, game.state.inventory.size(), game.state.discoveries.size()])
	await quit_cleanly()
