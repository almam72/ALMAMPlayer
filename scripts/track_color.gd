extends Control

@onready var color_rect = $Node2D/ColorRect


var number = 0
var text = ""
var color = Color(1.0, 1.0, 1.0, 1.0)
var parallax = 1.0
var note_texture = "res://assets/sprites/note_texture.png"
var note_effect_texture = "res://assets/sprites/note_effect_texture.png"
var default_texture = load("res://assets/sprites/note_texture.png")
var default_staccato_texture = load("res://assets/sprites/note_staccato.png")
var default_effect_texture = load("res://assets/sprites/note_effect_texture.png")
var note_margins = Vector2(12,12)
var mouse_inside_note = false
var mouse_inside_noteon = false
var staccato = false
var dont_color = false
@onready var texture_rect = $HBoxContainer2/TextureRect
@onready var note_effect_preview = $Container/NoteEffectPreview

func _ready():
	set_note_texture()	
	texture_rect.custom_minimum_size = texture_rect.texture.get_size()
	await get_tree().process_frame
	if number % 2 == 1:
		color_rect.color = Color("#eee3ff")
	else:
		color_rect.color = Color("#ffe6c2")
func apply_color():
	$Container/Label.text = text
	$Container/ColorPickerButton.color = color
	texture_rect.self_modulate = color
	if not GlobalVariables.dont_color[str(number)]:
		note_effect_preview.self_modulate = color
	GlobalVariables.colors[str(number)] = color
	#GlobalVariables.save_settings()

func apply_parallax():
	$Container/SpinBox.value = parallax
	GlobalVariables.parallax[str(number)] = parallax
	#GlobalVariables.save_settings()

func apply_note_texture():
	GlobalVariables.note_texture[str(number)] = note_texture
	#GlobalVariables.save_settings()
	set_note_texture()
#	texture_rect.custom_minimum_size = texture_rect.texture.get_size()

func apply_note_margins():
	$HBoxContainer2/LeftMarginSlider.value = GlobalVariables.note_texture_margins[str(number)].x
	$HBoxContainer2/RightMarginSlider.value = GlobalVariables.note_texture_margins[str(number)].y
#	GlobalVariables.note_texture_margins[str(number)] = note_margins
	#GlobalVariables.save_settings()
#	set_note_texture()

func apply_note_effect_texture():
#	note_effect_texture
	GlobalVariables.note_effect_texture[str(number)] = note_effect_texture
	#GlobalVariables.save_settings()
	set_effect_texture()

func _on_color_picker_button_color_changed(color):
	texture_rect.self_modulate = color
	if not GlobalVariables.dont_color[str(number)]:
		note_effect_preview.self_modulate = color
	GlobalVariables.colors[str(number)] = color 
	#GlobalVariables.save_settings()

func _on_spin_box_value_changed(value):
	GlobalVariables.parallax[str(number)] = value
	#GlobalVariables.save_settings()

func _on_note_texture_button_pressed():
	$Container/FileDialog.show()

func _on_file_dialog_file_selected(path):
	GlobalVariables.note_texture[str(number)] = path
	set_note_texture()
#	await get_tree().create_timer(0.15).timeout
	#GlobalVariables.save_settings()


#func _on_note_effect_button_pressed():

func _on_file_dialog_2_file_selected(path):
	GlobalVariables.note_effect_texture[str(number)] = path
	note_effect_texture = path
	apply_note_effect_texture()
	set_effect_texture()
#	await get_tree().create_timer(0.15).timeout
	#GlobalVariables.save_settings()
	
func set_note_texture():
	await get_tree().create_timer(0.1).timeout
#	print(number)
	if GlobalVariables.note_texture[str(number)] == "res://assets/sprites/note_texture.png":
		texture_rect.texture = default_texture
		texture_rect.custom_minimum_size = texture_rect.texture.get_size()
#		texture_rect.custom_minimum_size.x = 250
		texture_rect.custom_minimum_size.y = 18
		return
	if GlobalVariables.note_texture[str(number)] == "res://assets/sprites/note_staccato_image.png":
		texture_rect.texture = default_texture
		texture_rect.custom_minimum_size = texture_rect.texture.get_size()
