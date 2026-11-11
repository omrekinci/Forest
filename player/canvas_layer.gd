extends CanvasLayer

@onready var bullet_amount = $bullets
@onready var ammo = $ammo

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	bullet_amount.text = str(Numbers.bullets)
	ammo.text = " / " + str(Numbers.ammo)
