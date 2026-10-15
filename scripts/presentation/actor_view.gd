extends Node2D

# Foot-origin actor. Motion is cosmetic and never invokes a domain command.
@export var actor_id := "shopkeeper"
var reduced_motion := false:
	set(value):
		reduced_motion = value
		if value and is_inside_tree():
			settle_reactions()
		elif is_inside_tree() and not sprite.is_playing():
			sprite.play("idle_" + facing if directional else "idle")
var waypoints: PackedVector2Array = []
var speed := 42.0
var sprite := AnimatedSprite2D.new()
var reaction_seconds := 0.0
var facing := "down"
var directional := false
var carried_sprite := Sprite2D.new()
var carry_seconds := 0.0
var after_walk := ""
var after_walk_facing := ""
const HAND_ANCHORS := {"down":Vector2(12,20),"left":Vector2(4,20),"right":Vector2(20,20),"up":Vector2(12,17)}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(-12, -28)
	sprite.centered = false
	add_child(sprite)
	carried_sprite.position = Vector2(-10,-24)
	carried_sprite.centered = false
	carried_sprite.visible = false
	add_child(carried_sprite)
	set_actor(actor_id)
	if reduced_motion:
		settle_reactions()

func set_actor(id: String) -> void:
	actor_id = id
	if not is_inside_tree():
		return
	var directional_path := "res://assets/pixel/actors/%s_directional.tres" % id
	if ResourceLoader.exists(directional_path):
		sprite.sprite_frames = load(directional_path)
		directional = true
		sprite.play("idle_down")
		return
	var path := "res://assets/pixel/actors/%s.png" % id
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var sequences := {"idle": [0, 1], "walk": [2, 3, 4, 5], "interact": [6, 7], "carry": [8, 9], "bid": [10, 11]}
	for animation in sequences:
		frames.add_animation(animation)
		frames.set_animation_speed(animation, 3.0 if animation == "idle" else 8.0)
		for index in sequences[animation]:
			var cel := AtlasTexture.new()
			cel.atlas = texture
			cel.region = Rect2(index * 24, 0, 24, 32)
			frames.add_frame(animation, cel)
	sprite.sprite_frames = frames
	sprite.play("idle")

func walk_path(path: PackedVector2Array) -> void:
	after_walk = ""
	after_walk_facing = ""
	waypoints = path
	if reduced_motion and not path.is_empty():
		position = path[path.size() - 1].round()
		waypoints.clear()

func walk_for_action(path: PackedVector2Array, animation: String, final_facing: String = "") -> void:
	walk_path(path)
	var length := 0.0
	var previous := position
	for point in path:
		length += point.distance_to(previous)
		previous = point
	speed = maxf(42.0,length/0.8)
	after_walk = animation
	after_walk_facing = final_facing
	if path.is_empty():
		if not final_facing.is_empty():
			facing = final_facing
		react(animation)
		after_walk = ""

func carry_item(texture_path: String, seconds := 1.0) -> void:
	if reduced_motion or not ResourceLoader.exists(texture_path):
		return
	carried_sprite.texture = load(texture_path)
	carried_sprite.visible = true
	carry_seconds = seconds

func settle_reactions() -> void:
	if not waypoints.is_empty():
		position = waypoints[waypoints.size()-1].round()
	waypoints.clear()
	after_walk = ""
	after_walk_facing = ""
	reaction_seconds = 0
	carry_seconds = 0
	carried_sprite.visible = false
	speed = 42.0
	sprite.stop()
	var idle := "idle_" + facing if directional else "idle"
	if sprite.sprite_frames.has_animation(idle):
		sprite.animation = idle
	sprite.frame = 0

func react(animation: String, seconds := 0.7) -> void:
	if reduced_motion:
		return
	reaction_seconds = seconds
	var sequence := animation
	if directional:
		sequence = ("handoff" if animation == "carry" else animation) + "_" + facing
	if sprite.sprite_frames.has_animation(sequence):
		sprite.play(sequence)

func _process(delta: float) -> void:
	# Logical movement is continuous; raster transform stays on whole art pixels.
	sprite.position = Vector2(-12,-28) + position.round() - position
	carried_sprite.position = HAND_ANCHORS[facing] - Vector2(12,28) - Vector2(12,22) + position.round() - position
	carried_sprite.z_index = -1 if facing == "up" else 1
	if reduced_motion:
		if sprite.is_playing():
			sprite.stop()
		return
	if carry_seconds > 0:
		carry_seconds -= delta
		if carry_seconds <= 0:
			carried_sprite.visible = false
	if reaction_seconds > 0:
		reaction_seconds -= delta
		if reaction_seconds <= 0:
			sprite.play("idle_" + facing if directional else "idle")
	if waypoints.is_empty():
		return
	var target := waypoints[0]
	var direction := target - position
	if absf(direction.x) > absf(direction.y):
		facing = "left" if direction.x < 0 else "right"
	else:
		facing = "up" if direction.y < 0 else "down"
	sprite.flip_h = direction.x < -0.1 and not directional
	position = position.move_toward(target, speed * delta)
	if position.distance_to(target) < 1:
		position = target.round()
		waypoints.remove_at(0)
		if waypoints.is_empty() and not after_walk.is_empty():
			var reaction := after_walk
			if not after_walk_facing.is_empty():
				facing = after_walk_facing
			after_walk = ""
			after_walk_facing = ""
			speed = 42
			react(reaction)
	if reaction_seconds <= 0:
		var sequence := "idle" if waypoints.is_empty() else "walk"
		if carry_seconds > 0 and directional:
			sequence = "carry_idle" if waypoints.is_empty() else "carry_walk"
		sprite.play(sequence + "_" + facing if directional else sequence)
