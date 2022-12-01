extends Spatial

export var flash_time = 0.01
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flash_time
	timer.connect("timeout", self, "end_flash")
	hide()
	
func flash():
	timer.start()
	rotation.x = rand_range(0.0, 2*PI) #this will rotate the flash model randomly, not needed for all guns
	show()
	
func end_flash():
	hide()
	
