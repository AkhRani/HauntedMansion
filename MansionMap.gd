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

const TERRAIN_DIR_START = TERRAIN.UP

const GEN_DIR = [
    Vector2(0,-2),    # Starting with TERRAIN.UP
    Vector2(2, 0),
    Vector2(-2, 0),
    Vector2(0, 2),
    Vector2(0, 0)
    ]

# signals
signal cat_saved

# member variables
var rng = RandomNumberGenerator.new()
var state : int = STATE.GENERATE
var cats_saved: int = 0
var gen_timer
var gen_pos: Vector2

var PlayerScene = preload("res://Player.tscn")
var player

var DemonScene = preload("res://Demon.tscn")
var demons = []

var CatScene = preload("res://CatSprite.tscn")

# it's probably better to have one player play multiple sounds, but this is easy
onready var up_sound = $SoundPlayer
onready var down_sound = $DownPlayer

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

func place_demons(count):
    for _i in range(count):
        var cell = get_empty_cell()
        # TODO:  Check for two demons in the same location
        # Even it if happens, it doesn't matter since they will move
        var demon = DemonScene.instance()
        demon.position = map_to_world(cell)
        demon.try_target = demon.position
        demons.append(demon)
        add_child(demon)

func place_all_items():
    player = PlayerScene.instance()
    player.position = map_to_world(Vector2(21, 21))
    player.target = player.position
    player.try_target = player.position
    player.speed = 6
    add_child(player)

    place_items(TILE.CAT, CAT_COUNT)
    place_items(TILE.GHOST, 3*global.difficulty)
    place_items(TILE.BAT, 3*global.difficulty)
    place_demons(2*global.difficulty)

func gen_cell(dir, id):
    set_cellv(gen_pos + dir/2, -1)
    gen_pos += dir
    set_cell(gen_pos.x, gen_pos.y, TILE.TERRAIN, false, false, false, Vector2(id, 0))

func do_generate():
    # this is somewhat more elegant and sublty different in the original BASIC
    var i = rng.randi_range(0, 3)
    for _x in range(4):
        var dir = GEN_DIR[i]
        var try = gen_pos + dir
        if get_cellv(try) == TILE.TERRAIN and get_cell_autotile_coord(try.x, try.y) == Vector2(TERRAIN.WALL, 0):
            gen_cell(dir, TERRAIN_DIR_START+i)
            return
        i = (i+1) % 4
    # back up if possible
    var from = get_cell_autotile_coord(gen_pos.x, gen_pos.y)
    set_cellv(gen_pos, -1)
    if from.x < TERRAIN.START:
        gen_pos -= GEN_DIR[from.x - TERRAIN_DIR_START]
        return

    # Clear vertical and horizontal strips to provide multiple paths
    for y in range(5, 21):
        set_cell(17, y, -1)
        set_cell(23, y, -1)
    for y in range(10, 21):
        set_cell(13, y, -1)
        set_cell(27, y, -1)
    for x in range(7, 33):
        set_cell(x, 21, -1)
        set_cell(x, 17, -1)
    for x in range(12, 30):
        set_cell(x, 11, -1)

    gen_timer.stop()
    remove_child(gen_timer)
    place_all_items()
    state = STATE.PLAY

func pick_up_cat(target_cell):
    up_sound.play()
    player.pick_up_cat()
    set_cellv(target_cell, -1)

func drop_cat(target_cell, cost):
    down_sound.play()
    global.score -= cost
    set_cellv(target_cell, -1)
    if player.holding_cat:
        player.drop_cat()
        global.score -= cost
        place_items(TILE.CAT, 1)

func save_cat():
    up_sound.play()
    global.score += SCORE_PER_CAT
    player.drop_cat()
    emit_signal("cat_saved")

# Overrides

# Called when the node enters the scene tree for the first time.
func _ready():
    # Kick off maze generation
    rng.randomize()
    set_cell(7, 21, TILE.TERRAIN, false, false, false, Vector2(TERRAIN.START, 0))
    gen_pos = Vector2(7, 21)
    gen_timer = Timer.new()
    gen_timer.connect("timeout", self, "do_generate")
    add_child(gen_timer)
    gen_timer.start(.01) # (.05)


func move_demons():
    # Only one demon can move at a time
    var moving = false
    for d in demons:
        if d.position != d.target:
            moving = true
        if d.target == player.target:
            get_tree().change_scene("res://DeathScreen.tscn")
    if moving:
        return

    # No demons are currently moving
    for _x in range(demons.size()):
        # pick a demon, any demon.  Might hit the same
        var d : DemonScene = demons[rng.randi_range(0, demons.size()-1)]
        if d.try_target == d.target:
            # must have already checked this one
            continue
        var target_cell = world_to_map(d.try_target)
        if get_cellv(target_cell) == -1:
            d.target = d.try_target
            break
        # demon will pick a new try_target on the next "_process"
        d.try_target = d.target

func move_player():
    if player.try_target == player.target:
        # No movement to try
        return

    var target_cell = world_to_map(player.try_target)
    match get_cellv(target_cell):
        -1:
            if player.holding_cat and target_cell.y == BOTTOM_ROW:
                save_cat()

        TILE.TERRAIN:
            player.try_target = player.target

        TILE.CAT:
            if player.holding_cat:
                player.try_target = player.target
            else:
                pick_up_cat(target_cell)

        # Note:  Original subtracted 2 * <difficulty>^2, double that if you were carrying a cat,
        # but wouldn't let the score go below zero, so you could game it by clearing ghosts and
        # bats before picking up any cats.
        TILE.GHOST:
            drop_cat(target_cell, 10)

        TILE.BAT:
            drop_cat(target_cell, 5)

    player.target = player.try_target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if state !=  STATE.PLAY:
        return
    move_demons()
    move_player()
