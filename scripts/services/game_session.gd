extends RefCounted

const Domain = preload("res://scripts/domain/session.gd")
const Saves = preload("res://scripts/services/save_service.gd")
var domain := Domain.new()
var saves := Saves.new()
var state: Dictionary = {}
var pending: Dictionary = {}
var error: String = ""
var serial: int = 0

func boot() -> void:
	state = saves.load_latest()
	error = saves.error
	if state.is_empty() and error == "":
		pending = domain.initial()
		retry()

func command(kind: String, args: Dictionary = {}) -> bool:
	if not pending.is_empty() or state.is_empty():
		return false
	serial += 1
	var command_data: Dictionary = {"id": "%d:%d:%d" % [Time.get_ticks_usec(), state.revision, serial], "revision": state.revision, "kind": kind, "args": args}
	var result: Dictionary = domain.apply(state, command_data)
	if not result.ok:
		error = result.message
		return false
	pending = result.state
	return retry()

func retry() -> bool:
	if pending.is_empty():
		return false
	if not saves.commit(pending):
		error = saves.error
		return false
	state = pending
	pending = {}
	error = ""
	return true
