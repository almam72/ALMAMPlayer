extends "res://scripts/beat_detection.gd"

func _ready():
	# I think this is necessary so we don't run the base class's _ready
	print("oh i am *so* ready >:)")

func init(arguments):
	reset()
	GlobalVariables.load_settings(arguments["loaded_config"])
#	print(GlobalVariables.square_ratio)
	if GlobalVariables.square_ratio:
#		ProjectSettings.set_setting("display/window/size/viewport_width", 1080)
#		DisplayServer.window_set_size(Vector2(1080, 1080))
		$Camera2D/BackgroundImageSquare.visible = true
	else:
		$Camera2D/BackgroundImageSquare.visible = false
	load_background_image(GlobalVariables.background_path)
	bpm = GlobalVariables.speed
	var audio_loader = AudioLoader.new()
	$AudioStreamPlayer2.set_stream(audio_loader.loadfile(GlobalVariables.sound_path))
#	$AnimationPlayer.seek(0.3, true)
	load_midi()
	await start() # Some weird async stuff happens in this function which leads to audio not pausing properly if you don't await
	get_tree().paused = true

func reset():
	# Clear all nodes
	var note_holder = $WaveAnchor/NoteHolder
	for child in note_holder.get_children():
		if child.name.begins_with("Track"):
			note_holder.remove_child(child)
			child.free()

	# Clear internal state
	notes.clear()
	sorted_notes.clear()
	pitchbends.clear()
	dance_notes.clear()
