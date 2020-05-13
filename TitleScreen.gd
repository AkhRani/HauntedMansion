extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    $Title.text = "Welcome"
    var anim = $AnimationPlayer
    anim.play("Fade")
    yield(anim, "animation_finished")
    $Title.text = "to the Haunted Mansion"
    anim.play("Fade Red")

    pass # Replace with function body.

func _on_Button_pressed():
    get_tree().change_scene("res://Mansion.tscn")

func _on_HSlider_value_changed(value: float):
    global.difficulty = int(value)
    $HBoxContainer/Difficulty.text = "%d" % global.difficulty
