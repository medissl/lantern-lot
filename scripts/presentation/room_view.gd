extends Node2D

const ItemView = preload("res://scripts/presentation/item_view.gd")
const ActorView = preload("res://scripts/presentation/actor_view.gd")
const Layout = preload("res://scripts/presentation/layout_controller.gd")
const ROOM_BOUNDS := Rect2(0, 0, 208, 288)
const SHELF_SOCKETS := [Vector2(32,72),Vector2(176,72),Vector2(32,136),Vector2(176,136),Vector2(32,200),Vector2(176,200)]
const LOT_SOCKETS := [Vector2(47,88),Vector2(105,88),Vector2(160,88),Vector2(47,136),Vector2(105,136),Vector2(160,136)]
const INSPECT_LABELS := ["Kettle maker mark", "Stool condition", "Fan material", "Covered crate packing label"]
@export var room_kind := "shop"
var room_bounds := ROOM_BOUNDS
var background := Sprite2D.new()
var ground := TileMapLayer.new()
var depth := Node2D.new()
var player: Node2D
var items: Dictionary = {}
var actors: Dictionary = {}
var fixtures: Dictionary = {}
var decorations: Dictionary = {}
var shelf_mapping: Dictionary = {}
var targets: Array = []
var selected_key := ""
var navigation := AStarGrid2D.new()
var last_state: Dictionary = {}
var reduced_motion := false
var public_reactions: Array[String] = []
var reaction_delay := 0.0
var reaction_step := 0.35
var current_layout: Dictionary = {}
var inspected_indices: Array = []
var layout_overlay := Node2D.new()
var layout_preview_enabled := false
var layout_preview_id := ""
var layout_preview_cell := Vector2i.ZERO
var layout_preview_valid := true
var effects := Node2D.new()
var departing_actors: Array[Node2D] = []
var presentation_tweens: Array[Tween] = []
var removed_positions: Dictionary = {}
var last_presented_revision := -1
var last_depth_probe := Vector2(INF,INF)
var opened_packages: Dictionary = {}
var fixture_animations: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.name = "Ground"
	ground.position = Vector2(8,32)
	ground.z_index = -25
	ground.tile_set = load("res://resources/visuals/room_tileset.tres")
	add_child(ground)
	for row in range(16):
		for col in range(12):
			ground.set_cell(Vector2i(col,row),(col*7+row*11)%6,Vector2i.ZERO)
	background.centered = false
	background.z_index = -20
	add_child(background)
	depth.y_sort_enabled = true
	add_child(depth)
	layout_overlay.z_index = 40
	layout_overlay.draw.connect(_draw_layout_overlay)
	add_child(layout_overlay)
	effects.z_index = 30
	add_child(effects)
	player = ActorView.new()
	player.actor_id = "shopkeeper"
	player.position = Vector2(104,224)
	depth.add_child(player)
	configure_room()

func configure_room() -> void:
	skip_reactions()
	opened_packages.clear()
	last_depth_probe = Vector2(INF,INF)
	if player:
		player.position = Vector2(104,224) if room_kind == "shop" else Vector2(104,252)
		player.waypoints.clear()
	var environment := "shop" if room_kind == "shop" else "yard"
	var path := "res://assets/pixel/environments/%s_architecture.png" % environment
	if ResourceLoader.exists(path):
		background.texture = load(path)
	for fixture in fixtures.values():
		fixture.queue_free()
	fixtures.clear()
	if room_kind == "shop":
		for index in range(6):
			add_fixture("shelf%d" % index, "shelf", shelf_positions()[index]+Vector2(0,25))
		add_fixture("bench", "bench", Vector2(152,50))
		add_fixture("counter", "counter", Vector2(43,262))
		add_fixture("tray", "tray", Vector2(165,256))
	else:
		add_fixture("shutter", "shutter", Vector2(104,60))
		if room_kind == "reveal":
			var shutter: Sprite2D = fixtures.shutter.get_child(0)
			shutter.region_enabled = true
			shutter.region_rect = Rect2(0,0,96,20)
		add_fixture("cart", "cart", Vector2(169,259))
		for index in range(3,6):
			add_fixture("package%d" % index, "crate" if index == 3 else "parcel", LOT_SOCKETS[index]-Vector2(0,1))
	build_navigation()
	layout_overlay.queue_redraw()

