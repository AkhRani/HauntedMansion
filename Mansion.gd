extends Node2D

onready var score = find_node("Score")
export var difficulty: int

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    score.text = "%d" % $MansionMap.score
