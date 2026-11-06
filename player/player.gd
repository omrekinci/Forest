extends CharacterBody3D

@export var walk_speed = 5.0
@export var sprint_speed = 10
@export var jump_speed = 4.5
@export var mouse_sensitivity = 0.003

@export var normal_fov = 75.0
@export var sprint_fov = 85.0
@export var fov_change = 10.0

@export var max_stamina = 100.0
@export var stamina_drain_speed = 25.0 
@export var stamina_regen_speed = 15.0
var stamina = 100.0
var has_stamina = false

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera
@onready var stamina_bar: ProgressBar = $CanvasLayer/StaminaBar

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	stamina = max_stamina
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if (Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = jump_speed

	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_dir.x += 1
		
	input_dir = input_dir.normalized()
	var is_moving = input_dir.length() > 0

	var is_sprinting = false
	if Input.is_key_pressed(KEY_SHIFT) and is_moving and not has_stamina:
		is_sprinting = true

	if is_sprinting:
		stamina = max(0.0, stamina - stamina_drain_speed * delta)
		if stamina <= 0.0:
			has_stamina = true
	else:
		stamina = min(max_stamina, stamina + stamina_regen_speed * delta)
		if has_stamina and stamina >= max_stamina * 0.2:
			has_stamina = false

	if stamina_bar:
		stamina_bar.value = stamina
		stamina_bar.visible = stamina < max_stamina

	var current_speed = walk_speed
	var target_fov = normal_fov
	
	if is_sprinting:
		current_speed = sprint_speed
		target_fov = sprint_fov

	camera.fov = lerpf(camera.fov, target_fov, delta * fov_change)

	var direction := (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
