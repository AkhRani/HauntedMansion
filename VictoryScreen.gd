extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    if global.difficulty < 6:
        global.difficulty += 1
    $VBoxContainer/HBoxContainer2/Difficulty.text = "%d" % global.difficulty
    $VBoxContainer/HBoxContainer/Score.text = "%d" % global.score

func _on_Button_pressed():
    get_tree().change_scene("res://Mansion.tscn")
