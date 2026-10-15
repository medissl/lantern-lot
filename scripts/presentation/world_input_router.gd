extends RefCounted

# One captured pointer; the controller feeds GUI-consumed events explicitly.
var pointer_id := -999
var origin := Vector2.ZERO
var previous := Vector2.ZERO
var panning := false
var threshold := 10.0

static func map_pointer(screen_position: Vector2, display_rect: Rect2, viewport_size: Vector2, canvas_transform: Transform2D) -> Variant:
	if display_rect.size.x <= 0 or display_rect.size.y <= 0 or not display_rect.has_point(screen_position):
		return null
	var viewport_point := (screen_position - display_rect.position) / display_rect.size * viewport_size
	return canvas_transform.affine_inverse() * viewport_point

func begin(id: int, point: Vector2) -> bool:
	if pointer_id != -999:
		return false
	pointer_id = id
	origin = point
	previous = point
	panning = false
	return true

func update(id: int, point: Vector2) -> Dictionary:
	if pointer_id != id:
		return {}
	if point.distance_to(origin) >= threshold:
		panning = true
	var change := point - previous
	previous = point
	return {"pan": panning, "delta": change if panning else Vector2.ZERO}

func finish(id: int, point: Vector2) -> Dictionary:
	if pointer_id != id:
		return {}
	var result := {"tap": not panning and point.distance_to(origin) < threshold, "position": point}
	cancel()
	return result

func cancel() -> void:
	pointer_id = -999
	panning = false
