extends ColorRect

@export var biome: Biome

func _ready():
    #set color to biome color
    self.color = biome.color if biome else Color.WHITE