extends Node3D
## Construção modular jogável: pisos, paredes, portas, telhados, física e saves.
## Usa grade de 3 metros. O aspecto visual ainda é provisório.
const CELL := 3.0
const MAX_PIECES := 72
var height_at: Callable
var records: Array[Dictionary] = []
var ghost: MeshInstance3D
var last_error := ""
var wood := Color("806044")
var trim := Color("513e2d")
var roof_tint := Color("465c53")
var glow_good := Color(0.15,0.94,0.76,0.40)
var glow_bad := Color(0.99,0.27,0.25,0.40)

func configure(height_function: Callable) -> void:
	height_at = height_function

func _ready() -> void:
	ghost = MeshInstance3D.new()
	ghost.name = "PreviaConstrucao"
	ghost.mesh = BoxMesh.new()
	var ghost_material := StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ghost_material.albedo_color = glow_good
	ghost.material_override = ghost_material
	ghost.visible = false
	add_child(ghost)

func snap(point: Vector3) -> Vector3:
	var x: float = roundf(point.x / CELL) * CELL
	var z: float = roundf(point.z / CELL) * CELL
	return Vector3(x, float(height_at.call(x,z)) if height_at.is_valid() else point.y,z)

func candidate(source: Node3D) -> Vector3:
	var p: Vector3 = source.global_position + (source.global_transform.basis * Vector3(0,0,-4.1))
	return snap(p)

func _type_allowed(kind: String) -> bool:
	return ["piso","parede","porta","teto"].has(kind)

func _key(kind: String, center: Vector3, side: int) -> String:
	var x := int(round(center.x / CELL))
	var z := int(round(center.z / CELL))
	return "%s:%d:%d:%d" % [kind,x,z,side if kind in ["parede","porta"] else 0]

func _find(kind: String, center: Vector3, side: int = 0) -> Dictionary:
	var key: String = _key(kind,center,side)
	for record in records:
		if String(record.get("key","")) == key:
			return record
	return {}

func _has_floor(center: Vector3) -> bool:
	return not _find("piso",center,0).is_empty()

func can_place(kind: String, center: Vector3, side: int = 0) -> bool:
	last_error = ""
	if not _type_allowed(kind):
		last_error = "Peça não reconhecida."
		return false
	if records.size() >= MAX_PIECES:
		last_error = "Limite de estruturas desta ilha atingido."
		return false
	if center.y < 0.40:
		last_error = "Construa acima da faixa de maré."
		return false
	var orientation: int = posmod(side,4)
	if not _find(kind,center,orientation).is_empty():
		last_error = "Já existe uma peça nesta posição."
		return false
	if kind == "piso":
		var h1: float = float(height_at.call(center.x+1.25,center.z+1.25))
		var h2: float = float(height_at.call(center.x-1.25,center.z-1.25))
		if absf(h1-h2) > 1.8:
			last_error = "Terreno íngreme: escolha um local plano."
			return false
		return true
	if not _has_floor(center):
		last_error = "Construa primeiro um piso nessa célula."
		return false
	if kind in ["parede","porta"]:
		if not _find("parede",center,orientation).is_empty() or not _find("porta",center,orientation).is_empty():
			last_error = "Essa borda já está ocupada."
			return false
	return true

func _material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = metallic
	return mat

func _solid(parent: Node3D, offset: Vector3, size: Vector3, color: Color, physics: bool = true) -> Node3D:
	var host := Node3D.new()
	host.position = offset
	parent.add_child(host)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _material(color)
	host.add_child(mesh)
	if physics:
		var solid := StaticBody3D.new()
		host.add_child(solid)
		var shape := CollisionShape3D.new()
		var collision := BoxShape3D.new()
		collision.size = size
		shape.shape = collision
		solid.add_child(shape)
	return host

func _wood_panels(parent: Node3D, width: float, y: float, z: float, vertical: bool) -> void:
	for i in range(5):
		if vertical:
			_solid(parent,Vector3(-width*0.4+float(i)*width*0.2,y,z),Vector3(width*0.2-0.012,2.45,0.12),wood,false)
		else:
			_solid(parent,Vector3(0,y,z-width*0.40+float(i)*width*0.2),Vector3(width*0.2,0.12,width*0.2-0.012),wood,false)

func _side_transform(side: int) -> Transform3D:
	var b := Basis(Vector3.UP,float(posmod(side,4))*PI*0.5)
	return Transform3D(b,b*Vector3(0,0,-CELL*0.5))

