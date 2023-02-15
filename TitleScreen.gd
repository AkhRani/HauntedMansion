extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Title.text = "Welcome"
	var anim = $AnimationPlayer
	anim.play("Fade")
	await anim.animation_finished
	$Title.text = "to the Haunted Mansion"
	anim.play("Fade Red")

func _on_Button_pressed():
	$Title.text = "Save the cats!"
	var anim = $AnimationPlayer
	anim.play("Fade")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://Mansion.tscn")

func _on_HSlider_value_changed(value: float):
	global.difficulty = int(value)
	$HBoxContainer/MarginContainer2/Difficulty.text = "%d" % global.difficulty
