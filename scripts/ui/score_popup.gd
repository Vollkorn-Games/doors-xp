extends Label

## Floating score text that rises and fades out.
## Created via the static create() method called from desktop.gd.

const _Self := preload("res://scripts/ui/score_popup.gd")

var _velocity: Vector2 = Vector2(0, -80)
var _lifetime: float = 1.2
var _elapsed: float = 0.0


func _ready() -> void:
	z_index = 100
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 20)


func _process(delta: float) -> void:
	_elapsed += delta
	position += _velocity * delta
	_velocity.y *= 0.97  # Slow down

	var progress: float = _elapsed / _lifetime
	modulate.a = 1.0 - ease(progress, 2.0)

	# Scale up then settle
	if progress < 0.2:
		scale = Vector2.ONE * lerpf(0.5, 1.2, progress / 0.2)
	elif progress < 0.4:
		scale = Vector2.ONE * lerpf(1.2, 1.0, (progress - 0.2) / 0.2)

	if _elapsed >= _lifetime:
		queue_free()


static func create(msg: String, color: Color, font_size: int = 20) -> Label:
	var popup: Label = _Self.new()
	popup.text = msg
	popup.add_theme_color_override("font_color", color)
	popup.add_theme_font_size_override("font_size", font_size)
	# Add a dark outline for readability
	popup.add_theme_constant_override("outline_size", 3)
	popup.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
	return popup
