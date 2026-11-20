extends RefCounted
## Modelo humanoide procedural mais detalhado para substituir o boneco em cubos.
## Mantem o corpo separado das animacoes leves de membros de CharacterMotion.
static func _material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.87
	m.metallic = metallic
	return m

static func _oval(parent: Node3D, position: Vector3, scale: Vector3, color: Color, name: String) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 22
	shape.rings = 12
	node.mesh = shape
	node.position = position
	node.scale = scale
	node.material_override = _material(color)
	node.name = name
	parent.add_child(node)
	return node

static func _strap(parent: Node3D, position: Vector3, size: Vector3, color: Color, name: String) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	node.mesh = box
	node.position = position
	node.material_override = _material(color)
	node.name = name
	parent.add_child(node)
	return node

static func create_body(parent: Node3D) -> MeshInstance3D:
	var torso := _oval(parent,Vector3(0,1.22,0),Vector3(1.17,1.28,0.74),Color("596b63"),"JaquetaDeExplorador")
	_oval(parent,Vector3(0,0.68,-0.025),Vector3(0.94,0.46,0.79),Color("3d484c"),"Quadril")
	_oval(parent,Vector3(0,1.88,-0.04),Vector3(0.24,0.28,0.25),Color("a97d61"),"Pescoco")
	_oval(parent,Vector3(0,2.11,-0.025),Vector3(0.57,0.65,0.55),Color("b99173"),"Rosto")
	_oval(parent,Vector3(0,2.35,-0.04),Vector3(0.61,0.25,0.60),Color("202d2c"),"Cabelo")
	_oval(parent,Vector3(0.0,2.25,-0.27),Vector3(0.46,0.25,0.25),Color("283534"),"Franja")
	_oval(parent,Vector3(0,2.08,-0.32),Vector3(0.18,0.20,0.22),Color("b58a70"),"Nariz")
	for side in [-1.0,1.0]:
		_oval(parent,Vector3(side*0.30,2.09,-0.045),Vector3(0.12,0.22,0.20),Color("b18a6e"),"Orelha")
		_oval(parent,Vector3(side*0.137,2.14,-0.270),Vector3(0.09,0.07,0.042),Color("353a37"),"Olho")
		_strap(parent,Vector3(side*0.36,1.26,0.42),Vector3(0.115,0.99,0.07),Color("2e3c3c"),"AlcaDaMochila")
		_oval(parent,Vector3(side*0.51,1.65,0.01),Vector3(0.37,0.31,0.43),Color("64776b"),"Ombreira")
	_strap(parent,Vector3(0,0.95,-0.00),Vector3(0.85,0.10,0.77),Color("5e4935"),"Cinto")
	_strap(parent,Vector3(0,0.95,-0.397),Vector3(0.18,0.14,0.04),Color("c1a271"),"Fivela")
	_oval(parent,Vector3(0,1.11,0.46),Vector3(0.92,1.10,0.55),Color("2e4d47"),"Mochila")
	_strap(parent,Vector3(0,1.45,0.744),Vector3(0.80,0.085,0.07),Color("9e8d65"),"FaixaDaMochila")
	_strap(parent,Vector3(0,1.07,0.744),Vector3(0.80,0.085,0.07),Color("9e8d65"),"FechoDaMochila")
	_strap(parent,Vector3(0,1.18,-0.378),Vector3(0.12,0.64,0.047),Color("9ba89b"),"Ziper")
	return torso
