extends Control

const Game = preload("res://scripts/services/game_session.gd")
const Value = preload("res://scripts/domain/valuation.gd")
const World = preload("res://scripts/ui/world.gd")
var game := Game.new()
var body: VBoxContainer
var scroll: ScrollContainer
var large_text: bool = false
var help_open: bool = false
var busy: bool = false
var restore_scroll: float = 0
var restore_focus: String = ""
const CREAM := Color("f2e9d4")
const MUTED := Color("abbdb5")
const GOLD := Color("e4b866")
const MINT := Color("96cabb")

func _ready() -> void:
	get_tree().auto_accept_quit = false
	if "--ui-smoke" in OS.get_cmdline_user_args():
		game.saves = Game.Saves.new(ProjectSettings.globalize_path("res://build/ui-smoke-%d" % Time.get_ticks_usec()))
	game.boot()
	render()
	if "--ui-smoke" in OS.get_cmdline_user_args():
		smoke_capture.call_deferred()

func box(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1 if border.a > 0 else 0)
	style.set_corner_radius_all(7)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func build_theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 20 if large_text else 15
	result.set_color("font_color", "Label", CREAM)
	result.set_color("font_color", "Button", CREAM)
	result.set_color("font_hover_color", "Button", CREAM)
	result.set_color("font_disabled_color", "Button", Color("72847d"))
	result.set_stylebox("normal", "Button", box(Color("2c4541")))
	result.set_stylebox("hover", "Button", box(Color("3b5b52"), MINT))
	result.set_stylebox("pressed", "Button", box(Color("49695e"), GOLD))
	result.set_stylebox("disabled", "Button", box(Color("24332f")))
	result.set_stylebox("focus", "Button", box(Color.TRANSPARENT, GOLD))
	result.set_constant("separation", "VBoxContainer", 9)
	result.set_constant("separation", "HBoxContainer", 8)
	return result

func render() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	theme = build_theme()
	var background := ColorRect.new()
	background.color = Color("172829")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	add_child(margin)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	margin.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	label("LANTERN LOT", body, 26, GOLD)
	label("A little shop. A second life.", body, 14, MUTED)
	var utilities := HBoxContainer.new()
	body.add_child(utilities)
	button("Help", func(): help_open = not help_open; render(), utilities)
	button("Text +" if not large_text else "Text −", func(): large_text = not large_text; render(), utilities)
	if not game.pending.is_empty() or game.state.is_empty():
		label("Saving needs attention", body, 22, GOLD)
		label(game.error, body)
		if not game.pending.is_empty():
			button("Retry save", func(): game.retry(); render(), body)
		label("Economic actions are paused. Previous save files are retained.", body, 14, MUTED)
		return
	var s: Dictionary = game.state
	label("%d coins   ·   Stock %d/%d   ·   Shelves %d/6" % [s.coins, s.inventory.size(), s.capacity, game.domain.shelves(s)], body, 14, MINT)
	if help_open:
		var help: VBoxContainer = card()
		label("Your first shop visit", help, 19, GOLD)
		label("Stock practice objects and start a customer wave. Offer one shelf object, then confirm the stated net proceeds or skip. At the yard, choose two clues and a bid ceiling. Passing is permanent and free; accepted bids bind until you are outbid. Winners receive all six objects. Appraise before listing.", help)
		label("Everything pauses for your decisions. Every change saves before it is acknowledged. Tab/arrow keys move focus; Enter/Space activates buttons. Sorting's accessible skip pays 40. This early prototype repeats the same six-object fixture; art and the full catalog are still in development.", help, 14, MUTED)
	label(s.notice, body, 15, CREAM)
	if game.error != "":
		label(game.error, body, 15, GOLD)
	match s.screen:
		"shop": shop(s)
		"inspect", "auction": auction(s)
		"reveal": reveal(s)
		"result":
			label("A good decision can be walking away.", body, 22, GOLD)
			auction_log(s.lot.auction)
			action("Return to shop", "return_shop")
		"customers": customers(s)
		"receipt":
			label("The shop is quiet again", body, 22, GOLD)
			label("Completed shop sessions: %d" % s.shop_sessions, body)
			receipts(s)
			action("Return to shop", "return_shop")
	label("Saved locally · Prototype 0.1 · No background income", body, 12, MUTED)
	apply_focus.call_deferred()