#		texture_rect.custom_minimum_size.x = 250
		texture_rect.custom_minimum_size.y = 18
		return
#	var image = Image.new()
#	var err = image.load(GlobalVariables.note_texture[str(number)])
#	if err != OK:
##		# Failed
#		print("error loading image :(")
#		return
	var image = Image.load_from_file(GlobalVariables.note_texture[str(number)])
#	texture_rect.texture = ImageTexture.new()
#	texture_rect.texture.create_from_image(image)
	texture_rect.texture = ImageTexture.create_from_image(image)
	texture_rect.custom_minimum_size = texture_rect.texture.get_size()

func set_effect_texture():
	await get_tree().create_timer(0.1).timeout
#	print(number)
	if GlobalVariables.note_effect_texture[str(number)] == "res://assets/sprites/note_effect_texture.png":
		note_effect_preview.texture = default_effect_texture
#		texture_rect.custom_minimum_size.x = 250
#		texture_rect.custom_minimum_size.y = 18
		return
#	var image = Image.new()
#	var err = image.load(GlobalVariables.note_effect_texture[str(number)])
#	if err != OK:
#		# Failed
#		print("error loading image :(")
#	note_effect_preview.texture = ImageTexture.new()
	note_effect_preview.texture = ImageTexture.create_from_image(Image.load_from_file(GlobalVariables.note_effect_texture[str(number)]))
#	note_effect_preview.texture.create_from_image(image)
#	note_effect_preview.custom_minimum_size = note_effect_preview.texture.get_size()


func _on_left_margin_slider_value_changed(value):
	$HBoxContainer2/TextureRect.patch_margin_left = value
	GlobalVariables.note_texture_margins[str(number)] = Vector2(value, GlobalVariables.note_texture_margins[str(number)].y)
	#GlobalVariables.save_settings()
	
func _on_right_margin_slider_value_changed(value):
	$HBoxContainer2/TextureRect.patch_margin_right = value
	GlobalVariables.note_texture_margins[str(number)] = Vector2(GlobalVariables.note_texture_margins[str(number)].x, value)
	#GlobalVariables.save_settings()

func apply_staccato():
	GlobalVariables.staccato[str(number)] = staccato
	$Container/CheckBox.button_pressed = GlobalVariables.staccato[str(number)]
	#GlobalVariables.save_settings()
	
func apply_dont_color():
	GlobalVariables.dont_color[str(number)] = dont_color
	$Container/ColorCheckBox.button_pressed = GlobalVariables.dont_color[str(number)]
	#GlobalVariables.save_settings()

func _on_check_box_toggled(button_pressed):
	if button_pressed:
		$HBoxContainer2/TextureRect.set_h_size_flags($HBoxContainer2/TextureRect.SIZE_SHRINK_CENTER)
	else:
		$HBoxContainer2/TextureRect.set_h_size_flags($HBoxContainer2/TextureRect.SIZE_EXPAND_FILL)
	GlobalVariables.staccato[str(number)] = button_pressed
	#GlobalVariables.save_settings()


func _on_color_check_box_toggled(button_pressed):
	if button_pressed:
		$Container/NoteEffectPreview.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		$Container/NoteEffectPreview.self_modulate = GlobalVariables.colors[str(number)]
	GlobalVariables.dont_color[str(number)] = button_pressed
	#GlobalVariables.save_settings()




func _on_note_texture_button_mouse_entered():
	mouse_inside_note = true


func _on_note_texture_button_mouse_exited():
	mouse_inside_note = false


func _on_note_effect_button_mouse_entered():
	mouse_inside_noteon = true


func _on_note_effect_button_mouse_exited():
	mouse_inside_noteon = false


func _on_note_texture_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				$Container/FileDialog.show()

			MOUSE_BUTTON_RIGHT:
				GlobalVariables.note_texture[str(number)] = "res://assets/sprites/note_texture.png"
				set_note_texture()


func _on_note_effect_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				$Container/FileDialog2.show()

			MOUSE_BUTTON_RIGHT:
				GlobalVariables.note_effect_texture[str(number)] = "res://assets/sprites/note_effect_texture.png"
				set_effect_texture()
