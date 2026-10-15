extends RefCounted

# This service never reads or writes economic snapshots.
const Layout = preload("res://scripts/presentation/layout_controller.gd")
const VERSION := 2
const MAX_BYTES := 65536
var directory: String
var error := ""
var recovery_message := ""

func _init(save_directory: String = "user://lantern_lot_presentation") -> void:
	directory = save_directory

static func default_settings() -> Dictionary:
	return {"text_scale": 1.0, "reduced_motion": false, "sound": true, "haptics": false, "sfx_volume": 0.65, "ambience_volume": 0.3}

static func valid_settings(settings: Dictionary) -> bool:
	if settings.size() != 6 or not settings.get("text_scale") in [1.0, 1.5, 2.0] or not settings.get("reduced_motion") is bool or not settings.get("sound") is bool or not settings.get("haptics") is bool:
		return false
	for key in ["sfx_volume", "ambience_volume"]:
		var value: Variant = settings.get(key)
		if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0 or float(value) > 1:
			return false
	return true

static func valid_sockets(sockets: Dictionary) -> bool:
	if sockets.size() > 6:
		return false
	var occupied: Dictionary = {}
	for uid in sockets:
		var value: Variant = sockets[uid]
		if not uid is String or uid.is_empty() or uid.length() > 128 or not Layout.integral(value) or int(value) < 0 or int(value) >= 6 or occupied.has(int(value)):
			return false
		occupied[int(value)] = true
	return true

func load_sockets() -> Dictionary:
	return read_file("sockets", {})

func save_sockets(sockets: Dictionary) -> bool:
	if not valid_sockets(sockets):
		error = "Shelf mapping must contain unique valid sockets."
		return false
	return write_file("sockets", sockets)

func load_layout() -> Dictionary:
	return read_file("layout", Layout.defaults())

func load_settings() -> Dictionary:
	return read_file("settings", default_settings())

func save_layout(layout: Dictionary) -> bool:
	if not Layout.validate(layout).ok:
		error = Layout.validate(layout).message
		return false
	return write_file("layout", layout)

func save_settings(settings: Dictionary) -> bool:
	if not valid_settings(settings):
		error = "Choose supported text, motion, sound and haptics settings."
		return false
	return write_file("settings", settings)

func read_file(kind: String, fallback: Dictionary) -> Dictionary:
	error = ""
	recovery_message = ""
	var path := directory.path_join(kind + ".json")
	if not FileAccess.file_exists(path):
		return fallback.duplicate(true)
	var file := FileAccess.open(path, FileAccess.READ)
	if file != null and file.get_length() <= MAX_BYTES:
		var parser := JSON.new()
		var encoded := file.get_as_text()
		file.close()
		if parser.parse(encoded) == OK and parser.data is Dictionary:
			var envelope: Dictionary = parser.data
			if (envelope.get("version") == 1 or envelope.get("version") == VERSION) and envelope.get("kind") == kind and envelope.get("payload") is String and envelope.get("sha256") == str(envelope.get("payload", "")).sha256_text():
				if parser.parse(envelope.payload) == OK and parser.data is Dictionary:
					var candidate: Dictionary = parser.data
					if kind == "layout": candidate = Layout.migrate(candidate)
					if kind == "settings" and candidate.size() == 4:
						candidate["sfx_volume"] = 0.65
						candidate["ambience_volume"] = 0.3
					if (kind == "layout" and Layout.validate(candidate).ok) or (kind == "settings" and valid_settings(candidate)) or (kind == "sockets" and valid_sockets(candidate)):
						if kind == "layout":
							for placement in candidate.placements.values() + candidate.fixtures.values():
								placement.col = int(placement.col)
								placement.row = int(placement.row)
						if kind == "sockets":
							for uid in candidate:
								candidate[uid] = int(candidate[uid])
						return candidate
	recovery_message = "%s data could not be opened. Safe visual defaults restored; business saves are unchanged." % kind.capitalize()
	return fallback.duplicate(true)

func write_file(kind: String, candidate: Dictionary) -> bool:
	error = ""
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		error = "Cannot save presentation. Your draft is retained; Retry or Cancel."
		return false
	var payload := JSON.stringify(candidate)
	var path := directory.path_join(kind + ".json")
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		error = "Cannot write presentation. Your draft is retained; Retry or Cancel."
		return false
	file.store_string(JSON.stringify({"version": VERSION, "kind": kind, "payload": payload, "sha256": payload.sha256_text()}))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or DirAccess.rename_absolute(temporary, path) != OK:
		error = "Cannot commit presentation. Your draft is retained; Retry or Cancel."
		return false
	return true