func add_fixture(id: String, art: String, foot: Vector2) -> void:
	var node := Node2D.new()
	node.position = foot
	var sprite := Sprite2D.new()
	var path := "res://assets/pixel/furniture/%s.png" % art
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
		sprite.centered = false
		sprite.position = Vector2(-sprite.texture.get_width()/2.0, -sprite.texture.get_height()+2)
	node.add_child(sprite)
	if art == "shelf" and sprite.texture:
		# A clipped upper cabinet can recede around the player; its solid base keeps
		# contact/depth readable rather than fading an entire piece of furniture.
		var upper := Sprite2D.new()
		upper.name = "UpperCutaway"
		upper.texture = sprite.texture
		upper.centered = false
		upper.position = sprite.position
		upper.region_enabled = true
		upper.region_rect = Rect2(0,0,64,32)
		node.add_child(upper)
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0,32,64,16)
		sprite.position.y += 32
	depth.add_child(node)
	fixtures[id] = node

func sync(state: Dictionary, catalog_data: Dictionary, layout: Dictionary = {}, motion_reduced := false) -> void:
	if not is_inside_tree():
		return
	reduced_motion = motion_reduced
	player.reduced_motion = reduced_motion
	var desired := "shop" if str(state.get("screen","shop")) in ["shop","customers","receipt"] else ("reveal" if state.get("screen") == "reveal" else "yard")
	if desired != room_kind:
		room_kind = desired
		configure_room()
		last_state = {}
		targets.clear()
	targets = []
	removed_positions.clear()
	var shown: Array = []
	if room_kind == "shop":
		if current_layout != layout:
			current_layout = layout.duplicate(true)
			last_depth_probe = Vector2(INF,INF)
			for index in range(6):
				fixtures["shelf%d" % index].position = shelf_positions()[index]+Vector2(0,25)
			build_navigation()
		bind_shop(state,catalog_data,shown,layout)
	else:
		bind_lot(state,catalog_data,shown)
	for key in items.keys():
		if key not in shown:
			removed_positions[key] = items[key].position + items[key].visual_offset
			items[key].queue_free()
			items.erase(key)
	bind_actors(state,catalog_data)
	select(selected_key)
	last_state = state.duplicate(true)
	if reduced_motion:
		skip_reactions()
	queue_redraw()

