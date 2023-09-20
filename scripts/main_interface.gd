extends Control

var file_path
#var loaded_file = File.new()
@onready var color_container = $%ColorContainer
#@onready var happy_slider = $MarginContainer/HSplitContainer/MarginContainer/VBoxContainer/HappySlider/HappySlider
@onready var speed_slider = %SpeedSlider
@onready var note_spacing_slider = $%NoteSpacingSlider
@onready var vertical_offset_slider = $%VerticalOffsetSlider
@onready var note_size_slider = $%NoteSizeSlider
@onready var top_margin_slider = $%TopMarginSlider
@onready var audio_offset_slider = $%AudioOffsetSlider
@onready var velocity_slider = %VelocitySlider
@onready var pitch_bend_slider = %PitchBendSlider


@onready var MP3 = $%MP3


var track_color_scene = preload("res://scenes/TrackColor.tscn")

var notes = []


const MidiPlayer = preload( "res://addons/midi/MidiPlayer.gd" )
const Utility = preload( "res://addons/midi/Utility.gd" )

var channel:MidiPlayer.GodotMIDIPlayerChannelStatus = null
var midi_player:MidiPlayer = null
var keys:Array = []
var midi_player_change:bool = false

var smf_data:SMF.SMFData = null

func _ready():
	get_tree().set_auto_accept_quit(false)
	get_tree().get_root().connect("files_dropped", self._on_files_dropped)
#	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
#	print(ProjectSettings.get_setting("display/window/stretch/mode"))
#	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
#	update_sliders()


func update_sliders():
	note_size_slider.value = GlobalVariables.note_size
	speed_slider.value = GlobalVariables.speed
	velocity_slider.value = GlobalVariables.velocity_strength
	pitch_bend_slider.value = GlobalVariables.pitch_bend_strength
	note_spacing_slider.value = GlobalVariables.note_spacing
	vertical_offset_slider.value = GlobalVariables.vertical_offset
	top_margin_slider.value = GlobalVariables.top_margin
	audio_offset_slider.value = GlobalVariables.audio_offset
	load_image(GlobalVariables.background_path)
	MP3.text = GlobalVariables.sound_path + " loaded"
	if GlobalVariables.json_path != null:
		load_midi(GlobalVariables.json_path)

func _input(event):
	if Input.is_action_just_pressed("save"):
		GlobalVariables.save_settings()
	if Input.is_action_just_pressed("open_file"):
		$%LoadSongFileDialog.show()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				gradient_start = null

func load_song(file):
	if file.right(5) == ".json":
		GlobalVariables.load_settings(file)
		update_sliders()
	if file.right(4) == ".mid":
		load_midi(file)
		
	if file.right(4) == ".mp3" || file.right(4) == ".wav":
		load_sound(file)
		
	if file.right(4) == ".png" || file.right(4) == ".jpg":
		var was_inside = false
		await get_tree().create_timer(0.1).timeout
		for track in color_container.get_children():
			if track.mouse_inside_note:
				track.note_texture = file
				track.apply_note_texture()
				was_inside = true
			if track.mouse_inside_noteon:
				track.note_effect_texture = file
				track.apply_note_effect_texture()
				was_inside = true
		if not was_inside:
			load_image(file)
#	if file.right(5) == ".json":
#		load_json(file)

func _on_files_dropped(files):
	for file in files:
		load_song(file)

func _on_load_song_file_dialog_files_selected(paths):
	for file in paths:
		load_song(file)

#	var audio_loader = AudioLoader.new()
#	$AudioStreamPlayer.set_stream(audio_loader.loadfile(file_path))
#	$AudioStreamPlayer.play()

func load_midi(midi_path):
	smf_data = null
	if self.smf_data == null:
		var smf_reader: = SMF.new( )
		var result: = smf_reader.read_file(midi_path)
		if result.error == OK:
			self.smf_data = result.data
#			self.playing = true
		else:
			return
	
	GlobalVariables.json_path = midi_path
	$%LivePreview.reset()
	
	for track in color_container.get_children():
		track.free()
#	bpm = midi_json["header"]["tempos"][0]["bpm"]
	var track_number = 0
	track_number = 0
