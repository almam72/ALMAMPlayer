extends Node


var note_images = {}
var effect_images = {}

var vertical_offset = -192
var speed = 300
var note_spacing = 1
var note_size = 30
var audio_offset = 0.0
var colors = {}
var colors_json = {}
var note_texture = {}
var note_texture_margins = {}
var note_texture_margins_json = {}
var note_effect_texture = {}
var parallax = {}
var staccato = {}
var dont_color = {}
var staccato_texture = load("res://assets/sprites/note_staccato_image.png")
var bg = load("res://assets/sprites/black_image.png")
var background_path = "res://assets/sprites/black_image.png"
var json_path = "res://assets/sprites/demo.mid"
var sound_path = "res://assets/sprites/demo.mp3"
var square_ratio
var bottom_note = 0
var note_range = 0
var top_margin = 880

var velocity_strength = 0.2
var pitch_bend_strength = 0.5

var other_settings_path = "user://other_settings.json"
var loaded_settings_path = "user://default_settings.json"
var default_settings_path = "user://default_settings.json"
#------------------------------------------------------------------------
#SAVING SETTINGS
#------------------------------------------------------------------------


func save_other_settings():
	var save_data = {
		"loaded_settings_path": loaded_settings_path,
		}
	var save_setting = FileAccess.open(other_settings_path, FileAccess.WRITE)
#	if error == OK:
	save_setting.store_line(JSON.stringify(save_data,"\t"))

func load_other_settings(path = other_settings_path):
	var file = File.new()
	if FileAccess.file_exists(path):
		var json_text = FileAccess.get_file_as_string(path)
		var save_data = JSON.parse_string(json_text)
		load_variable(save_data, "loaded_settings_path")

func save_settings(path = loaded_settings_path):
	var i = 0
	for color in colors.values():
		colors_json[str(i)] = color.to_html()
		i += 1
		
	i = 0
	for margins in note_texture_margins.values():
		note_texture_margins_json[str(i)] = var_to_str(margins)
		i += 1
	
	var save_data = {
		"vertical_offset": vertical_offset,
		"speed": speed,
		"note_spacing": note_spacing,
		"audio_offset": audio_offset,
		"colors_json": colors_json,
		"note_texture": note_texture,
		"note_effect_texture": note_effect_texture,
		"parallax": parallax,
		"background_path": background_path,
		"sound_path": sound_path,
		"json_path": json_path,
		"note_size": note_size,
		"square_ratio": square_ratio,
		"bottom_note": bottom_note,
		"top_margin": top_margin,
		"note_texture_margins_json": note_texture_margins_json,
		"staccato": staccato,
		
		"velocity_strength": velocity_strength,
		"pitch_bend_strength": pitch_bend_strength,
		"dont_color": dont_color,
	}
	
#	var save_setting = File.new()
	var save_setting = FileAccess.open(path, FileAccess.WRITE)
#	if error == OK:
	save_setting.store_line(JSON.stringify(save_data,"\t"))
#	save_setting.close()

func add_colors():
	pass



#------------------------------------------------------------------------
#LOADING SETTINGS
#------------------------------------------------------------------------

func load_variable(save_data, variable):
	if save_data.has(variable):
		set(variable, save_data[variable])

func load_settings(path):
	var file = File.new()
	if FileAccess.file_exists(path):
#		var error = FileAccess.open("user://settings.json", FileAccess.READ)
#		if error == OK:
		var json_text = FileAccess.get_file_as_string(path)
		var save_data = JSON.parse_string(json_text)
#		if save_data == null:	
#			save_settings()
#			return
#		file.close()
		load_variable(save_data, "velocity_strength")
		load_variable(save_data, "pitch_bend_strength")
		load_variable(save_data, "dont_color")
		
		background_path = save_data["background_path"]
		colors_json = save_data["colors_json"]
		parallax = save_data["parallax"]
		audio_offset = save_data["audio_offset"]
		sound_path = save_data["sound_path"]
		json_path = save_data["json_path"]
		note_spacing = save_data["note_spacing"]
		vertical_offset = save_data["vertical_offset"]
		speed = save_data["speed"]
		note_size = save_data["note_size"]
		square_ratio = save_data["square_ratio"]
		note_texture = save_data["note_texture"]
		note_effect_texture = save_data["note_effect_texture"]
		bottom_note = save_data["bottom_note"]
		top_margin = save_data["top_margin"]
		note_texture_margins_json = save_data["note_texture_margins_json"]
		staccato = save_data["staccato"]
	else:
		save_settings("user://default_settings.json")
		return
		
#		load_settings("user://default_settings.json")
	loaded_settings_path = path
	DisplayServer.window_set_title("ALMAMPlayer | config: " + path)
	var i = 0
	
	for color in colors_json.values():
		colors[str(i)] = Color(colors_json[str(i)])
		i += 1
	
	i = 0
	for margins in note_texture_margins_json.values():
		note_texture_margins[str(i)] = str_to_var(note_texture_margins_json[str(i)])
		i += 1
#------------------------------------------------------------------------|
#OTHER
#------------------------------------------------------------------------|

func _ready():
	await get_tree().create_timer(0.1).timeout
	if not FileAccess.file_exists(default_settings_path):
		get_tree().get_nodes_in_group("MainInterface")[0].update_sliders()
		await get_tree().create_timer(0.1).timeout
		
		save_settings(default_settings_path)
	
	load_other_settings()
	load_settings(loaded_settings_path)
	get_tree().get_nodes_in_group("MainInterface")[0].update_sliders()

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
