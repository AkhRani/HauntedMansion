extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    if global.difficulty < 6:
        global.difficulty += 1
    $VBoxContainer/HBoxContainer2/Difficulty.text = "%d" % global.difficulty
    $VBoxContainer/HBoxContainer/Score.text = "%d" % global.score
    var file_read = File.new()
    if(file_read.open("res://credits.txt", File.READ) != 0):
        $ScrollContainer/Credits.text =  "error opening file"
    else:
        $ScrollContainer/Credits.text = file_read.get_as_text()
        file_read.close()
    pass


func _on_Button_pressed():
    get_tree().change_scene("res://Mansion.tscn")
