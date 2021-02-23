extends Spatial

signal dead
signal hurt
signal healed
signal health_changed
signal gibbed

export var max_health = 100
var cur_health = 1

var gib_at = -10

func _ready():
	init() #making sure the init is called on the ready, this doesn't hurt because this specific init can be called twice
	
func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)
	
func hurt(damage: int, dir: Vector3, damage_type="normal"):
	#TODO possible damage type differences?
	if cur_health <= 0:
		return #do nothing, we're dead
	cur_health -= damage
	if cur_health <= gib_at:
		pass #TODO make gib spawner code
		emit_signal("gibbed")
		print('gibbed')
	if cur_health <=0:
		emit_signal("dead")
		print('dead')
	else:
		emit_signal("hurt")
	emit_signal("health_changed", cur_health)
	print('hurt ', damage, 'current health', cur_health)
	
func heal(amount: int):
	if cur_health <=0:
		return #do nothing, we're dead
	cur_health += amount
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", cur_health)
