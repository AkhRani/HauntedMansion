extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    if global.difficulty < 6:
        global.difficulty += 1
    $HBoxContainer/Difficulty.text = "%d" % global.difficulty
    $HBoxContainer/Score.text = "%d" % global.score

func _on_Button_pressed():
    get_tree().change_scene("res://Mansion.tscn")