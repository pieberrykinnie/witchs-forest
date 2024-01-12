extends TextureProgressBar

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.hit.connect(update)
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	value = player.hp * 100.0 / player.maxHp
