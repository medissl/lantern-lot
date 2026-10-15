extends RefCounted

# Placement grid origin (8,24); navigation cells are 16px, furnishing cells 32px.
const IDS := ["rug", "planter", "wall_clock", "harbor_print", "stool", "lamp"]
const FIXTURE_IDS := ["shelf0", "shelf1", "shelf2", "shelf3", "shelf4", "shelf5"]
const SHELF_CELLS := [Vector2i(0,1), Vector2i(5,1), Vector2i(0,3), Vector2i(5,3), Vector2i(0,5), Vector2i(5,5)]
const SHELF_POSITIONS := [Vector2(32,72), Vector2(176,72), Vector2(32,136), Vector2(176,136), Vector2(32,200), Vector2(176,200)]
const SERVICE_CELLS := [Vector2i(2,4), Vector2i(9,4), Vector2i(2,8), Vector2i(9,8), Vector2i(2,12), Vector2i(9,12), Vector2i(8,2), Vector2i(3,13)]
const FIXED_CELLS := [Vector2i(4,0), Vector2i(0,7), Vector2i(4,7), Vector2i(5,7)]
var draft: Dictionary = {}
var original: Dictionary = {}
var history: Array[Dictionary] = []

static func defaults() -> Dictionary:
	var fixtures: Dictionary = {}
	for index in range(6): fixtures[FIXTURE_IDS[index]] = {"col": SHELF_CELLS[index].x, "row": SHELF_CELLS[index].y}
	return {"placements": {"rug": {"col":2,"row":4}, "planter":{"col":1,"row":0}, "wall_clock":{"col":1,"row":0}, "harbor_print":{"col":4,"row":0}, "stool":{"col":4,"row":5}, "lamp":{"col":1,"row":5}}, "fixtures": fixtures}

static func migrate(layout: Dictionary) -> Dictionary:
	var result := layout.duplicate(true)
	if result.size() == 1 and result.get("placements") is Dictionary:
		result["fixtures"] = defaults().fixtures
	return result

static func fixture_positions(layout: Dictionary) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var fixtures: Dictionary = layout.get("fixtures", defaults().fixtures)
	for id in FIXTURE_IDS:
		var cell: Dictionary = fixtures.get(id, defaults().fixtures[id])
		positions.append(Vector2(clampf(24 + 32 * int(cell.col),32,176),40 + 32 * int(cell.row)))
	return positions

