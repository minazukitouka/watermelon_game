extends Node2D

@onready var left_marker: Marker2D = $LeftMarker
@onready var right_marker: Marker2D = $RightMarker
@onready var next_fruit_marker: Marker2D = $NextFruitMarker
@onready var full_marker: Marker2D = $FullMarker
@onready var game_over: Label = $CanvasLayer/GameOver

var fruit_scene := preload('res://fruit.tscn')
var current_fruit
var next_fruit
var is_game_over = false


func _ready() -> void:
	current_fruit = create_fruit((left_marker.global_position + right_marker.global_position) / 2)
	next_fruit = create_fruit(next_fruit_marker.global_position)
	SignalBus.collided.connect(detect_game_over)


func _physics_process(delta: float) -> void:
	if is_game_over:
		return
	if current_fruit != null:
		if current_fruit.gravity_scale == 0:
			var fruit_x = get_fruit_x()
			current_fruit.global_position.x = fruit_x
			current_fruit.global_position.y = left_marker.global_position.y
		if Input.is_action_just_pressed('drop'):
			drop_fruit()


func create_fruit(position):
	var fruit = fruit_scene.instantiate()
	fruit.disable_physics()
	fruit.global_position = position
	fruit.size = randi_range(1, 5)
	add_child(fruit)
	return fruit


func get_fruit_x():
	return clamp(
		get_global_mouse_position().x,
		left_marker.global_position.x,
		right_marker.global_position.x
	)


func drop_fruit():
	current_fruit.enable_physics()
	current_fruit = null
	await get_tree().create_timer(0.5).timeout
	current_fruit = next_fruit
	next_fruit = create_fruit(next_fruit_marker.global_position)


func detect_game_over(height: float):
	if height < full_marker.global_position.y:
		is_game_over = true
		game_over.visible = true
		await get_tree().create_timer(5).timeout
		get_tree().reload_current_scene()
