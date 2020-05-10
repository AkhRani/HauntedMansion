extends TileMap

# member variables
var rng = RandomNumberGenerator.new()
var playerScene = preload("res://Player.tscn")
var player

var demonScene = preload("res://Demon.tscn")
var demons = []

const TERRAIN_TILE=0
const CAT_TILE=1
const GHOST_TILE=2
const BAT_TILE=3

func getEmptyCell():
    while true:
        var try_x = rng.randi_range(7, 33)
        var try_y = rng.randi_range(3, 20)
        if -1 == get_cell(try_x, try_y):
            return Vector2(try_x, try_y)


func placeItems(id, count):
    for i in range(count):
        var cell = getEmptyCell()
        set_cell(cell.x, cell.y, id)

func cellToSprite(cell):
    return map_to_world(cell) + Vector2(8,8)

func placeDemons(count):
    for i in range(count):
        var cell = getEmptyCell()
        # TODO:  Check for two demons in the same location
        # Even it if happens, it doesn't matter since they will move
        var demon = demonScene.instance()
        demon.position = cellToSprite(cell)
        demons.append(demon)
        add_child(demon)

# Called when the node enters the scene tree for the first time.
func _ready():
    player = playerScene.instance()
    player.position = cellToSprite(Vector2(21, 21))
    player.target = player.position
    player.try_target = player.position
    player.speed = 8
    add_child(player)

    placeItems(1, 3)
    placeItems(2, 4)
    placeItems(3, 6)
    placeDemons(3)
    pass

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
            print("Empty")
        TERRAIN_TILE:
            print("Wall")
            player.try_target = player.target
        CAT_TILE:
            print("Cat!")
        GHOST_TILE:
            print("Ghost")
        BAT_TILE:
            print("Bat!")
    player.target = player.try_target
