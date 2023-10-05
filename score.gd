extends Label

var current_score = 0


func _ready() -> void:
	SignalBus.fruit_removed.connect(update_score)


func update_score(size: int):
	current_score += size * size
	text = str(current_score)
