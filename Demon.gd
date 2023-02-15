extends Node2D
class_name DemonScene

# Declare member variables here. Examples:
# var a = 2
var target : Vector2
var try_target: Vector2
var start : Vector2
var dt : float
var rng = RandomNumberGenerator.new()
@export var speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	target = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position == target and try_target == target:
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
		try_target = position + dir * 16
		dt = 0
	elif position != target:
		dt += delta * speed
		if dt > 1:
			dt = 1
		position = start.lerp(target, dt)