func bind_shop(state: Dictionary, catalog: Dictionary, shown: Array, layout: Dictionary) -> void:
	for index in range(2):
		var key := "stock_upgrade%d" % index
		if int(state.get("rack_count",0)) > index:
			if not fixtures.has(key):
				add_fixture(key,"stock_bundle",Vector2(134 if index == 0 else 196,256))
				fixtures[key].get_child(0).position.y -= 20
		elif fixtures.has(key):
			fixtures[key].queue_free()
			fixtures.erase(key)
	var inventory: Array = state.get("inventory",[])
	var shelved: Array = []
	var unstocked: Array = []
	for item in inventory:
		(shelved if item.get("shelf",false) else unstocked).append(item)
	for uid in shelf_mapping.keys():
		var remains := false
		for item in shelved:
			if str(item.uid) == uid:
				remains = true
		if not remains:
			shelf_mapping.erase(uid)
	var used_sockets: Array = []
	for uid in shelf_mapping.keys():
		var index := int(shelf_mapping[uid])
		if index < 0 or index >= 6 or index in used_sockets:
			shelf_mapping.erase(uid)
		else:
			used_sockets.append(index)
	for item in shelved:
		var uid := str(item.uid)
		if not shelf_mapping.has(uid):
			for index in range(6):
				if index not in shelf_mapping.values():
					shelf_mapping[uid] = index
					break
		bind_item(item, definition_label(item,catalog), shelf_positions()[int(shelf_mapping[uid])], shown,false,Vector2(0,25))
	for index in range(mini(3,unstocked.size())):
		bind_item(unstocked[index], definition_label(unstocked[index],catalog), Vector2(145+20*index,243), shown,false,Vector2(0,13))
	targets.append(hit("bench","Appraise all · free",Vector2(152,39),16))
	targets.append(hit("counter","Open shop",Vector2(43,250),21))
	targets.append(hit("door","Visit auction yard",Vector2(104,269),18))
	if unstocked.size() > 3:
		targets.append(hit("stock","Stock drawer · %d objects" % unstocked.size(),Vector2(164,251),22))
	for id in decorations.keys():
		decorations[id].visible = false
	for id in layout.get("placements",{}):
		var placement: Dictionary = layout.placements[id]
		if not decorations.has(id):
			var node := Sprite2D.new()
			var path := "res://assets/pixel/decor/%s.png" % id
			if ResourceLoader.exists(path):
				node.texture = load(path)
			node.centered = false
			depth.add_child(node)
			decorations[id] = node
		var decor: Sprite2D = decorations[id]
		decor.visible = true
		var foot := Vector2(24+32*int(placement.get("col",0)),56+32*int(placement.get("row",0)))
		decor.position = foot
		decor.offset = -Vector2(decor.texture.get_width()/2.0,decor.texture.get_height()) if decor.texture else Vector2.ZERO
		decor.z_index = -1 if id == "rug" else 0

func bind_lot(state: Dictionary, catalog: Dictionary, shown: Array) -> void:
	for decor in decorations.values():
		decor.visible = false
	var lot: Dictionary = state.get("lot",{})
	inspected_indices = lot.get("inspections",[]).duplicate()
	var lot_items: Array = lot.get("items",[])
	for index in range(mini(6,lot_items.size())):
		var item: Dictionary = lot_items[index].duplicate(true)
		# Reveal reads verified owned instance; auction data may retain its unverified copy.
		if room_kind == "reveal":
			for owned in state.get("inventory",[]):
				if owned.uid == item.uid:
					item = owned
		var exposed := index < 3 or bool(item.get("verified",false))
		var label: String = definition_label(item,catalog) if bool(item.get("verified",false)) else (["Exposed kettle","Exposed stool","Exposed fan"][index] if index < 3 else "Covered package")
		bind_item(item,label,LOT_SOCKETS[index],shown,exposed)
		if opened_packages.has(str(item.uid)) and not bool(item.get("verified",false)):
			items[str(item.uid)].sprite.visible = false
		if room_kind == "reveal":
			targets.append(hit(str(item.uid),label,LOT_SOCKETS[index]-Vector2(0,10),16))
	if room_kind != "reveal":
		for index in range(4):
			var checked: bool = index in lot.get("inspections",[])
			targets.append(hit("inspect:%d" % index,INSPECT_LABELS[index]+(" · read clue" if checked else ""),LOT_SOCKETS[index]-Vector2(0,10),17))
	else:
		targets.append(hit("bench","Appraise all · free",Vector2(104,174),18))
		targets.append(hit("door","Return to shop",Vector2(104,269),18))

func bind_item(item: Dictionary, label: String, foot: Vector2, shown: Array, exposed := false, sort_offset := Vector2.ZERO) -> void:
	var uid := str(item.uid)
	shown.append(uid)
	if not items.has(uid):
		var node := ItemView.new()
		depth.add_child(node)
		items[uid] = node
	var view: Node2D = items[uid]
	var visible_identity := bool(item.get("verified",false)) or exposed
	var texture_path := "res://assets/pixel/goods/%s.png" % str(item.definition_id) if visible_identity else "res://assets/pixel/goods/covered.png"
	view.bind_public(uid,label,texture_path)
	view.sprite.visible = true
	view.visual_offset = -sort_offset
	# Goods share the fixture's floor contact, with their art at its shelf surface.
	# Put tied goods after fixtures even when returning with existing item nodes.
	depth.move_child(view,depth.get_child_count()-1)
	view.settle_at(foot+sort_offset,reduced_motion or last_state.is_empty())
	if room_kind == "shop":
		targets.append(hit(uid,label,foot-Vector2(0,10),16))

