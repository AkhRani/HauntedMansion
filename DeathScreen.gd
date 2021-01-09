extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    $HBoxContainer/Score.text = "%d" % global.score

func _on_Button_pressed():
    global.score = 0
    get_tree().change_scene("res://Mansion.tscn")

func _on_HSlider_value_changed(value: float):
    global.difficulty = int(value)
    $HBoxContainer/Difficulty.text = "%d" % global.difficulty