func label(text: String, parent: Node, size: int = 15, color: Color = CREAM) -> Label:
	var node := Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_font_size_override("font_size", int(size * (1.3 if large_text else 1.0)))
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

func button(text: String, callback: Callable, parent: Node, disabled: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 44
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.disabled = disabled
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

func action(text: String, kind: String, args: Dictionary = {}, parent: Node = null, disabled: bool = false) -> Button:
	return button(text, func(): dispatch(kind, args), body if parent == null else parent, disabled)

func dispatch(kind: String, args: Dictionary) -> void:
	if busy:
		return
	busy = true
	restore_scroll = scroll.scroll_vertical
	var focus: Control = get_viewport().gui_get_focus_owner()
	restore_focus = focus.text if focus is Button else ""
	perform.call_deferred(kind, args)

func perform(kind: String, args: Dictionary) -> void:
	game.command(kind, args)
	busy = false
	render()

func apply_focus() -> void:
	if not is_instance_valid(scroll):
		return
	scroll.scroll_vertical = int(restore_scroll)
	for node in body.find_children("*", "Button", true, false):
		if not node.disabled and node.text == restore_focus:
			node.grab_focus()
			return

func card() -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", box(Color("203634")))
	body.add_child(panel)
	var content := VBoxContainer.new()
	panel.add_child(content)
	return content

func world(yard: bool) -> void:
	var container := TextureRect.new()
	container.custom_minimum_size = Vector2(0, 180)
	container.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	container.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 108)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	container.texture = viewport.get_texture()
	var picture := World.new()
	picture.yard = yard
	viewport.add_child(picture)

func shop(s: Dictionary) -> void:
	world(false)
	label("Your harbor shop", body, 22, GOLD)
	var row := HBoxContainer.new()
	body.add_child(row)
	action("Auction yard", "visit_lot", {}, row, s.coins < 80 or int(s.capacity) - s.inventory.size() < 6)
	action("Open shop", "customers", {}, row)
	if s.coins < 80 or int(s.capacity) - s.inventory.size() < 6:
		label("Yard needs 80 coins and six free stock slots. Sell stock or sort to recover; 160 coins gives more bidding room.", body, 14, MUTED)
	var tools := HBoxContainer.new()
	body.add_child(tools)
	action("Appraise all", "appraise", {}, tools)
	action("Sort · +40", "commission", {}, tools)
	if s.rack_count < 2:
		var cost: int = 120 if int(s.rack_count) == 0 else 180
		action("Add 6 stock slots · %d coins" % cost, "rack", {}, null, int(s.coins) < cost)
	label("Stock & shelves", body, 20, GOLD)
	for item in s.inventory:
		inventory_card(item)
	if s.inventory.is_empty():
		label("Empty shelves are okay. A sorting commission can fund your next lot.", body)
	if not s.discoveries.is_empty():
		var index: VBoxContainer = card()
		label("Collection notebook · %d / 6 prototype objects" % s.discoveries.size(), index, 18, GOLD)
		for id in s.discoveries:
			label(game.domain.catalog.definition(id).name, index, 14, MUTED)
	receipts(s)

