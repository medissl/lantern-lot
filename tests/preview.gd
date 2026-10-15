extends "res://scripts/ui/main.gd"

# A playable scratch-save entry for editor/integration inspection.
# The normal main scene always keeps its original economic save directory.
func _ready() -> void:
	var scratch := ProjectSettings.globalize_path("res://build/manual-preview-%d" % Time.get_ticks_usec())
	game.saves = Game.Saves.new(scratch + "/economy")
	visual_save = VisualSave.new(scratch + "/visual")
	super._ready()
