extends KinematicBody2D


var height
var step
var max_height
const SPEED = 10
var linear_vel = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	height = 0
	step = 0
	max_height = $CollisionShape2D.shape.extents.y * 2
	pass # Replace with function body.

func _process(delta):
	print(height)
	if step != 0:
		var del = position.y
		
		move_and_collide(linear_vel * delta)
		del -= position.y
		
		height += del
		if height > max_height:
			position.y += height - max_height
			height -= height - max_height
			step = 0
		elif height < 0:
			position.y += height
			height = 0
			step = 0
	pass


func _on_IgnisRegularLevel_active():
	linear_vel.y = -SPEED
	step = -SPEED
	pass # Replace with function body.


func _on_IgnisRegularLevel_not_active():
	linear_vel.y = SPEED
	step = SPEED
	pass # Replace with function body.