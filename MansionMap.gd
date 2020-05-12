extends TileMap

# member variables
var rng = RandomNumberGenerator.new()
var score: int = 0

var playerScene = preload("res://Player.tscn")
var player

var demonScene = preload("res://Demon.tscn")
var demons = []

var holding_cat : bool = false

const TERRAIN_TILE=0
const CAT_TILE=1
const GHOST_TILE=2
const BAT_TILE=3

func get_empty_cell():
    while true:
        var try_x = rng.randi_range(7, 33)
        var try_y = rng.randi_range(3, 20)
        if -1 == get_cell(try_x, try_y):
            return Vector2(try_x, try_y)

func place_items(id, count):
    for i in range(count):
        var cell = get_empty_cell()
        set_cell(cell.x, cell.y, id)

func cell_to_sprite(cell):
    return map_to_world(cell) + Vector2(8,8)

func place_demons(count):
    for i in range(count):
        var cell = get_empty_cell()
        # TODO:  Check for two demons in the same location
        # Even it if happens, it doesn't matter since they will move
        var demon = demonScene.instance()
        demon.position = cell_to_sprite(cell)
        demons.append(demon)
        add_child(demon)

# Called when the node enters the scene tree for the first time.
func _ready():
    player = playerScene.instance()
    player.position = cell_to_sprite(Vector2(21, 21))
    player.target = player.position
    player.try_target = player.position
    player.speed = 8
    add_child(player)

    place_items(CAT_TILE, 3)
    place_items(GHOST_TILE, 4)
    place_items(BAT_TILE, 6)
    place_demons(3)
    pass

func drop_cat(target_cell, cost):
    score -= cost
    set_cellv(target_cell, -1)
    if holding_cat:
        holding_cat = false
        score -= cost
        place_items(CAT_TILE, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # Check for collisions (most of the game logic is here)
    for d in demons:
        if d.target == player.target:
            print("Ouch")

    if player.try_target == player.target:
        # No movement to try
        return

    var target_cell = world_to_map(player.try_target)
    match get_cellv(target_cell):
        -1:
            if holding_cat and target_cell.y == 21:
                score += 100
                holding_cat = false

        TERRAIN_TILE:
            player.try_target = player.target

        CAT_TILE:
            if holding_cat:
                player.try_target = player.target
            else:
                holding_cat = true
                set_cellv(target_cell, -1)

        # Note:  Original subtracted 2 * <difficulty>^2, double that if you were carrying a cat,
        # but wouldn't let the score go below zero, so you could game it by clearing ghosts and
        # bats before picking up any cats.
        GHOST_TILE:
            drop_cat(target_cell, 10)

        BAT_TILE:
            drop_cat(target_cell, 5)

    player.target = player.try_target
