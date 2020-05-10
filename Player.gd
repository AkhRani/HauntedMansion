extends Node2D

# Declare member variables here. Examples:
# var a = 2
var target : Vector2
var try_target : Vector2
var start : Vector2
var dt : float
export var speed = 4
const GRID_SIZE = 16

# Called when the node enters the scene tree for the first time.
func _ready():
    target = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var dir = Vector2()

    if Input.is_action_pressed("ui_right"):
        dir.x = 1
    elif Input.is_action_pressed("ui_left"):
        dir.x = -1
    elif Input.is_action_pressed("ui_up"):
        dir.y = -1
    elif Input.is_action_pressed("ui_down"):
        dir.y = 1

    if position == target and dir != Vector2():
        start = position
#        var check_target = position + dir * 16
#        # There may be a better way to do this
#        var map = get_node("/root/Mansion/MansionMap")
#        var cellv = map.world_to_map(check_target)
#        print(cellv)
#        if map.get_cellv(cellv) == -1:
#            target = check_target
        try_target = position + dir * GRID_SIZE
        print(try_target)
        dt = 0
    elif position != target:
        dt += delta * speed
        if dt > 1:
            dt = 1
        position = start.linear_interpolate(target, dt)

