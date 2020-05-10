extends Node2D

# Declare member variables here. Examples:
# var a = 2
var target : Vector2
var start : Vector2
var dt : float
var rng = RandomNumberGenerator.new()
export var speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    target = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if position == target and rng.randf() < .1:
        var dir = Vector2()
        match rng.randi_range(0, 3):
            0:
                dir.x = 1
            1:
                dir.x = -1
            2:
                dir.y = -1
            3:
                dir.y = 1
    
        start = position
        var check_target = position + dir * 16
        # There may be a better way to do this
        var map = get_node("/root/Mansion/MansionMap")
        var cellv = map.world_to_map(check_target)
        if map.get_cellv(cellv) == -1:
            target = check_target
        dt = 0
    elif position != target:
        dt += delta * speed
        if dt > 1:
            dt = 1
        position = start.linear_interpolate(target, dt)
    