#	print(smf_data)
	for track in smf_data.tracks:
		var has_notes = false
		if track.events.size() == 0:
			continue
		var track_name = "Track"
			
		for note in track.events:
			if note.event.type == 240:
				if "text" in note.event.args:
				
#					print(note.event.args["type"])
					track_name = note.event.args["text"]
#				print(note.event.args["text"])
			if note.event.type == 144:

				has_notes = true
#			print(note.event.type)
#			if note.event.type == 3:
#			if "text" in note.event:
#				print(note.event.text.to_ascii_buffer())

#			print(note.event.type)
		if not has_notes:
			continue
		track_number += 1
			
		var track_color_instance = track_color_scene.instantiate()
		track_color_instance.text = track_name
		color_container.add_child(track_color_instance)
	track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
#		track.text = "Track " + str(track_number) + " " 
#		print((1.75 / number_of_tracks * track_number) + 0.25)
		track.number = track_number
		if not GlobalVariables.dont_color.has(str(track.number)):
			GlobalVariables.dont_color[str(track_number)] = false
		if not GlobalVariables.colors.has(str(track.number)):
			track.color = Color.from_hsv(1.0 / number_of_tracks * track_number, 0.62 + float((track_number+1)) / float((number_of_tracks+1) * 4), 0.92 - float((track_number+1)) / float((number_of_tracks+1) * 4), 1.0)
			track.dont_color = false
			track.parallax = (1.2 / number_of_tracks * (number_of_tracks - track_number)) + 0.6
			track.note_texture = "res://assets/sprites/note_texture.png"
			track.note_effect_texture = "res://assets/sprites/note_effect_texture.png"
			GlobalVariables.note_texture_margins[str(track_number)] = Vector2(12,12)
			track.note_margins = Vector2(12,12)
			GlobalVariables.staccato[str(track_number)] = false
#			if track_number == 10 || track_number == 11:
#				track.note_texture = "res://assets/sprites/note_staccato_image.png"
#				GlobalVariables.staccato[str(track_number)] = true
#				track.staccato = true
		else:
			track.color = GlobalVariables.colors[str(track_number)]
			track.parallax = GlobalVariables.parallax[str(track_number)]
			track.note_texture = GlobalVariables.note_texture[str(track_number)]
			track.note_effect_texture = GlobalVariables.note_effect_texture[str(track_number)]
			track.note_margins = GlobalVariables.note_texture_margins[str(track_number)]
			track.staccato = GlobalVariables.staccato[str(track_number)]
			track.dont_color = GlobalVariables.dont_color[str(track_number)]
		track.apply_note_texture()
		track.apply_color()
		track.apply_parallax()
		track.apply_note_effect_texture()
		track.apply_note_margins()
		track.apply_staccato()
		track.apply_dont_color()
		track_number += 1
	track_number = 0
	
	for track in smf_data.tracks:
		var has_notes = false
		if track.events.size() == 0:
			continue
		for note in track.events:
			if note.event.type == 144:
				has_notes = true
#			print(note.event.type)
		if not has_notes:
			continue
#		print(track)
		for note in track.events:
			if note.event.type == 144:
				add_note_to_array(note.event.note, track_number)
		track_number += 1
		
		
	for track in smf_data.tracks:
		var has_notes = false
		if track.events.size() == 0:
			continue
		for note in track.events:
			if note.event.type == 144:
				has_notes = true
#			print(note.event.type)
		if not has_notes:
			continue
		for note in track.events:
			if note.event.type == 144:
				add_note_to_array(note.event.note, track_number)
		track_number += 1

	track_number = 0
	var note_min = 128
	var note_max = 0
#	print(notes)
	for note in notes:
		if note[0] > note_max:
			note_max = note[0]
		if note[0] < note_min:
			note_min = note[0]
	var note_range = note_max - note_min
	print(note_range)
	GlobalVariables.note_range = note_range
	GlobalVariables.bottom_note = note_min
	GlobalVariables.note_spacing = (GlobalVariables.vertical_offset + GlobalVariables.top_margin) / note_range
	#GlobalVariables.save_settings()

var gradient_start = null

