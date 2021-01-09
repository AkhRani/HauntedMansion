extends Node2D


# Constants
const GRID_SIZE = 16
const MAX_SCALE = .5
const MIN_SCALE = .25
const DELTA_SCALE = .001
const SCREEN_CENTER = Vector2(640,480)/2
const ZOOM_DELAY = .3

# Settings
export var speed = 4

# Variables
var CatScene = preload("res://CatSprite.tscn")

var target : Vector2
var try_target : Vector2
var start : Vector2
var dt : float = 0
var zoom_timer : float = 0
var zoom_scale : float = .5
var initial_pan : float  = 0
var holding_cat = false
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
        # If we don't adjust position here, we stop moving for a frame or two
        # when we hit the target position.  Doing it this way we will instead
        # get a "bump" frame
        dt = delta * speed
        position = start.linear_interpolate(try_target, dt)
    elif position != target:
        dt += delta * speed
        if dt > 1:
            dt = 1
        position = start.linear_interpolate(target, dt)
    adjust_camera(delta, position != target)

func pick_up_cat():
    if holding_cat:
        print("ERROR: already holding cat")
        return
    holding_cat = true
    var cat = CatScene.instance()
    cat.position.y = -8
    add_child(cat)
    $Sprite.frame = 5

func drop_cat():
    if not holding_cat:
        print("ERROR: not holding cat")
        return
    var cat = get_child(get_child_count()-1)
    remove_child(cat)
    cat.queue_free()
    holding_cat = false
    $Sprite.frame = 0

func adjust_camera(delta, moving):
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
        return
    if moving:
        if zoom_timer < ZOOM_DELAY:
            zoom_timer += delta*2
        elif zoom_scale > MIN_SCALE:
            zoom_camera(-DELTA_SCALE)
    else:
        # Standing still, decrease zoom (increase scale)
        if zoom_timer > -ZOOM_DELAY:
            zoom_timer -= delta
        elif zoom_scale < MAX_SCALE:
            zoom_camera(DELTA_SCALE / 2)

func zoom_camera(delta):
    zoom_scale += delta
    camera.zoom.x = zoom_scale
    camera.zoom.y = zoom_scale
