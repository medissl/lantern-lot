extends Node2D

var uid := ""
var definition_id := ""
var public_label := "Covered package"
var selected := false
var sprite := Sprite2D.new()
var movement: Tween
var visual_offset := Vector2.ZERO
var destination := Vector2(INF,INF)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = Vector2(-12, -22)
	add_child(sprite)

func bind_public(id: String, label: String, texture_path: String) -> void:
	uid = id
	public_label = label
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
	else:
		push_error("Missing required item art: " + texture_path)
	queue_redraw()

func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()

func settle_at(target: Vector2, instant := false) -> void:
	if target == destination and not instant:
		return
	destination = target
	if movement and movement.is_running():
		movement.kill()
	if instant or position == Vector2.ZERO:
		position = target
	else:
		movement = create_tween()
		movement.tween_property(self, "position", target, 0.25)

func _draw() -> void:
	if not selected:
		return
	var color := Color("fff1d6")
	for raw_corner in [Vector2(-13,-24), Vector2(13,-24), Vector2(-13,2), Vector2(13,2)]:
		var corner: Vector2 = raw_corner + visual_offset
		var x_direction := 1 if raw_corner.x < 0 else -1
		var y_direction := 1 if raw_corner.y < 0 else -1
		draw_line(corner, corner + Vector2(5*x_direction,0), color, 1)
		draw_line(corner, corner + Vector2(0,5*y_direction), color, 1)

func _process(_delta: float) -> void:
	sprite.position = Vector2(-12,-22) + visual_offset + position.round() - position