func create_gradient(to_track):
#	for track in color_container.get_children():
#		track.apply_color()
	var start_tween = get_tree().create_tween()
	start_tween.tween_property(color_container.get_child(gradient_start).get_node("Container/GradientStart"), "scale", Vector2(0.0, 0.0), 0.5)
	GlobalVariables.save_settings()
	var from_track = gradient_start
	if from_track == to_track:
		gradient_start = null
		
		return
		
	if from_track > to_track:
		var from = from_track
		from_track = to_track
		to_track = from
	var tracks_to_color = color_container.get_children().slice(from_track, to_track + 1)
	var number_of_tracks = to_track - from_track
	var h_diff = wrapf((color_container.get_child(to_track).color.h - color_container.get_child(from_track).color.h), -0.5, 0.5) / number_of_tracks
	var s_diff = (color_container.get_child(to_track).color.s - color_container.get_child(from_track).color.s) / number_of_tracks
	var v_diff = (color_container.get_child(to_track).color.v - color_container.get_child(from_track).color.v) / number_of_tracks
#	print( color_container.get_child(from_track).color.h)
	var i = 0
	var starting_color = color_container.get_child(from_track).color
	for track in tracks_to_color:
		track.color.h = starting_color.h + h_diff * i
		track.color.s = starting_color.s + s_diff * i
		track.color.v = starting_color.v + v_diff * i
		GlobalVariables.colors[str(from_track + i)] = track.color
		await get_tree().create_timer(0.05).timeout
#		track.color = Color(starting_color.h + (h_diff * i), starting_color.s + (s_diff * i), starting_color.v + (v_diff * i))
		i += 1
		track.apply_color()
		
	gradient_start = null

	
func add_note_to_array(note, track_number):
	notes.append([note, track_number])
		

func load_sound(file):
	GlobalVariables.sound_path = file
	MP3.text = file + " loaded"
	#GlobalVariables.save_settings()

func load_image(file):
#	var image = Image.new()
#	var err = image.load(file)
#	if err != OK:
#		# Failed
#		print("error loading image :(")
#	background.texture = ImageTexture.new()
#	background.texture.create_from_image(image)
	GlobalVariables.background_path = file
	#GlobalVariables.save_settings()

func _on_preview_button_pressed():
	GlobalVariables.save_settings()
	OS.create_process(OS.get_executable_path(), ["res://scenes/BUG.tscn", GlobalVariables.background_path, "--", "--loaded_config=" + GlobalVariables.loaded_settings_path])

func _on_export_button_pressed():
	GlobalVariables.save_settings()
	$%ExportVideo.show()

func _on_debug_button_pressed():
	$%LivePreview.reset()

func _on_h_slider_value_changed(value):
	GlobalVariables.audio_offset = value
	#GlobalVariables.save_settings()

func _on_speed_slider_value_changed(value):
	GlobalVariables.speed = value
	#GlobalVariables.save_settings()
	$%LivePreview.notify_global_variable_change("speed", value)

func _on_note_spacing_slider_value_changed(value):
#	GlobalVariables.note_spacing = value
	#GlobalVariables.save_settings()
	pass

func _on_vertical_offset_slider_value_changed(value):
	GlobalVariables.vertical_offset = value
	#GlobalVariables.save_settings()
	$%LivePreview.notify_global_variable_change("vertical_offset", value)
	update_note_spacing()
	

func _on_note_size_slider_value_changed(value):
	GlobalVariables.note_size = value
	#GlobalVariables.save_settings()

func _on_square_toggle_toggled(button_pressed):
	GlobalVariables.square_ratio = button_pressed
	#GlobalVariables.save_settings()


func _on_reset_colors_button_pressed():
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.color = Color.from_hsv(1.0 / number_of_tracks * track_number, 0.62 + float((track_number+1)) / float((number_of_tracks+1) * 4), 0.92 - float((track_number+1)) / float((number_of_tracks+1) * 4), 1.0)
#		track.color = Color.from_hsv(1.0 / number_of_tracks * track_number, 0.7, 0.85, 1.0)
		track.apply_color()
		track_number += 1


func _on_reset_parallax_button_pressed():
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.parallax = (1.2 / number_of_tracks * (number_of_tracks - track_number)) + 0.5
		track.apply_parallax()
		track_number += 1

func update_note_spacing():
	GlobalVariables.note_spacing = (GlobalVariables.vertical_offset + GlobalVariables.top_margin) / GlobalVariables.note_range
	#GlobalVariables.save_settings()
	$%LivePreview.notify_global_variable_change("note_spacing", GlobalVariables.note_spacing)


