extends Spatial

enum WEAPON_SLOTS {MACHETE, GUSTAV_GUN, BLASTER}
var slots_unlocked = {
	WEAPON_SLOTS.MACHETE: true,
	WEAPON_SLOTS.GUSTAV_GUN: true,
	WEAPON_SLOTS.BLASTER: true,
} #this is gd dict formatting

onready var weapons = $Weapons.get_children()
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLos

var cur_slot = 0
var cur_weapon = null
var fire_point : Spatial
var bodies_to_exclude : Array = []

func _ready():
	pass

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _bodies_to_exclude) #initialize all weapons
	
	#repeat this for all weapon alerts except melee
	weapons[WEAPON_SLOTS.BLASTER].connect("fired", self, "alert_nearby_enemies")
	weapons[WEAPON_SLOTS.GUSTAV_GUN].connect("fired", self, "alert_nearby_enemies")
	
	switch_to_weapon_slot(WEAPON_SLOTS.MACHETE)#only works with an always true weapon like the machete
	
func attack(attack_input_just_pressed: bool, attack_input_held: bool): #from weapon script
	if cur_weapon.has_method("attack"): #just in case so it doesn't crash if the weapon has no attack method
		cur_weapon.attack(attack_input_just_pressed, attack_input_held)
	
	
func switch_to_next_weapon():
	cur_slot = (cur_slot + 1) % slots_unlocked.size()
	if !slots_unlocked[cur_slot]:
		switch_to_next_weapon() # we need to make sure here that one weapon is always unlocked or this will go forever
	else:
		switch_to_weapon_slot(cur_slot)
	
func switch_to_last_weapon():
	cur_slot = posmod((cur_slot - 1), slots_unlocked.size()) #same as modulo but wraps around to be positive
	if !slots_unlocked[cur_slot]:
		switch_to_last_weapon() # we need to make sure here that one weapon is always unlocked or this will go forever
	else:
		switch_to_weapon_slot(cur_slot)
	
func switch_to_weapon_slot(slot_ind: int):
	if slot_ind<0 or slot_ind >= slots_unlocked.size():
		return #don't do anything if passed an out of bounds int
	if !slots_unlocked[cur_slot]:
		return # don't do anything if the int passed is not in unlocked slots
	disable_all_weapons()
	cur_weapon = weapons[slot_ind]
	if cur_weapon.has_method("set_active"):
		cur_weapon.set_active()
	else:
		cur_weapon.show()
	
func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()
			
func alert_nearby_enemies():
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert()
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(false)