func set_layout_preview(enabled: bool, selected_id: String = "", col: int = 0, row: int = 0, valid: bool = true) -> void:
	layout_preview_enabled = enabled
	layout_preview_id = selected_id
	layout_preview_cell = Vector2i(col,row)
	layout_preview_valid = valid
	layout_overlay.queue_redraw()

func _draw_layout_overlay() -> void:
	if not layout_preview_enabled or room_kind != "shop":
		return
	var ink := Color("282522",0.6)
	for col in range(7):
		layout_overlay.draw_line(Vector2(8+32*col,24),Vector2(8+32*col,280),ink)
	for row in range(9):
		layout_overlay.draw_line(Vector2(8,24+32*row),Vector2(200,24+32*row),ink)
	var aisle := Rect2(88,24,32,256)
	layout_overlay.draw_rect(aisle,Color("245b59",0.13))
	for y in range(24,276,8):
		layout_overlay.draw_line(Vector2(88,y),Vector2(120,mini(y+24,280)),Color("245b59",0.45))
	if layout_preview_id.is_empty():
		return
	var footprint := Rect2(Vector2(8,24)+Vector2(layout_preview_cell)*32,Vector2(32,32))
	var color := Color("245b59") if layout_preview_valid else Color("b94f3b")
	layout_overlay.draw_rect(footprint,Color(color,0.25))
	layout_overlay.draw_rect(footprint,color,false,2)
	var center := footprint.get_center()
	if layout_preview_valid:
		layout_overlay.draw_line(center+Vector2(-7,0),center+Vector2(-2,5),Color("fff1d6"),2)
		layout_overlay.draw_line(center+Vector2(-2,5),center+Vector2(8,-7),Color("fff1d6"),2)
	else:
		layout_overlay.draw_line(center-Vector2(7,7),center+Vector2(7,7),Color("fff1d6"),2)
		layout_overlay.draw_line(center+Vector2(-7,7),center+Vector2(7,-7),Color("fff1d6"),2)

func definition_label(item: Dictionary, catalog: Dictionary) -> String:
	if not item.get("verified",false):
		return "Covered stock object"
	for definition in catalog.get("items",[]) + catalog.get("starters",[]):
		if definition.id == item.definition_id:
			return str(definition.name)
	return "Identified object"