func inventory_card(item: Dictionary) -> void:
	var panel: VBoxContainer = card()
	var definition: Dictionary = game.domain.catalog.definition(item.definition_id)
	label(definition.name if item.verified else "Unidentified consignment object", panel, 18, CREAM)
	if not item.verified:
		label("Appraise all to verify identity and reference value.", panel, 14, MUTED)
		return
	var reference: int = Value.reference_value(item)
	var condition: String = "Excellent" if int(item.condition) == 10000 else ("Good" if int(item.condition) == 8500 else "Worn")
	label("%s · %s · Reference %d" % [definition.category.capitalize(), condition, reference], panel, 14, MUTED)
	var price_row := HBoxContainer.new()
	panel.add_child(price_row)
	label("Ask", price_row, 14)
	var price := SpinBox.new()
	price.min_value = 1
	price.max_value = 100000
	price.step = 1
	price.value = int(item.ask) if int(item.ask) > 0 else maxi(5, Value.rounded(reference, 5) * 5)
	price.custom_minimum_size = Vector2(95, 44)
	price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_row.add_child(price)
	button("Set", func(): dispatch("price", {"uid": item.uid, "amount": int(price.value)}), price_row)
	var row := HBoxContainer.new()
	panel.add_child(row)
	action("Unstock" if item.shelf else "Stock shelf", "stock", {"uid": item.uid}, row, not item.shelf and game.domain.shelves(game.state) >= 6)
	var dealer: int = Value.rounded(reference * int(game.domain.config.dealer_bp))
	action("Sell to dealer · %d net" % dealer, "dealer", {"uid": item.uid}, row)

func auction(s: Dictionary) -> void:
	var a: Dictionary = s.lot.auction
	world(true)
	label("Harbor clearance yard", body, 22, GOLD)
	label("Household clearance · 3 exposed + 3 covered\nFixed opening: 40 · No entry or transfer fee", body, 14, MUTED)
	label("Visible: kettle shape, folding seat, metal fan. Covered: a tool crate, wrapped carton, flat package. Three homewares guaranteed. Hidden identities and values stay unknown until purchase.", body)
	if s.screen == "inspect":
		label("Notebook · %d/2 close inspections" % s.lot.inspections.size(), body, 18, GOLD)
		var targets: Array = ["Kettle · maker mark", "Folding seat · condition", "Fan · material", "Covered crate · packing label"]
		for target in range(4):
			var seen: bool = target in s.lot.inspections
			action(("Read again: " if seen else "Inspect: ") + targets[target], "inspect", {"target": target}, null, not seen and s.lot.inspections.size() == 2)
			if seen:
				label(game.domain.catalog.data.items[target].clue, body, 14, MINT)
		var ceiling_row := HBoxContainer.new()
		body.add_child(ceiling_row)
		var ceiling := SpinBox.new()
		ceiling.min_value = 40
		ceiling.max_value = int(a.limits.player)
		ceiling.value = int(a.limits.player)
		ceiling.custom_minimum_size = Vector2(100, 44)
		ceiling_row.add_child(ceiling)
		button("Tighten ceiling", func(): dispatch("ceiling", {"amount": int(ceiling.value)}), ceiling_row)
	label("Bid %d · Leader: %s\nYour ceiling %d · Reserve at least 40" % [a.bid, "None" if a.leader == "" else str(a.leader).capitalize(), a.limits.player], body, 17, GOLD)
	if int(a.bid) > 0:
		label("If you win at the current bid: %d coins remain." % (int(s.coins) - int(a.bid)), body, 14, MUTED)
	for rival in game.domain.catalog.data.rivals:
		label("%s · %s · %s" % [rival.name, rival.trait, "Active" if rival.id in a.active else "Passed out"], body, 13, MUTED)
	if int(a.bid) == 0:
		action("Bid 40 · binding if you win", "bid", {"amount": 40})
	else:
		for step in [10, 20, 40]:
			var amount: int = int(a.bid) + step
			action("Raise +%d · total %d%s" % [step, amount, " (above ceiling)" if amount > int(a.limits.player) else ""], "bid", {"amount": amount}, null, amount > int(a.limits.player))
	action("Leave freely" if int(a.bid) == 0 else "Pass out permanently · no charge", "pass")
	auction_log(a)

func auction_log(a: Dictionary) -> void:
	var panel: VBoxContainer = card()
	label("Bid ledger", panel, 17, GOLD)
	if a.log.is_empty():
		label("No bids yet. The opening never reveals hidden value.", panel, 14, MUTED)
	for entry in a.log.slice(maxi(0, a.log.size() - 10)):
		label(entry, panel, 14, MUTED)