func _on_top_margin_slider_value_changed(value):
	GlobalVariables.top_margin = value
	$%LivePreview.notify_global_variable_change("top_margin", value)
	#GlobalVariables.save_settings()
	update_note_spacing()


func _on_reset_note_texture_button_pressed():
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.note_texture = "res://assets/sprites/note_texture.png"
		track.apply_note_texture()
#		track.set_note_texture()
		track_number += 1


func _on_note_texture_button_pressed():
	$%SetAllNotesTextureFileDialog.show()


func _on_set_all_notes_texture_file_dialog_file_selected(path):
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.note_texture = path
		track.apply_note_texture()
#		track.set_note_texture()
		track_number += 1

func _on_effect_texture_button_pressed():
	$%SetAllEffectsTextureFileDialog.show()

func _on_set_all_effects_texture_file_dialog_file_selected(path):
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.note_effect_texture = path
		track.apply_note_effect_texture()
		track_number += 1


func _on_reset_note_effect_texture_button_pressed():
	var track_number = 0
	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
		track.number = track_number
		track.note_effect_texture = "res://assets/sprites/note_effect_texture.png"
		track.apply_note_effect_texture()
#		track.set_note_texture()
		track_number += 1

func set_all_notes_left_margin():
	var value = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer3/LeftMarginSlider.value
	var track_number = 0
#	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
#		track.number = track_number
		GlobalVariables.note_texture_margins[str(track_number)] = Vector2(value, GlobalVariables.note_texture_margins[str(track_number)].y)
		#GlobalVariables.save_settings()
		track.apply_note_margins()
		track_number += 1
		

func set_all_notes_right_margin():
	var value = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer3/RightMarginSlider.value
	var track_number = 0
#	var number_of_tracks = color_container.get_child_count()
	for track in color_container.get_children():
#		track.number = track_number
		GlobalVariables.note_texture_margins[str(track_number)] = Vector2(GlobalVariables.note_texture_margins[str(track_number)].x, value)
		#GlobalVariables.save_settings()
		track.apply_note_margins()
		track_number += 1


func _on_export_video_file_selected(path):
	OS.create_process(OS.get_executable_path(), ["res://scenes/BUG.tscn", GlobalVariables.background_path, "--write-movie", path, "--", "--loaded_config=" + GlobalVariables.loaded_settings_path])


func _on_audio_offset_slider_value_changed(value):
	GlobalVariables.audio_offset = value
	#GlobalVariables.save_settings()
	$%LivePreview.notify_global_variable_change("audio_offset", value)


func _on_note_length_slider_value_changed(value):
	for track in color_container.get_children():
		track.get_node("HBoxContainer2/TextureRect").size_flags_stretch_ratio = value


func _on_velocity_slider_value_changed(value):
	GlobalVariables.velocity_strength = value
	#GlobalVariables.save_settings()


func _on_pitch_bend_slider_value_changed(value):
	GlobalVariables.pitch_bend_strength = value
	#GlobalVariables.save_settings()



func _on_save_config_button_pressed():
	GlobalVariables.save_settings()
	


func _on_new_config_button_pressed():
	%SaveBeforeNewDialog.show()

func _on_save_as_config_button_pressed():
	%SaveConfig.show()

func _on_save_config_file_selected(path):
	GlobalVariables.save_settings(path)
	GlobalVariables.load_settings(path)
	

func _on_save_before_new_dialog_confirmed():
	#GlobalVariables.save_settings()
	%CreateNewConfig.show()

func _on_save_before_new_dialog_canceled():
	%CreateNewConfig.show()

func _on_create_new_config_file_selected(path):
	GlobalVariables.load_settings(GlobalVariables.default_settings_path)
	GlobalVariables.save_settings(path)
	GlobalVariables.load_settings(path)
	
	update_sliders()


func _on_load_config_button_pressed():
	%LoadConfigDialog.show()

func _on_load_config_dialog_file_selected(path):
	GlobalVariables.load_settings(path)
	update_sliders()
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GlobalVariables.save_other_settings()
		
		%SaveBeforeQuit.show()

func _on_save_before_quit_confirmed():
	GlobalVariables.save_settings()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()


func _on_save_before_quit_canceled():
	get_tree().quit()
