extends TileMap

# constants and enums
enum TILE {
    TERRAIN
    CAT
    GHOST
    BAT
    }

# sub-tile enum for TERRAIN_TILE
enum TERRAIN {
    WALL,
    ROOF_LEFT,
    ROOF_RIGHT,
    SKY,
    UP,
    RIGHT,
    LEFT,
    DOWN,
    START
    }

enum STATE {
    GENERATE,
    PLAY
    }

const BOTTOM_ROW=21
const SCORE_PER_CAT=10
const CAT_COUNT=10

# member variables
var rng = RandomNumberGenerator.new()
var state : int = STATE.GENERATE
var score: int = 0
var cats_saved: int = 0
var gen_timer

var playerScene = preload("res://Player.tscn")
var player

var demonScene = preload("res://Demon.tscn")
var demons = []

var catScene = preload("res://CatSprite.tscn")

var holding_cat : bool = false


func get_empty_cell():
    while true:
        var try_x = rng.randi_range(7, 33)
        var try_y = rng.randi_range(3, BOTTOM_ROW-1)
        if -1 == get_cell(try_x, try_y):
            return Vector2(try_x, try_y)

func place_items(id, count):
    for _i in range(count):
        var cell = get_empty_cell()
        set_cell(cell.x, cell.y, id)

func cell_to_sprite(cell):
    return map_to_world(cell) + Vector2(8,8)

func place_demons(count):
    for _i in range(count):
        var cell = get_empty_cell()
        # TODO:  Check for two demons in the same location
        # Even it if happens, it doesn't matter since they will move
        var demon = demonScene.instance()
        demon.position = cell_to_sprite(cell)
        demons.append(demon)
        add_child(demon)

func place_all_items():
    player = playerScene.instance()
    player.position = cell_to_sprite(Vector2(21, 21))
    player.target = player.position
    player.try_target = player.position
    player.speed = 8
    add_child(player)

    place_items(TILE.CAT, CAT_COUNT)
    place_items(TILE.GHOST, 3*global.difficulty)
    place_items(TILE.BAT, 3*global.difficulty)
    place_demons(2*global.difficulty)

# Called when the node enters the scene tree for the first time.
func _ready():
    gen_timer = Timer.new()
    gen_timer.connect("timeout", self, "do_generate")
    add_child(gen_timer)
    gen_timer.start(1)

func do_generate():
    gen_timer.stop()
    remove_child(gen_timer)
    place_all_items()
    state = STATE.PLAY

func drop_cat(target_cell, cost):
    score -= cost
    set_cellv(target_cell, -1)
    if holding_cat:
        var cat = player.get_child(1)
        player.remove_child(cat)
        cat.free()
        holding_cat = false
        score -= cost
        place_items(TILE.CAT, 1)

func save_cat():
    score += SCORE_PER_CAT
    holding_cat = false
    var cat = player.get_child(1)
    player.remove_child(cat)
    cat.position.y = 0
    cat.position.x = cats_saved * cat.texture.get_height()
    cats_saved += 1
    find_node("SavedCats").add_child(cat)
    if CAT_COUNT == cats_saved:
        get_tree().change_scene("res://VictoryScreen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if state !=  STATE.PLAY:
        return
    # Check for collisions (most of the game logic is here)
    for d in demons:
        if d.target == player.target:
            get_tree().change_scene("res://DeathScreen.tscn")

    if player.try_target == player.target:
        # No movement to try
        return

    var target_cell = world_to_map(player.try_target)
    match get_cellv(target_cell):
        -1:
            if holding_cat and target_cell.y == BOTTOM_ROW:
                save_cat()

        TILE.TERRAIN:
            player.try_target = player.target

        TILE.CAT:
            if holding_cat:
                player.try_target = player.target
            else:
                holding_cat = true
                var cat = catScene.instance()
                cat.position.x = -8
                cat.position.y = -16
                player.add_child(cat)
                set_cellv(target_cell, -1)

        # Note:  Original subtracted 2 * <difficulty>^2, double that if you were carrying a cat,
        # but wouldn't let the score go below zero, so you could game it by clearing ghosts and
        # bats before picking up any cats.
        TILE.GHOST:
            drop_cat(target_cell, 10)

        TILE.BAT:
            drop_cat(target_cell, 5)

    player.target = player.try_target