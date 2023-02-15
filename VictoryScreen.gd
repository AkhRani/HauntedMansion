extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if global.difficulty < 6:
		global.difficulty += 1
	$VBoxContainer/HBoxContainer2/Difficulty.text = "%d" % global.difficulty
	$VBoxContainer/HBoxContainer/Score.text = "%d" % global.score
	var file_read = FileAccess.open("res://credits.txt", FileAccess.READ)
	if file_read.is_open():
		$ScrollContainer/Credits.text = file_read.get_as_text()
	else:
		$ScrollContainer/Credits.text =  "error opening file"
	pass


func _on_Button_pressed():
	get_tree().change_scene_to_file("res://Mansion.tscn")
