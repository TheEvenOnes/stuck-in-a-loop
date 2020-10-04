tool
extends Position3D

export(float) var PERIOD: float = 1.0 setget set_period, get_period
export(float) var AMPLITUDE: float = 0.1 setget set_amplitude, get_amplitude
export(Texture) var TEXTURE: Texture setget set_texture, get_texture

onready var _period: float
onready var _amplitude: float

var elapsed: float = 0.0

func set_period(new_period: float) -> void:
	_period = new_period

func get_period() -> float:
	return _period

func set_amplitude(new_amplitude: float) -> void:
	_amplitude = new_amplitude

func get_amplitude() -> float:
	return _amplitude

func set_texture(new_texture: Texture) -> void:
	$Sprite3D.set_texture(new_texture)

func get_texture() -> Texture:
	return $Sprite3D.texture

func _process(delta: float) -> void:
	elapsed += delta
	$Sprite3D.translation.y = sin(elapsed * 2.0 * PI / _period) * _amplitude
