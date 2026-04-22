extends CharacterBody3D

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = true

@export_group("Speeds")
@export var look_speed : float = 0.002
@export var base_speed : float = 2.8
@export var jump_velocity : float = 4.5
@export var sprint_speed : float = 10.0

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_left_click : String = "click_left"
@export var input_right_click : String = "click_right"
@export var album_open_close : String = "album"
@export var open_close_camera : String = "camera"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0

@onready var head: Node3D = $Head
@onready var player_camera = $Head/Camera3D
@onready var collider_player: CollisionShape3D = $Collider
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var crosshair_normal = $Head/Camera3D/normal
@onready var crosshair_pick = $Head/Camera3D/pick
@onready var crosshair_pick_piano = $Head/Camera3D/pick_piano
@onready var album_obj = $Head/Camera3D/Album
@onready var animation_player = $AnimationPlayer

enum PlayerState { NORMAL, TERMINAL, ALBUM, CAMERA, ENDING }
var state : PlayerState = PlayerState.NORMAL
var current_terminal: Node = null

var has_crowbar: bool = false

var grabbed_object: RigidBody3D = null
var grab_distance := 1.5
var just_released := false

@export var min_fov: float = 15.0  
@export var max_fov: float = 75.0   
@export var zoom_speed: float = 50.0

var target_fov: float
var default_fov: float

@onready var sequence_p3 = [true, false, false, false, false, false, false, false, false, false, false, false, false]

@onready var UI_clickRemember = $"../UI/clickRemember"
@onready var UI_zoomRemember = $"../UI/zoomRemember"
@onready var UI_textRemember = $"../UI/textRemember/Label"
@onready var UI_camera = $"../UI/camera"
"""
Practice code 
"""

"""
Practice code 
"""

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	target_fov = player_camera.fov
	default_fov = player_camera.fov
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)


func _physics_process(delta: float) -> void:
	match state:
		PlayerState.NORMAL:
			_normal_movement(delta)
		PlayerState.TERMINAL:
			velocity = Vector3.ZERO
			
			if Input.is_action_just_pressed("enter"):
				if current_terminal and current_terminal.terminal_input:
					var text = current_terminal.terminal_input.text.to_lower()  
					var answer = current_terminal.answer(text)
					if answer:
						current_terminal.khackharSolution()
						exit_terminal()
					else:
						_on_terminal_text_entered(text) 
			
			move_and_slide()
		PlayerState.ALBUM:
			clean_ui()
			velocity = Vector3.ZERO
			if Input.is_action_just_pressed("album"):
				state = PlayerState.NORMAL
				animation_player.play("album_close")
				await animation_player.animation_finished
				album_obj.visible = false
		PlayerState.CAMERA:
			clean_ui()
			UI_camera.visible = true
			UI_zoomRemember.visible = true
			velocity = Vector3.ZERO
			
			if Input.is_action_pressed(input_left_click):
				target_fov -= zoom_speed * delta
			elif Input.is_action_pressed(input_right_click):
				target_fov += zoom_speed * delta
			
			target_fov = clamp(target_fov, min_fov, max_fov)
			player_camera.fov = lerp(player_camera.fov, target_fov, 10 * delta)
			
			var zoom_factor = player_camera.fov / default_fov
			zoom_factor = clamp(zoom_factor, min_fov / default_fov, max_fov / default_fov)
			
			if Input.is_action_just_pressed(open_close_camera):
				player_camera.fov = default_fov
				state = PlayerState.NORMAL
				UI_zoomRemember.visible = false
				UI_camera.visible = false
				crosshair_normal.visible = true
		
		PlayerState.ENDING:
			return

