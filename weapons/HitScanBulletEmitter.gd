extends Spatial

var hit_effect = preload("res://effects/BulletHitEffect.tscn")#preload loads the arg when the scene is loaded # just use load if you're only using it once. preload is for things you'll be loading multiple times.
export var distance = 10000
var bodies_to_exclude = [] #list of bodies to exclude from hit
var damage = 1 #set to 1 because it will be set by the weapon itself (parent)

func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude
	
func fire():
	var space_state = get_world().get_direct_space_state() #gets the world obj and everything in it
	var our_pos = global_transform.origin #gets out position
	var result = space_state.intersect_ray(#this is how you do raycasts
		our_pos, #from here
		our_pos - global_transform.basis.z * distance, #to here
		bodies_to_exclude, #bodies to exclude
		1 + 2 + 4, #collision mask. Go to player node, find layers on the right. world layer is 1, characters later is 2, hitboxes layer is 4. hence.
		true, #intersect with bodies
		true) #intersect with areas
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal) #if the thing we hit has a hurt method, pass damage to that method and normal(e.g spray blood in that direction)
	elif result:
		var hit_effect_inst = hit_effect.instance() #create an instance of the hit effect
		get_tree().get_root().add_child(hit_effect_inst) #get the root world node and add the hit effect instance
		hit_effect_inst.global_transform.origin = result.position #set the global position of the hit effect to be the same as the result
		
		if result.normal.angle_to(Vector3.UP) < 0.00005: #get the angle between the normal and UP
			return #if the thing we hit is a floor, don't do anything because the effect is already oriented correctly for floors
		if result.normal.angle_to(Vector3.DOWN) < 0.00005: #if what we hit is the ceiling
			hit_effect_inst.rotate(Vector3.RIGHT, PI) #rotate to the right by pi (180 deg)
			return
		#vector cross product math:
		#basically we need to use an arbitrary vector3 like UP to compare to, so the previous two conditions were to ensure we don't get a zero at UP-UP or DOWN-UP, which would cause an error
		var y = result.normal
		var x =  y.cross(Vector3.UP)
		var z = x.cross(y)
		# set 3d basis for the vector based on the above math
		hit_effect_inst.global_transform.basis = Basis(x, y, z)
