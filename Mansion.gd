extends Node2D

var catScene = preload("res://CatSprite.tscn")

onready var mansion_map = find_node("MansionMap")
onready var score = find_node("Score")

# TODO:  Single definition of this constant (in globals?)
const CAT_COUNT = 10
var cats_saved = 0

func on_cat_saved():
    var cat = catScene.instance()
    cats_saved += 1
    cat.position.y = 0
    cat.position.x = cats_saved * cat.texture.get_height()
    find_node("SavedCats").add_child(cat)
    if CAT_COUNT == cats_saved:
        # TODO:  Victory sound, animation, final score, something.
        get_tree().change_scene("res://VictoryScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    mansion_map.connect("cat_saved", self, "on_cat_saved")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    score.text = "%d" % mansion_map.score
