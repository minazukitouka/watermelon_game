extends RigidBody2D

var fruit_scene := preload('res://fruit.tscn')

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var max_size = 10
var size = 1


func _ready() -> void:
	collision_shape_2d.shape.radius = size * 10
	mass = size * size * PI
	body_entered.connect(handle_collision)


func _draw() -> void:
	var color = Color.from_hsv(float(size) / max_size, 1, 1)
	draw_circle(Vector2.ZERO, collision_shape_2d.shape.radius, color)


func handle_collision(body):
	if is_queued_for_deletion():
		return
	if not body.is_in_group('fruits'):
		return

	var new_fruit_position = (global_position + body.global_position) / 2
	SignalBus.collided.emit(new_fruit_position.y)

	if body.size != size:
		return

	body.queue_free()
	queue_free()

	if size < max_size:
		var fruit = fruit_scene.instantiate()
		fruit.enable_physics()
		fruit.global_position = new_fruit_position
		fruit.size = size + 1
		get_parent().add_child.call_deferred(fruit)

	SignalBus.fruit_removed.emit(size)


func disable_physics():
	gravity_scale = 0
	collision_layer = 0
	collision_mask = 0


func enable_physics():
	gravity_scale = 1
	collision_layer = 1
	collision_mask = 1
