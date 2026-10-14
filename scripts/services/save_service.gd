extends RefCounted

const Session = preload("res://scripts/domain/session.gd")
const MAX_BYTES: int = 2097152
var directory: String
var error: String = ""
var unsupported_sequence: int = -1
var domain := Session.new()

func _init(save_directory: String = "user://lantern_lot_prototype") -> void:
	directory = save_directory

func load_latest() -> Dictionary:
	error = ""
	var best: Dictionary = {}
	var exists: bool = false
	var newest_unsupported: int = -1
	for name in ["slot_a.json", "slot_b.json", "previous.json"]:
		var path: String = directory.path_join(name)
		if FileAccess.file_exists(path):
			exists = true
			var snapshot: Dictionary = read_snapshot(path)
			newest_unsupported = maxi(newest_unsupported, unsupported_sequence)
			if not snapshot.is_empty() and (best.is_empty() or int(snapshot.revision) > int(best.revision)):
				best = snapshot
	if exists and best.is_empty():
		error = "No compatible save could be opened. Original files are preserved. See README for recovery."
	if newest_unsupported >= 0 and (best.is_empty() or newest_unsupported >= int(best.revision)):
		error = "A newer or incompatible save exists. Open it with its matching build. Original files are preserved."
		return {}
	return best

func read_snapshot(path: String) -> Dictionary:
	unsupported_sequence = -1
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {}
	var envelope: Variant = parser.data
	if not envelope is Dictionary:
		return {}
	if envelope.get("schema_version") != 1 or envelope.get("content_version") != "prototype-1" or envelope.get("generator_version") != 1:
		if envelope.get("save_sequence") is String and envelope.save_sequence.is_valid_int():
			unsupported_sequence = maxi(0, int(envelope.save_sequence))
		return {}
	if not envelope.get("payload_json") is String or not envelope.get("payload_sha256") is String or not envelope.get("save_sequence") is String:
		return {}
	var payload: String = envelope.payload_json
	if payload.to_utf8_buffer().size() != envelope.get("payload_bytes_length") or payload.sha256_text() != envelope.payload_sha256:
		return {}
	if parser.parse(payload) != OK:
		return {}
	var state: Variant = normalize_numbers(parser.data)
	if not state is Dictionary or not domain.valid(state) or str(int(state.revision)) != envelope.save_sequence:
		return {}
	return state

func normalize_numbers(value: Variant) -> Variant:
	# JSON numbers decode as floats. Restore integral domain values before any
	# Array.has/contains comparison, which distinguishes int from float.
	if value is float and is_finite(value) and value == floor(value) and abs(value) <= 9007199254740991.0:
		return int(value)
	if value is Array:
		var array: Array = []
		for element in value:
			array.append(normalize_numbers(element))
		return array
	if value is Dictionary:
		var dictionary: Dictionary = {}
		for key in value:
			dictionary[key] = normalize_numbers(value[key])
		return dictionary
	return value

func commit(candidate: Dictionary) -> bool:
	error = ""
	if not domain.valid(candidate):
		error = "Invalid candidate; save was not written."
		return false
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		error = "Cannot create save directory. Check disk space and permissions, then Retry save."
		return false
	var payload: String = JSON.stringify(candidate)
	var envelope: Dictionary = {"schema_version": 1, "content_version": "prototype-1", "generator_version": 1, "engine_version": Engine.get_version_info().string, "save_sequence": str(int(candidate.revision)), "payload_bytes_length": payload.to_utf8_buffer().size(), "payload_sha256": payload.sha256_text(), "payload_json": payload}
	var slot: String = "slot_a.json" if int(candidate.revision) % 2 == 0 else "slot_b.json"
	var path: String = directory.path_join(slot)
	var temp: String = directory.path_join(slot + ".tmp")
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		error = "Save write failed. Progress is pending; check storage and Retry save."
		return false
	file.store_string(JSON.stringify(envelope))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK or read_snapshot(temp).is_empty():
		error = "Save verification failed. Progress is pending; Retry save."
		return false
	if FileAccess.file_exists(path):
		# Never overwrite an unsupported/corrupt original during ordinary play.
		if read_snapshot(path).is_empty():
			var archived: String = path + ".preserved-%s" % Time.get_unix_time_from_system()
			if DirAccess.rename_absolute(path, archived) != OK:
				error = "Cannot preserve the unreadable slot. Retry after checking storage."
				return false
		elif DirAccess.copy_absolute(path, directory.path_join("previous.json.tmp")) != OK or read_snapshot(directory.path_join("previous.json.tmp")).is_empty():
			error = "Could not verify the previous snapshot. Retry save."
			return false
		elif DirAccess.rename_absolute(directory.path_join("previous.json.tmp"), directory.path_join("previous.json")) != OK:
			error = "Could not replace the backup. Retry save."
			return false
	if DirAccess.rename_absolute(temp, path) != OK:
		error = "Could not replace the inactive slot. Prior saves are retained; Retry save."
		return false
	var final: Dictionary = read_snapshot(path)
	if final.is_empty() or int(final.revision) != int(candidate.revision):
		error = "Final save verification failed. Retry save."
		return false
	return true
