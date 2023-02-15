extends Node2D

var CatScene = preload("res://CatSprite.tscn")

@onready var mansion_map = find_child("MansionMap")
@onready var score = find_child("Score")

# TODO:  Single definition of this constant (in globals?)
const CAT_COUNT = 10
var cats_saved = 0

func on_cat_saved():
	var cat = CatScene.instantiate()
	cats_saved += 1
	cat.position.y = 0
	cat.position.x = cats_saved * cat.texture.get_height()
	find_child("SavedCats").add_child(cat)
	print(cats_saved)
	if CAT_COUNT == cats_saved:
		# TODO:  Victory sound, animation, final score, something.
		get_tree().change_scene_to_file("res://VictoryScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	mansion_map.connect("cat_saved",Callable(self,"on_cat_saved"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	score.text = "%d" % global.score