func place_piece(kind: String, center: Vector3, side: int = 0, opened: bool = false) -> bool:
	if not can_place(kind,center,side):
		return false
	var house := Node3D.new()
	house.name = "Modulo_%s_%d" % [kind,records.size()]
	house.position = center
	add_child(house)
	var orientation: int = posmod(side,4)
	var door: Node3D = null
	var door_shape: CollisionShape3D = null
	match kind:
		"piso":
			_solid(house,Vector3(0,0.16,0),Vector3(2.94,0.32,2.94),trim,true)
			for i in range(5):
				_solid(house,Vector3(-1.18+float(i)*0.59,0.34,0),Vector3(0.57,0.06,2.85),wood,false)
		"parede":
			var side_node := Node3D.new()
			side_node.transform = _side_transform(orientation)
			house.add_child(side_node)
			_solid(side_node,Vector3(0,1.55,0),Vector3(3.0,2.6,0.16),wood,true)
			for x in [-1.43,1.43]:
				_solid(side_node,Vector3(x,1.55,-0.03),Vector3(0.12,2.75,0.25),trim,false)
			for y in [0.35,2.87]:
				_solid(side_node,Vector3(0,y,-0.03),Vector3(3.0,0.15,0.25),trim,false)
		"porta":
			var side_node := Node3D.new()
			side_node.transform = _side_transform(orientation)
			house.add_child(side_node)
			_solid(side_node,Vector3(-1.22,1.55,0),Vector3(0.56,2.6,0.18),wood,true)
			_solid(side_node,Vector3(1.22,1.55,0),Vector3(0.56,2.6,0.18),wood,true)
			_solid(side_node,Vector3(0,2.7,0),Vector3(1.94,0.3,0.2),wood,true)
			door = Node3D.new()
			door.name = "PortaArticulada"
			door.position = Vector3(-0.92,0.20,0.04)
			side_node.add_child(door)
			_solid(door,Vector3(0.90,1.11,0),Vector3(1.8,2.17,0.12),Color("986e45"),true)
			_solid(door,Vector3(1.55,1.1,-0.13),Vector3(0.12,0.13,0.12),Color("d2a562"),false)
		"teto":
			_solid(house,Vector3(0,3.03,0),Vector3(3.2,0.21,3.2),roof_tint,true)
			for i in range(4):
				_solid(house,Vector3(-1.15+float(i)*0.76,3.17,0),Vector3(0.05,0.09,3.3),Color("759089"),false)
	var entry := {"kind":kind,"center":[center.x,center.y,center.z],"side":orientation,"opened":opened,"node":house,"key":_key(kind,center,orientation),"door":door}
	records.append(entry)
	if opened and door != null:
		door.rotation.y = -1.35
	return true

func toggle_door_near(position: Vector3) -> bool:
	var nearest_dist := 4.0
	var target := -1
	for i in range(records.size()):
		var record: Dictionary = records[i]
		if record["kind"] != "porta":
			continue
		var structure: Node3D = record["node"]
		var dist: float = position.distance_to(structure.global_position)
		if dist < nearest_dist:
			target = i
			nearest_dist = dist
	if target < 0:
		return false
	var record: Dictionary = records[target]
	var opened := not bool(record["opened"])
	record["opened"] = opened
	var door: Node3D = record["door"]
	var tween := create_tween()
	tween.tween_property(door,"rotation:y",-1.35 if opened else 0.0,0.32).set_trans(Tween.TRANS_SINE)
	return true

func set_preview(kind: String, center: Vector3, side: int, show: bool) -> void:
	if not is_instance_valid(ghost):
		return
	ghost.visible = show and _type_allowed(kind)
	if not ghost.visible:
		return
	ghost.position = center
	ghost.rotation.y = 0.0
	match kind:
		"piso":
			ghost.position.y += 0.16
			(ghost.mesh as BoxMesh).size = Vector3(2.94,0.32,2.94)
		"teto":
			ghost.position.y += 3.03
			(ghost.mesh as BoxMesh).size = Vector3(3.2,0.21,3.2)
		_:
			ghost.transform = Transform3D(Basis(),center) * _side_transform(side)
			ghost.position.y += 1.5
			(ghost.mesh as BoxMesh).size = Vector3(3.0,2.6,0.22)
	var mat: StandardMaterial3D = ghost.material_override
	mat.albedo_color = glow_good if can_place(kind,center,side) else glow_bad

func serialize() -> Array:
	var data := []
	for r in records:
		data.append({"kind":r["kind"],"center":r["center"],"side":r["side"],"opened":r["opened"]})
	return data

func restore(data: Array) -> void:
	clear_pieces()
	for record in data:
		if not record is Dictionary:
			continue
		var p: Array = record.get("center",[])
		if p.size() != 3:
			continue
		var center := Vector3(float(p[0]),float(p[1]),float(p[2]))
		place_piece(str(record.get("kind","")),center,int(record.get("side",0)),bool(record.get("opened",false)))

func clear_pieces() -> void:
	for record in records:
		var node: Node3D = record["node"]
		if is_instance_valid(node):
			node.queue_free()
	records.clear()
	set_preview("",Vector3.ZERO,0,false)
