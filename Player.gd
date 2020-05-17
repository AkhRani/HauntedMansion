extends Node2D

# Constants
const GRID_SIZE = 16
const MAX_SCALE = .5
const MIN_SCALE = .2
const DELTA_SCALE = .001

# Settings
export var speed = 4

# Variables
var target : Vector2
var try_target : Vector2
var start : Vector2
var dt : float
var still_time : float
var zoom_scale = .5
onready var camera = $Camera2D

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
        try_target = position + dir * GRID_SIZE
        dt = 0
    elif position != target:
        still_time = 0
        dt += delta * speed
        if dt > 1:
            dt = 1
        position = start.linear_interpolate(target, dt)
        # Moving, increase zoom (decrease scale)
        if zoom_scale > MIN_SCALE:
            zoom_scale -= DELTA_SCALE
            camera.zoom.x = zoom_scale
            camera.zoom.y = zoom_scale
    else:
        still_time += delta
        # Standing still, decrease zoom (increase scale)
        if still_time > 1 and zoom_scale < MAX_SCALE:
            zoom_scale += DELTA_SCALE / 2
            camera.zoom.x = zoom_scale
            camera.zoom.y = zoom_scale
