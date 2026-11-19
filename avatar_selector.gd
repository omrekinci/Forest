extends Control

@onready var avatar1 = $bob
@onready var avatar2 = $"çınar"
@onready var avatar3 = $john
@onready var avatar4 = $simon

func _ready() -> void:
	avatar1.pressed.connect(av1)
	avatar2.pressed.connect(av2)
	avatar3.pressed.connect(av3)
	avatar4.pressed.connect(av4)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func av1():
	Numbers.avatar = 1
	
func av2():
	Numbers.avatar = 2
	
func av3():
	Numbers.avatar = 3
	
func av4():
	Numbers.avatar = 4
