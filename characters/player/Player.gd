extends KinematicBody

export var mouse_sens = 0.5 
# export var means that the variable will be adjustable in the editor menu

onready var camera = $Camera 
onready var character_mover = $CharacterMover
#onready is used to reference a child of the node that this script extends so the engine will wait until that node is loaded in
# the $ is used to reference the node, by giving the name of the node

func _ready(): #ready is called when the scene is ready
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # mouse is hidden and stuck in the center of the screen, so you need the esc exit cmd
	character_mover.init(self) #initialize the character mover and send it self (KinematicBody)
	
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
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
		

func _input(event):
	# event is basically any event that the computer senses
	# you can go to search help for information on any class
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90) # cant more the camera higher than these angles
