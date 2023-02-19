extends Node


var note_images = {}
var effect_images = {}

var vertical_offset = -192
var speed = 400
var note_spacing = 1
var note_size = 30
var happiness = 0.0
var colors = {}
var note_texture = {}
var note_texture_margins = {}
var note_effect_texture = {}
var parallax = {}
var staccato = {}
var staccato_texture = load("res://assets/sprites/note_staccato_image.png")
var bg = load("res://assets/sprites/black_image.png")
var background_path = "res://assets/sprites/black_image.png"
var json_path = "res://assets/sprites/test.json"
var sound_path = "res://assets/sprites/demo.mp3"
var square_ratio
var bottom_note = 0
var note_range = 0
var top_margin = 880

#------------------------------------------------------------------------
#SAVING SETTINGS
#------------------------------------------------------------------------

func save_settings():
	var save_data = {
		"vertical_offset": vertical_offset,
		"speed": speed,
		"note_spacing": note_spacing,
		"happiness": happiness,
		"colors": colors,
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
		"note_texture_margins": note_texture_margins,
		"staccato": staccato,
	}
	
#	var save_setting = File.new()
	var save_setting = FileAccess.open("user://settings.dat", FileAccess.WRITE)
#	if error == OK:
	save_setting.store_var(save_data)
#	save_setting.close()

func add_colors():
	pass

#------------------------------------------------------------------------
#LOADING SETTINGS
#------------------------------------------------------------------------

func load_settings():
	var file = File.new()
	if FileAccess.file_exists("user://settings.dat"):
		var error = FileAccess.open("user://settings.dat", FileAccess.READ)
#		if error == OK:
		var save_data = error.get_var()
#		if save_data == null:
#			save_settings()
#			return
#		file.close()
		background_path = save_data["background_path"]
		colors = save_data["colors"]
		parallax = save_data["parallax"]
		happiness = save_data["happiness"]
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
		note_texture_margins = save_data["note_texture_margins"]
		staccato = save_data["staccato"]

#------------------------------------------------------------------------|
#OTHER
#------------------------------------------------------------------------|

func _ready():
	load_settings()

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
