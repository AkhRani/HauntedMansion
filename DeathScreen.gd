extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Score.text = "%d" % global.score
	$VBoxContainer/HBoxContainer2/Difficulty.text = "%d" % global.difficulty
	$VBoxContainer/HBoxContainer2/HSlider.value = global.difficulty

func _on_Button_pressed():
	global.score = 0
	get_tree().change_scene_to_file("res://Mansion.tscn")

func _on_HSlider_value_changed(value: float):
	global.difficulty = int(value)
	$VBoxContainer/HBoxContainer2/Difficulty.text = "%d" % global.difficulty
