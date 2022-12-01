extends Spatial

var body_to_move : KinematicBody = null # this is a gd type definition, and it is not required. Just done for readability.

export var move_accel = 4
export var max_speed = 25
var drag = 0.0
export var jump_force = 30
export var gravity = 60

var pressed_jump = false
var move_vec : Vector3 #initialize var move_vec as type Vector3
var velocity : Vector3
var snap_vec : Vector3 #controls how we stick to the ground when we move around
export var ignore_rotation = false #this is basically whether you are moving "forward" or North, on move_vec. different for players and AI.

signal movement_info #signals output information about the node on the signals tab

var frozen = false #when the character dies we want them to stop moving

func _ready():
	drag = float(move_accel) / max_speed #calculates drag for movement
	
func init(_body_to_move: KinematicBody): #basically the root node will pass itself to this script
	body_to_move = _body_to_move
	
func jump():
	pressed_jump = true
	
func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized() #normalized means that it is always a length of 1
	
func _physics_process(delta):
	#DIFFERENCE BETWEEN _process AND _physics_process:
	#_process runs once every frame, and the frame is dependant on the computer
	#_physics_process runs independant of computer speed, at a constant rate
	# think of the movement speed clocked to framerate problem of fallout76
	# best to put input code in _process because input is handled in input frames rather than physics frames
	# is_action_just_pressed will return true for the frame you pressed the action on only if put in _process
	var cur_move_vec = move_vec
	if frozen:
		return
	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	# velocity += the movement accel times the direction we're facing, from which we subtract the velocity times the drag on the horizontal and then for the vertical it's gravity times vector down times the delta
	velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP) # Check Docs. basically moves the character but allows the character to collide with walls without sticking and also still sticking to the ground. 
	
	var grounded = body_to_move.is_on_floor() #does what you think, only updates when move_and_slide is called
	if grounded:
		velocity.y = -0.01 # we need this so that we are keeping the grounded true
	if grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO # so that we don't snap/stick to the ground anymore
	else:
		snap_vec = Vector3.DOWN # so we will stick to the ground if we haven't just jumped
	pressed_jump = false #so pressed_jump can only ever be true for one physics frame
	emit_signal("movement_info",velocity,grounded)
	
func freeze():
	frozen = true
	
	#TODO make sure the character falls to the ground and doesn't freeze in midair
	
func unfreeze():
	frozen = false
	
