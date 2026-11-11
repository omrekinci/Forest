extends CanvasLayer

@onready var bullet_label = $Label
func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	bullet_label.text = str(Numbers.bullets)
