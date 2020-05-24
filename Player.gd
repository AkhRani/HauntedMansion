extends Node2D

# Constants
const GRID_SIZE = 16
const MAX_SCALE = .5
const MIN_SCALE = .2
const DELTA_SCALE = .001
const SCREEN_CENTER = Vector2(640,480)/2
const ZOOM_DELAY = .3

# Settings
export var speed = 4

# Variables
var target : Vector2
var try_target : Vector2
var start : Vector2
var dt : float = 0
var zoom_timer : float = 0
var zoom_scale = .5
var initial_pan = 0
onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
    target = position
    camera.position = to_local(SCREEN_CENTER)

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
        dt += delta * speed
        if dt > 1:
            dt = 1
        position = start.linear_interpolate(target, dt)
    adjustCamera(delta, position != target)

func adjustCamera(delta, moving):
    if initial_pan < 2:
        initial_pan += delta
        if initial_pan > 2:
            camera.zoom = Vector2(MAX_SCALE,MAX_SCALE)
        else:
            camera.zoom = Vector2(1,1).linear_interpolate(Vector2(MAX_SCALE,MAX_SCALE), initial_pan/2)
        if initial_pan >= 1:
            camera.position = Vector2(0,0)
        else:
            camera.position = to_local(SCREEN_CENTER).linear_interpolate(Vector2(0,0), initial_pan)
    if moving:
        if zoom_timer < ZOOM_DELAY:
            zoom_timer += delta*2
        elif zoom_scale > MIN_SCALE:
            zoomCamera(-DELTA_SCALE)
    else:
        # Standing still, decrease zoom (increase scale)
        if zoom_timer > -ZOOM_DELAY:
            zoom_timer -= delta
        elif zoom_scale < MAX_SCALE:
            zoomCamera(DELTA_SCALE / 2)

func zoomCamera(delta):
    zoom_scale += delta
    camera.zoom.x = zoom_scale
    camera.zoom.y = zoom_scale
