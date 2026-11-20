extends Node3D
## Animacoes leves e procedurais. Sao animacoes de jogo reais, sem videos.
## A malha e provisoria; modelos glTF poderao substitui-la sem mudar a logica.
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var rig: Node3D
var camera_arms: Node3D
var elapsed := 0.0
var previous_motion := 0.0
var state := "parado"

func _skin(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.92
	return m

func _capsule(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.18
	mesh.height = 1.10
	mesh.radial_segments = 8
	mesh.rings = 4
	obj.mesh = mesh
	obj.position = pos
	obj.scale = size
	obj.material_override = _skin(color)
	parent.add_child(obj)
	return obj

func configure(camera: Camera3D) -> void:
	rig = Node3D.new()
	rig.name = "AnimationRig"
	add_child(rig)
	left_arm = Node3D.new()
	right_arm = Node3D.new()
	left_leg = Node3D.new()
	right_leg = Node3D.new()
	left_arm.position = Vector3(-0.53,1.55,0.0)
	right_arm.position = Vector3(0.53,1.55,0.0)
	left_leg.position = Vector3(-0.22,0.82,0)
	right_leg.position = Vector3(0.22,0.82,0)
	rig.add_child(left_arm)
	rig.add_child(right_arm)
	rig.add_child(left_leg)
	rig.add_child(right_leg)
	_capsule(left_arm,Vector3(-0.06,-0.39,0),Vector3(0.83,0.68,0.9),Color("6b7c78"))
	_capsule(right_arm,Vector3(0.06,-0.39,0),Vector3(0.83,0.68,0.9),Color("6b7c78"))
	_capsule(left_leg,Vector3(0,-0.29,0),Vector3(1.0,0.70,1.0),Color("354450"))
	_capsule(right_leg,Vector3(0,-0.29,0),Vector3(1.0,0.70,1.0),Color("354450"))
	camera_arms = Node3D.new()
	camera_arms.name = "FirstPersonHands"
	camera.add_child(camera_arms)
	_capsule(camera_arms,Vector3(-0.36,-0.40,-0.78),Vector3(0.68,0.60,0.66),Color("b78c6d"))
	_capsule(camera_arms,Vector3(0.36,-0.40,-0.78),Vector3(0.68,0.60,0.66),Color("b78c6d"))
	camera_arms.visible = false

func animate_character(delta: float, velocity: Vector3, riding: bool, first_person: bool) -> void:
	if rig == null:
		return
	elapsed += delta
	var ground_speed := Vector2(velocity.x,velocity.z).length()
	var moving := ground_speed > 0.3 or riding
	state = "navegando" if riding else ("andando" if moving else "parado")
	var stride: float = clampf(ground_speed / 5.0,0.0,1.0)
	var swing: float = sin(elapsed * (7.5 + stride * 3.0)) * stride * 0.68
	if riding:
		swing = sin(elapsed * 4.0) * 0.20
	var response := clampf(delta * 12.0,0,1)
	left_arm.rotation.x = lerpf(left_arm.rotation.x,swing,response)
	right_arm.rotation.x = lerpf(right_arm.rotation.x,-swing,response)
	left_leg.rotation.x = lerpf(left_leg.rotation.x,-swing,response)
	right_leg.rotation.x = lerpf(right_leg.rotation.x,swing,response)
	rig.position.y = lerpf(rig.position.y,(0.028 if moving else 0.007)*sin(elapsed*(10.5 if moving else 2.2)),response)
	camera_arms.visible = first_person
	camera_arms.position.y = (-0.025 if moving else 0.0) + sin(elapsed*7.5)*0.008
	camera_arms.rotation.z = sin(elapsed*5.0) * 0.012 if moving else 0.0