func bind_actors(state: Dictionary, catalog: Dictionary) -> void:
	for index in range(departing_actors.size()-1,-1,-1):
		if not is_instance_valid(departing_actors[index]):
			departing_actors.remove_at(index)
	for index in range(presentation_tweens.size()-1,-1,-1):
		if not presentation_tweens[index].is_running():
			presentation_tweens.remove_at(index)
	var visible_ids: Array = []
	if room_kind != "shop":
		ensure_actor("auctioneer",Vector2(104,184),visible_ids)
		for index in range(catalog.get("rivals",[]).size()):
			ensure_actor(str(catalog.rivals[index].id),Vector2(43+60*index,215),visible_ids)
		var auction: Dictionary = state.get("lot",{}).get("auction",{})
		var old_log: Array = last_state.get("lot",{}).get("auction",{}).get("log",[])
		var auction_log: Array = auction.get("log",[])
		if not last_state.is_empty():
			for index in range(old_log.size(),auction_log.size()):
				public_reactions.append(str(auction_log[index]))
			if not public_reactions.is_empty():
				reaction_step = minf(0.35,0.7/public_reactions.size())
				if auction_log.size() > old_log.size():
					reaction_delay = 0
	else:
		if state.get("screen") == "customers" and int(state.get("visitor",0)) < state.get("visits",[]).size():
			var visitor := int(state.visitor)
			var id := str(state.visits[visitor].id)
			var browse := browse_destination(state,visitor)
			var stand: Vector2 = browse.position
			ensure_actor(id,stand,visible_ids)
			if not last_state.is_empty() and int(last_state.get("visitor",-1)) != visitor:
				actors[id].position = Vector2(104,266)
				actors[id].walk_for_action(path_to(actors[id].position,stand),"browse",browse.facing)
			elif actors[id].waypoints.is_empty():
				actors[id].facing = str(browse.facing)
				if not reduced_motion and actors[id].reaction_seconds <= 0:
					actors[id].react("browse",1.0)
			for index in range(visitor+1,mini(visitor+3,state.visits.size())):
				ensure_actor(str(state.visits[index].id),Vector2(89+25*(index-visitor),274),visible_ids)
	for id in actors.keys():
		if id not in visible_ids:
			var departing: Node2D = actors[id]
			if not reduced_motion and room_kind == "shop" and not last_state.is_empty():
				# A skipped visitor leaves empty handed. Bags follow an actual sale diff.
				var sale_committed: bool = state.get("inventory",[]).size() < last_state.get("inventory",[]).size() and int(state.get("coins",0)) > int(last_state.get("coins",0))
				if sale_committed:
					departing.react("carry")
				departing_actors.append(departing)
				var tween := create_tween()
				presentation_tweens.append(tween)
				tween.tween_property(departing,"position",Vector2(104,300),0.7)
				tween.tween_callback(departing.queue_free)
			else:
				departing.queue_free()
			actors.erase(id)

func browse_destination(state: Dictionary, visitor: int) -> Dictionary:
	var uid := str(state.visits[visitor].get("offer",{}).get("uid",""))
	if uid.is_empty():
		for item in state.get("inventory",[]):
			if item.get("shelf",false):
				uid = str(item.uid)
				break
	if shelf_mapping.has(uid):
		var slot := int(shelf_mapping[uid])
		var service: Vector2i = Layout.service_cells(current_layout)[slot+2]
		return {"position":Vector2(16,36)+Vector2(service)*16,"facing":"up"}
	return {"position":Vector2(125,150),"facing":"down"}

func ensure_actor(id: String, foot: Vector2, visible_ids: Array) -> void:
	visible_ids.append(id)
	if not actors.has(id):
		var actor := ActorView.new()
		actor.actor_id = id
		actor.position = foot
		depth.add_child(actor)
		actors[id] = actor
	actors[id].reduced_motion = reduced_motion

func select(key: String) -> void:
	selected_key = key
	for uid in items:
		items[uid].set_selected(uid == key)
	if key.begins_with("inspect:"):
		var index := int(key.get_slice(":",1))
		if index >= 0 and index < 4:
			for item in items.values():
				if item.position == LOT_SOCKETS[index]:
					item.set_selected(true)

func public_hit_targets() -> Array:
	return targets.duplicate(true)

func shelf_positions() -> Array:
	return Layout.fixture_positions(current_layout)

func hit(id: String,label: String,point: Vector2,radius: float) -> Dictionary:
	return {"id":id,"label":label,"world_position":point,"radius":radius}

func build_navigation() -> void:
	navigation.region = Rect2i(0,0,12,16)
	navigation.cell_size = Vector2(16,16)
	navigation.offset = Vector2(16,32)
	navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	navigation.update()
	if room_kind == "shop":
		var blocked: Dictionary = Layout.navigation_blockers(current_layout if not current_layout.is_empty() else Layout.defaults())
		for cell in blocked:
			navigation.set_point_solid(cell,true)
	else:
		for y in range(2,8):
			for x in range(12):
				if x < 4 or x >= 8:
					navigation.set_point_solid(Vector2i(x,y),true)

