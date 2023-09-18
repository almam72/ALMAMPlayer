extends "res://scripts/beat_detection.gd"

var elapsed_playtime : float = 0

func _ready():
	# I think this is necessary so we don't run the base class's _ready
	print("oh i am *so* ready >:)")

func _process(delta):
	elapsed_playtime += delta

## (Re-)creates the preview based on arguments dict (see beat_detection.gd::_ready)
func init(arguments):
	_clear()
	get_tree().paused = false
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
	const an_arbitrary_but_necessary_offset = 0.4 # don't question it
	elapsed_playtime = 0.5 + an_arbitrary_but_necessary_offset

## Convenience function to relaod the preview based on the current config file
func reset():
	init({
		"loaded_config": GlobalVariables.loaded_settings_path
	})

## Removes all notes from the preview
func _clear():
	# Clear all nodes
	var note_holder = $WaveAnchor/NoteHolder
	for child in note_holder.get_children():
		if child.name.begins_with("Track"):
			note_holder.remove_child(child)
			child.free()

	# Clear internal state
	notes.clear()
	sorted_notes.clear()
	note_instances.clear()
	pitchbends.clear()
	dance_notes.clear()	

## Let the preview window know it needs to change stuff
func notify_global_variable_change(variable_name : String, _value : Variant):
	match variable_name:
		"vertical_offset", "audio_offset", "speed",	"top_margin", "note_spacing":
			_layout_notes()
		_:
			push_error("Unrecognized global variable \'%s\'" % variable_name)
			

## Sets note positions
func _layout_notes():
	var time = 1.0 - (elapsed_playtime + delay + abs(GlobalVariables.audio_offset))
	for track_instance in $WaveAnchor/NoteHolder.get_children():
		if track_instance.name.begins_with("Track"):
			# Update track's fields
			track_instance.speed = GlobalVariables.speed
			track_instance.set_parallax()

			# Update position
			track_instance.position = Vector2(time * track_instance.parallax, 0)

			# Update notes
			for note_instance in track_instance.get_children():
				if not (note_instance is AnimationPlayer):
					note_instance.speed = track_instance.speed
					note_instance.set_parallax()
					note_instance.position.x = note_instance.time * note_instance.parallax
					note_instance.position.y = -note_instance.note_number * GlobalVariables.note_spacing

	$WaveAnchor/NoteHolder.position.y = GlobalVariables.vertical_offset

