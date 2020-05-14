extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _on_Button_pressed():
    get_tree().change_scene("res://Mansion.tscn")

func _on_HSlider_value_changed(value: float):
    global.difficulty = int(value)
    $HBoxContainer/Difficulty.text = "%d" % global.difficulty