func path_to(start: Vector2,target: Vector2) -> PackedVector2Array:
	var from := Vector2i(clampi(int((start.x-8)/16),0,11),clampi(int((start.y-24)/16),0,15))
	var to := Vector2i(clampi(int((target.x-8)/16),0,11),clampi(int((target.y-24)/16),0,15))
	if navigation.is_point_solid(to):
		return PackedVector2Array()
	return navigation.get_point_path(from,to)

func move_player(world_position: Vector2) -> void:
	player.walk_path(path_to(player.position,world_position))

func present_commit(kind: String, args: Dictionary, before: Dictionary, after: Dictionary) -> void:
	var revision := int(after.get("revision",-1))
	if revision <= int(before.get("revision",-1)) or revision == last_presented_revision:
		return
	last_presented_revision = revision
	if reduced_motion:
		skip_reactions()
		return
	if after.get("screen") == "reveal" and before.get("screen") != "reveal":
		play_fixture_sequence("shutter","shutter_open",Vector2(96,64))
	match kind:
		"stock":
			var uid := str(args.get("uid",""))
			if items.has(uid):
				var view: Node2D = items[uid]
				var stand: Vector2 = view.destination + Vector2(32 if view.destination.x < 104 else -32,16)
				player.walk_for_action(path_to(player.position,stand),"interact")
				for item in after.get("inventory",[]):
					if str(item.uid) == uid and item.get("verified",false):
						player.carry_item("res://assets/pixel/goods/%s.png" % str(item.definition_id),1.1)
		"appraise":
			var stand := Vector2(144,64) if room_kind == "shop" else Vector2(104,168)
			player.walk_for_action(path_to(player.position,stand),"interact")
			for item in after.get("inventory",[]):
				var uid := str(item.uid)
				if items.has(uid):
					var view: Node2D = items[uid]
					play_effect("reveal_accent",view.destination + view.visual_offset - Vector2(0,10))
		"accept":
			player.react("interact")
			play_effect("sold_accent",Vector2(43,230))
			var visits: Array = before.get("visits",[])
			var visitor := int(before.get("visitor",0))
			if visitor < visits.size():
				var uid := str(visits[visitor].get("offer",{}).get("uid",""))
				if removed_positions.has(uid):
					play_effect("sold_accent",removed_positions[uid]-Vector2(0,10))
		"return_shop":
			if before.get("screen") == "reveal":
				var cart := Sprite2D.new()
				cart.texture = load("res://assets/pixel/furniture/cart.png")
				cart.position = Vector2(104,270)
				effects.add_child(cart)
				var tween := create_tween()
				presentation_tweens.append(tween)
				tween.tween_method(func(point: Vector2): cart.position = point.round(),Vector2(104,270),Vector2(104,310),0.9)
				tween.tween_callback(cart.queue_free)
		"bid", "pass":
			# Public log reactions are enqueued by the committed snapshot diff.
			pass

func open_package(uid: String) -> bool:
	# Unpacking is a local view over an already committed owned lot object.
	# Neither this API nor its animation callback calls the economic boundary.
	if room_kind != "reveal" or last_state.get("screen") != "reveal":
		return false
	var owned := false
	for item in last_state.get("inventory",[]):
		if str(item.uid) == uid:
			owned = true
			break
	if not owned:
		return false
	var index := -1
	var lot_items: Array = last_state.get("lot",{}).get("items",[])
	for slot in range(lot_items.size()):
		if str(lot_items[slot].uid) == uid:
			index = slot
			break
	if index < 3 or index > 5:
		return false
	if opened_packages.has(uid):
		return true
	var fixture_id := "package%d" % index
	if not fixtures.has(fixture_id):
		return false
	opened_packages[uid] = true
	play_fixture_sequence(fixture_id,"crate_open",Vector2(32,32))
	for item in last_state.inventory:
		if str(item.uid) == uid and not item.get("verified",false) and items.has(uid):
			# The authored open crate contains neutral wrapping, never hidden identity.
			items[uid].sprite.visible = false
	return true