func _normal_movement(delta):
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
		
	if grabbed_object:
		var target_position = raycast.global_transform.origin + raycast.global_transform.basis.y * -grab_distance
		var direction = target_position - grabbed_object.global_transform.origin
		grabbed_object.linear_velocity = direction * 10.0
	
	if Input.is_action_just_pressed(album_open_close):
		state = PlayerState.ALBUM
		album_obj.visible = true
		animation_player.play("album_open")
		await animation_player.animation_finished
	
	if Input.is_action_just_pressed(open_close_camera):
		state = PlayerState.CAMERA
		
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print(collider)
		if collider != null: 
			if collider.is_in_group("p0_piece"):
				crosshair(true)
				if not grabbed_object and not just_released:
					if Input.is_action_just_pressed(input_left_click):	
						grabbed_object = collider
				if grabbed_object and not grabbed_object.visible:
					grabbed_object = null
			elif collider.is_in_group("p1_buttons"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.pressed_button()
			elif collider.is_in_group("p2_highlight"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.pressed_button()
			elif collider.is_in_group("p3_computer"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					crosshair(false)
					enter_terminal(collider)
			elif collider.is_in_group("p6_crowbar"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.grab_crowbar()
					$Head/Camera3D/Crowbar.visible = true
					has_crowbar = true
			elif collider.is_in_group("p4_piano"):
				crosshair_piano(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.play_note()
			elif collider.is_in_group("letters"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					sequence_p3 = collider.on_click_letter(sequence_p3)
			elif collider.is_in_group("countries"):
				crosshair_piano(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.country_click_highlight()
			elif collider.is_in_group("wrong_countries"):
				crosshair_piano(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.country_wrong_highlight()
			elif collider.is_in_group("final_door_interact"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					show_interaction_text("Esta cerrado")
			elif collider.is_in_group("ending"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					state = PlayerState.ENDING
					player_camera.current = false
					clean_ui()
					collider.grand_final()
			elif collider.is_in_group("khachkars"):
				crosshair(true)
				if Input.is_action_just_pressed(input_left_click):
					collider.khachkar_photo(has_crowbar)
					if has_crowbar and collider.name == "collisionKhachkar6":
						$Head/Camera3D/Crowbar.visible = false
					if not has_crowbar and collider.name == "collisionKhachkar6":
						show_interaction_text("Nesecito algo para poder sacarlo")
			else:
				crosshair(false)
		else:
			crosshair(false)
	else:
		crosshair(false)
				
	move_and_slide()
	
	just_released = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(input_left_click) and grabbed_object:
		grabbed_object = null
		just_released = true
		
func enter_terminal(terminal_node):
	state = PlayerState.TERMINAL
	can_move = false
	can_jump = false
	current_terminal = terminal_node
	
	player_camera.current = false
	terminal_node.terminal_camera.current = true
	
	terminal_node.terminal_input.show()
	terminal_node.terminal_instructions.show()
	terminal_node.terminal_input.grab_focus()
	capture_mouse()

func exit_terminal():
	if current_terminal == null:
		return
		
	current_terminal.terminal_camera.current = false
	player_camera.current = true
	
	current_terminal.terminal_input.hide()
	current_terminal.terminal_instructions.hide()
	state = PlayerState.NORMAL
	can_move = true
	can_jump = true
	current_terminal = null
	capture_mouse()

func _on_terminal_text_entered(text: String):
	if current_terminal == null:
		return

	var command = text.strip_edges().to_lower()
	
	print(text)
	current_terminal.terminal_input.text = ""

	if command == "esc":
		exit_terminal()
		return

func crosshair(wich: bool):
	if wich:
		crosshair_normal.visible = false
		crosshair_pick.visible = true
		UI_clickRemember.visible = true
	elif grabbed_object: 
		crosshair_normal.visible = false
		crosshair_pick.visible = true
		UI_clickRemember.visible = true
	else:
		crosshair_normal.visible = true
		crosshair_pick.visible = false
		crosshair_pick_piano.visible = false
		UI_clickRemember.visible = false

func crosshair_piano(wich: bool):
	if wich:
		crosshair_normal.visible = false
		crosshair_pick_piano.visible = true
		UI_clickRemember.visible = true
	else:
		crosshair_normal.visible = true
		crosshair_pick.visible = false
		crosshair_pick_piano.visible = false
		UI_clickRemember.visible = false

func clean_ui():
	crosshair_normal.visible = false
	crosshair_pick.visible = false
	crosshair_pick_piano.visible = false
	UI_clickRemember.visible = false
	UI_textRemember.visible = false
	
		
func show_interaction_text(text: String):
	UI_textRemember.text = text
	UI_textRemember.visible = true
	await get_tree().create_timer(5.0).timeout
	UI_textRemember.visible = false

func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
