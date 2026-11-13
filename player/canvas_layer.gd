extends CanvasLayer

@onready var bullet_amount = $bullets
@onready var ammo = $ammo
@onready var energybar = $EnergyBar
@onready var staminabar = $StaminaBar

func _ready() -> void:
	energybar.visible = true
		


func _process(delta: float) -> void:
	bullet_amount.text = str(Numbers.bullets)
	ammo.text = " / " + str(Numbers.ammo)
	energybar.value = Numbers.energy
	
	if Numbers.energy == 0:
		staminabar.hide()