func play_fixture_sequence(fixture_id: String, effect_id: String, frame_size: Vector2) -> void:
	if not fixtures.has(fixture_id):
		return
	var fixture: Node2D = fixtures[fixture_id]
	var base: Sprite2D = fixture.get_child(0)
	var frames: SpriteFrames = load("res://assets/pixel/effects/%s.tres" % effect_id)
	base.texture = frames.get_frame_texture("default",frames.get_frame_count("default")-1)
	base.region_enabled = false
	base.position = Vector2(-frame_size.x/2,-frame_size.y+2)
	base.visible = true
	if reduced_motion:
		return
	var animation := AnimatedSprite2D.new()
	animation.sprite_frames = frames
	animation.centered = false
	animation.position = base.position
	fixture.add_child(animation)
	fixture_animations[fixture_id] = animation
	base.visible = false
	animation.animation_finished.connect(func():
		base.visible = true
		fixture_animations.erase(fixture_id)
		animation.queue_free()
	)
	animation.play("default")

func play_effect(id: String, point: Vector2) -> void:
	if reduced_motion or effects.get_child_count() >= 20:
		return
	var path := "res://assets/pixel/effects/%s.tres" % id
	if not ResourceLoader.exists(path):
		push_error("Missing committed effect: " + path)
		return
	var effect := AnimatedSprite2D.new()
	effect.sprite_frames = load(path)
	effect.position = point.round()
	effects.add_child(effect)
	effect.animation_finished.connect(effect.queue_free)
	effect.play("default")

func skip_reactions() -> void:
	public_reactions.clear()
	reaction_delay = 0
	if player:
		player.settle_reactions()
	for actor in actors.values():
		actor.settle_reactions()
	for tween in presentation_tweens:
		if tween and tween.is_running():
			tween.kill()
	presentation_tweens.clear()
	for actor in departing_actors:
		if is_instance_valid(actor):
			actor.queue_free()
	departing_actors.clear()
	for effect in effects.get_children():
		effect.queue_free()
	for key in fixture_animations:
		var animation: AnimatedSprite2D = fixture_animations[key]
		if is_instance_valid(animation):
			var fixture: Node2D = animation.get_parent()
			fixture.get_child(0).visible = true
			animation.queue_free()
	fixture_animations.clear()

func _process(delta: float) -> void:
	if player and player.position != last_depth_probe:
		last_depth_probe = player.position
		if room_kind == "shop":
			for index in range(6):
				var shelf: Node2D = fixtures.get("shelf%d" % index)
				if shelf and shelf.has_node("UpperCutaway"):
					var obstructed := absf(player.position.x-shelf.position.x) <= 32 and player.position.y < shelf.position.y and player.position.y >= shelf.position.y-44
					shelf.get_node("UpperCutaway").modulate.a = 0.38 if obstructed else 1.0
	reaction_delay -= delta
	while not public_reactions.is_empty() and reaction_delay <= 0:
		var line: String = public_reactions.pop_front()
		var id := line.get_slice(" ",0).to_lower()
		var actor: Node2D = player if id == "player" else actors.get(id)
		if actor:
			actor.react("bid" if "bid" in line else "interact")
		# Ordered cosmetic replay, bounded to .7s plus final .7s pose.
		reaction_delay += reaction_step if not reduced_motion else 0.0

func _draw() -> void:
	if room_kind == "shop":
		return
	for index in inspected_indices:
		if int(index) >= 0 and int(index) < 4:
			var point: Vector2 = LOT_SOCKETS[int(index)] + Vector2(12,-18)
			draw_line(point,point+Vector2(2,2),Color("245b59"),2)
			draw_line(point+Vector2(2,2),point+Vector2(6,-3),Color("245b59"),2)

