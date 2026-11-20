extends Node3D
## Palmeiras costeiras com frondes trianguladas e instanciamento eficiente.
## Uma evolução da vegetação genérica; usa malhas procedurais leves.
var height_at: Callable
var count := 28
var seed := 77812

func configure(height_cb: Callable, amount: int = 28) -> void:
	height_at = height_cb
	count = clampi(amount,0,80)

func _ready() -> void:
	if count == 0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var trunks := _create_trunk()
	var leaves := _create_fronds()
	var trunk_instances := MultiMesh.new()
	trunk_instances.transform_format = MultiMesh.TRANSFORM_3D
	trunk_instances.mesh = trunks
	trunk_instances.instance_count = count
	var leaf_instances := MultiMesh.new()
	leaf_instances.transform_format = MultiMesh.TRANSFORM_3D
	leaf_instances.mesh = leaves
	leaf_instances.instance_count = count
	for i in range(count):
		var angle: float = TAU * float(i) / float(count) + rng.randf_range(-0.15,0.15)
		var radius: float = rng.randf_range(32.0,46.0)
		var x := cos(angle)*radius
		var z := sin(angle)*radius
		var y: float = float(height_at.call(x,z)) if height_at.is_valid() else 0.0
		var scale := rng.randf_range(0.87,1.25)
		var rotation := Basis(Vector3.UP,rng.randf_range(0,TAU))
		var transform := Transform3D(rotation.scaled(Vector3(scale,scale,scale)),Vector3(x,y,z))
		trunk_instances.set_instance_transform(i,transform)
		leaf_instances.set_instance_transform(i,transform)
	var trunk_node := MultiMeshInstance3D.new()
	trunk_node.name = "TroncosPalmeiras"
	trunk_node.multimesh = trunk_instances
	add_child(trunk_node)
	var crowns := MultiMeshInstance3D.new()
	crowns.name = "FolhasPalmeiras"
	crowns.multimesh = leaf_instances
	add_child(crowns)

func _create_trunk() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.98
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(material)
	for level in range(8):
		var t1 := float(level)/8.0
		var t2 := float(level+1)/8.0
		var y1 := 5.1*t1
		var y2 := 5.1*t2
		var r1 := 0.29 - t1*0.12
		var r2 := 0.29 - t2*0.12
		var center1 := Vector3(t1*t1*0.48,y1,0)
		var center2 := Vector3(t2*t2*0.48,y2,0)
		for k in range(9):
			var a := TAU*float(k)/9.0
			var b := TAU*float(k+1)/9.0
			var c := Color("826140").lerp(Color("a18456"),0.25 if level%2==0 else 0.55)
			_triangle(st,center1+Vector3(cos(a)*r1,0,sin(a)*r1),center2+Vector3(cos(a)*r2,0,sin(a)*r2),center1+Vector3(cos(b)*r1,0,sin(b)*r1),c)
			_triangle(st,center1+Vector3(cos(b)*r1,0,sin(b)*r1),center2+Vector3(cos(a)*r2,0,sin(a)*r2),center2+Vector3(cos(b)*r2,0,sin(b)*r2),c)
	st.generate_normals()
	return st.commit()

func _create_fronds() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.91
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(mat)
	var top := Vector3(0.48,5.0,0.0)
	for i in range(10):
		var angle := TAU*float(i)/10.0
		var direction := Vector3(cos(angle),0,sin(angle))
		var side := Vector3(-direction.z,0,direction.x)
		var hue := Color("3b834d") if i%3==0 else Color("2c7547")
		for part in range(6):
			var t0 := float(part)/6.0
			var t1 := float(part+1)/6.0
			var length := 3.1
			var p0 := top + direction * (length*t0) + Vector3(0,0.55*sin(t0*PI)-0.95*t0*t0,0)
			var p1 := top + direction * (length*t1) + Vector3(0,0.55*sin(t1*PI)-0.95*t1*t1,0)
			var w0 := 0.03+0.45*sin(t0*PI)
			var w1 := 0.03+0.45*sin(t1*PI)
			var c := hue.lerp(Color("78ae62"),t1*0.37)
			_triangle(st,p0-side*w0,p0+side*w0,p1+side*w1,c)
			_triangle(st,p0-side*w0,p1+side*w1,p1-side*w1,c)
	st.generate_normals()
	return st.commit()

func _triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	st.set_color(color)
	st.add_vertex(a)
	st.set_color(color)
	st.add_vertex(b)
	st.set_color(color)
	st.add_vertex(c)
