extends Node3D
## Recursos coletaveis visuais com geometria simples e identificavel.
## Sem baixar assets externos nem depender da internet no celular.
var kind := ""
var visual: Node3D
var elapsed := 0.0

func _mat(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.86
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 10
	instance.mesh = shape
	instance.material_override = _mat(color)
	instance.position = pos
	parent.add_child(instance)
	return instance

func _sphere(parent: Node3D, pos: Vector3, radius: float, color: Color, roughness: float = 1.0) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	shape.radial_segments = 10
	shape.rings = 5
	instance.mesh = shape
	instance.material_override = _mat(color)
	instance.position = pos
	parent.add_child(instance)
	return instance

func _box(parent: Node3D, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = dimensions
	instance.mesh = shape
	instance.material_override = _mat(color)
	instance.position = pos
	parent.add_child(instance)
	return instance

func configure(resource_kind: String) -> void:
	kind = resource_kind
	visual = Node3D.new()
	visual.name = "ModeloDeRecurso"
	add_child(visual)
	match kind:
		"madeira":
			for i in range(2):
				var log := _cylinder(visual,Vector3(0,0.19,float(i)*0.23-0.1),0.17,0.96,Color("77533a"))
				log.rotation.z = PI/2
				var end := _cylinder(visual,Vector3(0.47,0.19,float(i)*0.23-0.1),0.175,0.04,Color("c29a69"))
				end.rotation.z = PI/2
		"pedra":
			var stone := _sphere(visual,Vector3(0,0.24,0),0.44,Color("899a97"))
			stone.scale = Vector3(1.1,0.68,0.92)
			stone.rotation.y = 0.35
			var highlight := _sphere(visual,Vector3(-0.21,0.37,0.07),0.13,Color("a5b3ab"))
			highlight.scale = Vector3(1.5,0.40,0.65)
		"fibra":
			for i in range(6):
				var a := float(i)*TAU/6
				var fiber := _cylinder(visual,Vector3(sin(a)*0.16,0.32,cos(a)*0.16),0.035,0.64,Color("4c9b53"))
				fiber.rotation.z = sin(a)*0.44
				fiber.rotation.x = cos(a)*0.33
			_sphere(visual,Vector3(0,0.43,0),0.17,Color("529e5c"))
		"comida":
			var fruit := _sphere(visual,Vector3(0,0.30,0),0.29,Color("d99539"))
			fruit.scale = Vector3(0.95,1.1,0.95)
			var leaf := _sphere(visual,Vector3(0.12,0.58,0),0.14,Color("40814d"))
			leaf.scale = Vector3(1.6,0.28,0.55)
			_cylinder(visual,Vector3(0,0.57,0),0.035,0.16,Color("6c5539"))
		"agua":
			var bottle := _cylinder(visual,Vector3(0,0.36,0),0.16,0.60,Color("5ba7c4"))
			bottle.scale = Vector3(0.90,1.0,0.90)
			_cylinder(visual,Vector3(0,0.71,0),0.11,0.12,Color("2a566c"))
			_box(visual,Vector3(0,0.39,0.15),Vector3(0.2,0.22,0.025),Color("add7da"))
		_:
			_sphere(visual,Vector3(0,0.28,0),0.29,Color("d1ba7b"))

func _process(delta: float) -> void:
	if visual == null:
		return
	elapsed += delta
	visual.rotation.y += delta * 0.22
	visual.position.y = sin(elapsed*1.7)*0.033
