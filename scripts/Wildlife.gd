extends Node3D
## Animal terrestre pacifico do prototipo. Vagando e evitando o jogador.
## Movimentacao leve: nao usa fisica cara nem scripts de combate.
var player: Node3D
var height_at: Callable
var home: Vector3
var wander_dir := Vector3.FORWARD
var clock := 0.0
var rest_timer := 0.0
var rng := RandomNumberGenerator.new()
var state := "explorar"
var visuals: Node3D

func _ready() -> void:
	home = global_position
	rng.seed = int(absf(position.x * 919.0 + position.z * 327.0)) + 40
	visuals = Node3D.new()
	add_child(visuals)
	var body := MeshInstance3D.new()
	var torso := SphereMesh.new()
	torso.radius = 0.65
	torso.height = 1.45
	torso.radial_segments = 10
	torso.rings = 5
	body.mesh = torso
	body.position = Vector3(0,0.72,0)
	body.scale = Vector3(0.9,0.8,1.4)
	body.material_override = _material(Color("a27b56"))
	visuals.add_child(body)
	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.38
	sphere.height = 0.75
	sphere.radial_segments = 8
	sphere.rings = 4
	head.mesh = sphere
	head.position = Vector3(0,0.8,-0.86)
	head.material_override = _material(Color("b48d62"))
	visuals.add_child(head)
	for x in [-0.43,0.43]:
		for z in [-0.6,0.6]:
			var leg := MeshInstance3D.new()
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.13
			cylinder.bottom_radius = 0.15
			cylinder.height = 0.48
			cylinder.radial_segments = 6
			leg.mesh = cylinder
			leg.position = Vector3(x,0.24,z)
			leg.material_override = _material(Color("785d44"))
			visuals.add_child(leg)
	wander_dir = Vector3(rng.randf_range(-1.0,1.0),0,rng.randf_range(-1.0,1.0)).normalized()
	clock = rng.randf_range(2,5)

func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	return mat

func _process(delta: float) -> void:
	if not height_at.is_valid():
		return
	clock -= delta
	if clock <= 0:
		clock = rng.randf_range(2.0,6.0)
		wander_dir = Vector3(rng.randf_range(-1.0,1.0),0,rng.randf_range(-1.0,1.0)).normalized()
		rest_timer = rng.randf_range(0,2)
	var close := is_instance_valid(player) and player.global_position.distance_to(global_position) < 7.0
	var speed := 0.65
	if close:
		state = "evitar_jogador"
		wander_dir = (global_position - player.global_position).normalized()
		wander_dir.y = 0
		speed = 2.0
	elif rest_timer > 0:
		state = "descansar"
		rest_timer -= delta
		return
	else:
		state = "explorar"
	if global_position.distance_to(home) > 16:
		wander_dir = (home - global_position).normalized()
		wander_dir.y = 0
	var next_pos := global_position + wander_dir.normalized() * speed * delta
	if next_pos.length() < 59:
		global_position.x = next_pos.x
		global_position.z = next_pos.z
		global_position.y = float(height_at.call(global_position.x,global_position.z))
	visuals.rotation.y = lerp_angle(visuals.rotation.y,atan2(-wander_dir.x,-wander_dir.z),minf(1.0,delta*5))
