extends KinematicBody

var hotkeys = {
	KEY_1: 0, #these are standard key input codes and can be found in search help
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9
}

export var mouse_sens = 0.5 
# export var means that the variable will be adjustable in the editor menu

onready var camera = $Camera 
onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager
#onready is used to reference a child of the node that this script extends so the engine will wait until that node is loaded in
# the $ is used to reference the node, by giving the name of the node
var dead = false

func _ready(): #ready is called when the scene is ready
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # mouse is hidden and stuck in the center of the screen, so you need the esc exit cmd
	character_mover.init(self) #initialize the character mover and send it self (KinematicBody)
	health_manager.init()
	health_manager.connect("dead", self, "kill") #connects dead variable to kill func i guess
	weapon_manager.init($Camera/FirePoint, [self]) #init weapon manager with firepoint node and bodies 2 exclude
	
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if dead:
		#TODO make sure player falls to the ground and doesn't freeze in midair
		return #don't run any of the movement code
		
	# you wanna put your input code in a seperate script from your movement code so you can re-use the movement code on the AI
	# best to put input code in _process because input is handled in input frames rather than physics frames
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
	character_mover.set_move_vec(move_vec)
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
		
	weapon_manager.attack(
		Input.is_action_just_pressed("attack"),
		Input.is_action_pressed("attack")
		)

func _input(event):
	# event is basically any event that the computer senses
	# you can go to search help for information on any class
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90) # cant more the camera higher than these angles
	if event is InputEventKey and event.pressed:
		if event.scancode in hotkeys:
			weapon_manager.switch_to_weapon_slot(hotkeys[event.scancode])
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_next_weapon()
		if event.button_index == BUTTON_WHEEL_UP:
			weapon_manager.switch_to_last_weapon()
	
func hurt(damage, dir):
	health_manager.hurt(damage, dir)
	
func heal(amount):
	health_manager.heal(amount)
	
func kill():
	dead = true
	character_mover.freeze()
	#TODO make sure the character falls to the ground and doesn't freeze in midair
