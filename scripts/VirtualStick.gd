extends Control
## Joystick virtual multitoque para a versao Android.
var amount: Vector2 = Vector2.ZERO
var pointer := -1
const DEAD_ZONE := 0.12

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius: float = minf(size.x, size.y) * 0.43
	draw_circle(center, radius, Color(0.03, 0.13, 0.16, 0.43))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.61, 0.87, 0.94, 0.68), 3.0, true)
	draw_circle(center + amount * radius * 0.70, radius * 0.32, Color(0.55, 0.82, 0.93, 0.84))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and pointer < 0:
			pointer = event.index
			_move_joystick(event.position)
			accept_event()
		elif not event.pressed and event.index == pointer:
			pointer = -1
			amount = Vector2.ZERO
			queue_redraw()
			accept_event()
	elif event is InputEventScreenDrag and event.index == pointer:
		_move_joystick(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pointer = 999
			_move_joystick(event.position)
		else:
			pointer = -1
			amount = Vector2.ZERO
			queue_redraw()
		accept_event()
	elif event is InputEventMouseMotion and pointer == 999:
		_move_joystick(event.position)
		accept_event()

func _move_joystick(p: Vector2) -> void:
	var radius: float = minf(size.x, size.y) * 0.43
	amount = ((p - size * 0.5) / radius).limit_length(1.0)
	if amount.length() < DEAD_ZONE:
		amount = Vector2.ZERO
	queue_redraw()