static func service_cells(layout: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = [Vector2i(8,2),Vector2i(3,13)]
	var fixtures: Dictionary = layout.get("fixtures", defaults().fixtures)
	for id in FIXTURE_IDS:
		var cell: Dictionary = fixtures[id]
		var col := int(cell.col)
		cells.append(Vector2i(col * 2 + 2 if col < 2 else col * 2 - 1, int(cell.row) * 2 + 2))
	return cells

static func wall_item(id: String) -> bool:
	return id in ["wall_clock", "harbor_print"]

static func fail(message: String) -> Dictionary:
	return {"ok":false,"message":message}

static func integral(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

static func position_valid(position: Variant) -> bool:
	return position is Dictionary and position.size() == 2 and integral(position.get("col")) and integral(position.get("row")) and int(position.col) >= 0 and int(position.col) < 6 and int(position.row) >= 0 and int(position.row) < 8

static func occupy(blocked: Dictionary, cell: Vector2i) -> void:
	for y in range(2):
		for x in range(2): blocked[cell * 2 + Vector2i(x,y)] = true

static func fixture_blockers(layout: Dictionary = {}) -> Dictionary:
	var blocked: Dictionary = {}
	for cell in FIXED_CELLS: occupy(blocked,cell)
	var fixtures: Dictionary = layout.get("fixtures", defaults().fixtures)
	for position in fixtures.values(): occupy(blocked,Vector2i(int(position.col),int(position.row)))
	return blocked

static func navigation_blockers(layout: Dictionary) -> Dictionary:
	var blocked := fixture_blockers(layout)
	for id in IDS:
		if wall_item(id) or id == "rug": continue
		var position: Dictionary = layout.get("placements",{}).get(id,{})
		if position_valid(position): occupy(blocked,Vector2i(int(position.col),int(position.row)))
	return blocked

static func validate(layout: Dictionary) -> Dictionary:
	if layout.size() != 2 or not layout.get("placements") is Dictionary or layout.placements.size() != IDS.size() or not layout.get("fixtures") is Dictionary or layout.fixtures.size() != 6:
		return fail("Layout needs six decorations and exactly six sale shelves.")
	var blocked: Dictionary = {}
	for cell in FIXED_CELLS: occupy(blocked,cell)
	for id in FIXTURE_IDS:
		var position: Variant = layout.fixtures.get(id)
		if not position_valid(position): return fail("Shelf placements need whole columns 0–5 and rows 0–7.")
		var cell := Vector2i(int(position.col),int(position.row))
		if cell.x not in [0,1,4,5]: return fail("Keep shelves beside the protected central aisle.")
		if cell.y == 7: return fail("Leave a reachable stand below every shelf.")
		for y in range(2):
			for x in range(2):
				if blocked.has(cell * 2 + Vector2i(x,y)): return fail("Shelves cannot overlap each other or fixed service furniture.")
		occupy(blocked,cell)
	var services := service_cells(layout)
	var walls: Dictionary = {}
	for id in IDS:
		var position: Variant = layout.placements.get(id)
		if not position_valid(position): return fail("Decorations need whole columns 0–5 and rows 0–7.")
		var cell := Vector2i(int(position.col),int(position.row))
		if wall_item(id):
			if cell.y != 0: return fail("Clock and harbor print use back-wall sockets (row 0).")
			if walls.has(cell): return fail("Wall decorations cannot share a socket.")
			walls[cell] = true
			continue
		if id == "rug": continue
		for y in range(2):
			for x in range(2):
				var nav: Vector2i = cell * 2 + Vector2i(x,y)
				if nav.x in [5,6] or nav in services: return fail("Keep the central aisle, entrance and service access clear.")
				if blocked.has(nav): return fail("Solid decorations cannot overlap fixtures or each other.")
		occupy(blocked,cell)
	var reachable: Dictionary = {Vector2i(5,15):true}
	var queue: Array[Vector2i] = [Vector2i(5,15)]
	var cursor := 0
	while cursor < queue.size():
		var current := queue[cursor]
		cursor += 1
		for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = current + delta
			if next.x >= 0 and next.x < 12 and next.y >= 0 and next.y < 16 and not blocked.has(next) and not reachable.has(next):
				reachable[next] = true
				queue.append(next)
	for service in services:
		if not reachable.has(service): return fail("Every shelf, checkout and appraisal stand must be reachable.")
	return {"ok":true,"message":"Layout valid. Entrance and all service paths stay clear."}

func begin(layout: Dictionary) -> void:
	var candidate := migrate(layout)
	original = (candidate if validate(candidate).ok else defaults()).duplicate(true)
	draft = original.duplicate(true)
	history.clear()

func place(id: String, col: int, row: int) -> Dictionary:
	if (not id in IDS and not id in FIXTURE_IDS) or draft.is_empty(): return fail("Choose a decoration or shelf while editing.")
	var next := draft.duplicate(true)
	var group := "fixtures" if id in FIXTURE_IDS else "placements"
	next[group][id] = {"col":col,"row":row}
	var result := validate(next)
	if result.ok and next != draft:
		history.append(draft.duplicate(true))
		if history.size() > 20: history.pop_front()
		draft = next
	return result

func undo() -> bool:
	if history.is_empty(): return false
	draft = history.pop_back()
	return true

func cancel() -> Dictionary:
	draft = original.duplicate(true)
	history.clear()
	return draft.duplicate(true)