func reveal(s: Dictionary) -> void:
	label("A new home for six objects", body, 22, GOLD)
	label("The bid was debited once and all six items are in stock. Full inspection is free. Collection knowledge survives selling.", body)
	var verified: bool = true
	for item in s.lot.items:
		var owned: Dictionary = game.domain.owned(s, item.uid)
		if not owned.verified:
			verified = false
		var panel: VBoxContainer = card()
		label(game.domain.catalog.definition(item.definition_id).name if owned.verified else "Wrapped object · awaiting appraisal", panel, 18)
		if owned.verified:
			label("Reference %d · Paid cost share %d" % [Value.reference_value(item), item.cost], panel, 14, MUTED)
	if not verified:
		action("Appraise all six · free", "appraise")
	action("Return to shop", "return_shop")

func customers(s: Dictionary) -> void:
	var customer: Dictionary = game.domain.catalog.data.customers[int(s.visitor)]
	var visit: Dictionary = s.visits[int(s.visitor)]
	label("Visitor %d / 6 · %s" % [int(s.visitor) + 1, customer.name], body, 22, GOLD)
	label("Looking for: %s\nBudget band: %s" % ["a bargain" if customer.preferences.is_empty() else ", ".join(customer.preferences), "modest (60–100)" if int(visit.budget) <= 100 else "comfortable (160–300)"], body, 15, MUTED)
	if not visit.offer.is_empty():
		var offer: Dictionary = visit.offer
		var panel: VBoxContainer = card()
		label(game.domain.catalog.definition(game.domain.owned(s, offer.uid).definition_id).name, panel, 20, GOLD)
		label("Gross %d − handling %d = %d net" % [offer.gross, offer.fee, int(offer.gross) - int(offer.fee)], panel, 17, MINT)
		action("Confirm sale · receive %d" % (int(offer.gross) - int(offer.fee)), "accept", {}, panel)
	else:
		var found: bool = false
		for item in s.inventory:
			if item.shelf:
				found = true
				action("Offer %s · ask %d" % [game.domain.catalog.definition(item.definition_id).name, item.ask], "offer", {"uid": item.uid})
		if not found:
			label("No objects on sale shelves. You may skip every visitor and return to stock your shop.", body)
	action("Decline / skip visitor · no penalty", "skip")

func receipts(s: Dictionary) -> void:
	if s.receipts.is_empty():
		return
	var panel: VBoxContainer = card()
	label("Recent receipts", panel, 18, GOLD)
	for receipt in s.receipts.slice(maxi(0, s.receipts.size() - 5)):
		if receipt.kind == "sale":
			label("%s · %d gross − %d fee = %d net" % [receipt.buyer, receipt.gross, receipt.fee, receipt.net], panel, 14, MUTED)
		else:
			label("%s · %s · bid %d" % [receipt.lot_id, str(receipt.winner).capitalize(), receipt.bid], panel, 14, MUTED)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Every acknowledged command is already durable; no quit-time economy.
		get_tree().quit()

func smoke_capture() -> void:
	await capture("shop-preview")
	scroll.scroll_vertical = 1000
	await capture("stock-preview")
	game.command("visit_lot")
	game.command("inspect", {"target": 0})
	game.command("inspect", {"target": 3})
	restore_scroll = 0
	render()
	await capture("auction-preview")
	var turns: int = 0
	while game.state.screen in ["inspect", "auction"] and turns < 50:
		var a: Dictionary = game.state.lot.auction
		game.command("bid", {"amount": 40 if int(a.bid) == 0 else int(a.bid) + 10})
		turns += 1
	game.command("appraise")
	render()
	await capture("reveal-preview")
	game.command("return_shop")
	game.command("stock", {"uid": "starter-0"})
	game.command("customers")
	game.command("offer", {"uid": "starter-0"})
	render()
	await capture("customer-preview")
	game.command("accept")
	for _visitor in range(5):
		game.command("skip")
	render()
	await capture("receipt-preview")
	game.command("return_shop")
	large_text = true
	render()
	await capture("large-text-preview")
	print("UI_SMOKE: shop, stock, auction, reveal, customer, receipt, large text")
	get_tree().quit()

func capture(name: String) -> void:
	for _frame in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: String = ProjectSettings.globalize_path("res://build/%s.png" % name)
	get_viewport().get_texture().get_image().save_png(path)
	print("UI_SMOKE_CAPTURE:", path)
