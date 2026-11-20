extends Node3D
## Direcao visual da ilha: terreno sombreado, ceu, ondas, rochas, vegetacao
## instanciada e instalacao antiga. Substitui a geometria de cubos/bolas da v0.1.
## Um estilo naturalista procedural inicial; NAO equivale a modelos AAA/PBR fotorrealistas.
var height_at: Callable
var tree_count := 130
var sun: DirectionalLight3D
var scenery_rng := RandomNumberGenerator.new()

func configure(terrain_height: Callable, trees: int) -> void:
	height_at = terrain_height
	tree_count = maxi(60, trees)

func _ready() -> void:
	scenery_rng.seed = 20261120
	_environment()
	_terrain()
	_ocean()
	_trees()
	_rocks()
	_grass()
	_relic_station()

func _height(x: float, z: float) -> float:
	if height_at.is_valid():
		return float(height_at.call(x,z))
	return 0.0

func _surface(color: Color, roughness: float = 0.92, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m

func _box(parent: Node3D, pos: Vector3, dimensions: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var obj := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	obj.mesh = mesh
	obj.position = pos
	obj.material_override = _surface(color,0.83,metallic)
	parent.add_child(obj)
	return obj

func _environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("2e607f")
	sky_mat.sky_horizon_color = Color("a9cdd0")
	sky_mat.ground_bottom_color = Color("304b45")
	sky_mat.ground_horizon_color = Color("9bbcb1")
	sky_mat.use_debanding = true
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("a7bac0")
	env.fog_density = 0.008
	world.environment = env
	add_child(world)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-31,-3)
	sun.light_color = Color("ffeac7")
	sun.light_energy = 1.45
	sun.shadow_enabled = true
	add_child(sun)

func _terrain() -> void:
	var steps := 134
	var extent := 76.0
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var triangles := PackedInt32Array()
	for iz in range(steps+1):
		for ix in range(steps+1):
			var x := (float(ix)/float(steps)*2.0-1.0)*extent
			var z := (float(iz)/float(steps)*2.0-1.0)*extent
			var h := _height(x,z)
			vertices.append(Vector3(x,h,z))
			normals.append(Vector3(_height(x-0.25,z)-_height(x+0.25,z),0.5,_height(x,z-0.25)-_height(x,z+0.25)).normalized())
			uvs.append(Vector2(x/8.0,z/8.0))
			var beach := Color("c5b78a")
			var grass := Color("436b4a")
			var rock := Color("6c7873")
			var fade := smoothstep(-0.4,2.5,h)
			var tint := beach.lerp(grass,fade)
			if h > 7.6:
				tint = tint.lerp(rock,clampf((h-7.6)/5.0,0.0,0.57))
			colors.append(tint)
	for iz in range(steps):
		for ix in range(steps):
			var a := iz*(steps+1)+ix
			triangles.append_array(PackedInt32Array([a,a+steps+1,a+1,a+1,a+steps+1,a+steps+2]))
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_COLOR] = colors
	arr[Mesh.ARRAY_INDEX] = triangles
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arr)
	var mat := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
float hash21(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123); }
float noise21(vec2 p) {
	vec2 i=floor(p), f=fract(p);
	f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1.0,0.0)),f.x),mix(hash21(i+vec2(0.0,1.0)),hash21(i+vec2(1.0,1.0)),f.x),f.y);
}
void fragment() {
	float n=noise21(UV*5.2);
	float fine=noise21(UV*27.0);
	vec3 base=COLOR.rgb;
	ALBEDO=base*(0.76+0.36*n+0.13*fine);
	ROUGHNESS=0.94;
	METALLIC=0.0;
}
"""
	mat.shader = shader
	var ground := MeshInstance3D.new()
	ground.name = "TerrenoNatural"
	ground.mesh = mesh
	ground.material_override = mat
	add_child(ground)
	var physics := StaticBody3D.new()
	physics.name = "ColisaoDoTerreno"
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	physics.add_child(shape)
	add_child(physics)

func _ocean() -> void:
	var surface := MeshInstance3D.new()
	surface.name = "MarComOndas"
	var plane := PlaneMesh.new()
	plane.size = Vector2(430,430)
	plane.subdivide_width = 80
	plane.subdivide_depth = 80
	surface.mesh = plane
	surface.position.y = -1.18
	var water := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;
varying float ripple;
void vertex() {
	float w=sin(VERTEX.x*0.13+TIME*0.48)*0.11+cos(VERTEX.z*0.19+TIME*0.59)*0.10;
	VERTEX.y+=w;
	ripple=w;
}
void fragment() {
	float band=sin(UV.x*220.0+TIME*0.65+sin(UV.y*160.0))*0.06;
	vec3 deep=vec3(0.015,0.23,0.32);
	vec3 aqua=vec3(0.055,0.39,0.46);
	ALBEDO=mix(deep,aqua,0.50+ripple*0.8+band);
	ROUGHNESS=0.18;
	METALLIC=0.17;
	ALPHA=0.88;
}
"""
	water.shader = shader
	surface.material_override = water
	add_child(surface)

func _multimesh(mesh: Mesh, total: int) -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = total
	return mm

func _trees() -> void:
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.13
	trunk_mesh.bottom_radius = 0.31
	trunk_mesh.height = 3.8
	trunk_mesh.radial_segments = 9
	var trunk_mat := _surface(Color.WHITE)
	trunk_mat.vertex_color_use_as_albedo = true
	trunk_mesh.material = trunk_mat
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.0
	crown_mesh.height = 1.9
	crown_mesh.radial_segments = 12
	crown_mesh.rings = 8
	var leaf_mat := _surface(Color.WHITE)
	leaf_mat.vertex_color_use_as_albedo = true
	crown_mesh.material = leaf_mat
	var trunks := _multimesh(trunk_mesh,tree_count)
	var leaves := _multimesh(crown_mesh,tree_count*3)
	for i in range(tree_count):
		var x := scenery_rng.randf_range(-58.0,58.0)
		var z := scenery_rng.randf_range(-58.0,58.0)
		if Vector2(x,z).length() > 56.0 or (absf(x) < 8 and z > 12 and z < 32):
			x = scenery_rng.randf_range(-41,-13)
			z = scenery_rng.randf_range(-29,10)
		var y := _height(x,z)
		var size_factor := scenery_rng.randf_range(0.88,1.8)
		var t := Transform3D(Basis().scaled(Vector3(size_factor,size_factor,size_factor)),Vector3(x,y+1.9*size_factor,z))
		trunks.set_instance_transform(i,t)
		trunks.set_instance_color(i,Color("614b36").lerp(Color("856a4c"),scenery_rng.randf()))
		for k in range(3):
			var angle := float(k)*TAU/3.0+scenery_rng.randf_range(-0.2,0.2)
			var lean := Vector3(sin(angle)*0.7,3.65+float(k)*0.15,cos(angle)*0.55)*size_factor
			var leaf_factor := scenery_rng.randf_range(1.15,1.75)*size_factor
			var basis := Basis().scaled(Vector3(leaf_factor,leaf_factor*0.73,leaf_factor))
			leaves.set_instance_transform(i*3+k,Transform3D(basis,Vector3(x,y,z)+lean))
			leaves.set_instance_color(i*3+k,Color("285a38").lerp(Color("57825a"),scenery_rng.randf()))
	var stem_inst := MultiMeshInstance3D.new()
	stem_inst.multimesh = trunks
	stem_inst.name = "TroncosInstanciados"
	add_child(stem_inst)
	var canopy_inst := MultiMeshInstance3D.new()
	canopy_inst.multimesh = leaves
	canopy_inst.name = "CopasInstanciadas"
	add_child(canopy_inst)

func _rocks() -> void:
	var rock_mesh := SphereMesh.new()
	rock_mesh.radius = 1.0
	rock_mesh.height = 2.0
	rock_mesh.radial_segments = 9
	rock_mesh.rings = 6
	var rock_mat := _surface(Color.WHITE,1.0)
	rock_mat.vertex_color_use_as_albedo = true
	rock_mesh.material = rock_mat
	var count := 190
	var mm := _multimesh(rock_mesh,count)
	for i in range(count):
		var x := scenery_rng.randf_range(-68,68)
		var z := scenery_rng.randf_range(-68,68)
		var y := _height(x,z)
		var scale := scenery_rng.randf_range(0.28,1.8)
		var size := Vector3(scale,scale*scenery_rng.randf_range(0.40,0.77),scale*scenery_rng.randf_range(0.85,1.65))
		mm.set_instance_transform(i,Transform3D(Basis().rotated(Vector3.UP,scenery_rng.randf_range(-PI,PI)).scaled(size),Vector3(x,y+scale*0.22,z)))
		mm.set_instance_color(i,Color("6a756c").lerp(Color("a8a596"),scenery_rng.randf()))
	var rocks := MultiMeshInstance3D.new()
	rocks.multimesh = mm
	rocks.name = "PedrasNaturais"
	add_child(rocks)

func _grass() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var colors := PackedColorArray()
	for face in range(3):
		var a := float(face)*TAU/3.0
		var direction := Vector3(cos(a),0,sin(a))
		var p0 := -direction*0.26
		var p1 := direction*0.26
		var start := vertices.size()
		vertices.append(p0)
		vertices.append(p1)
		vertices.append(Vector3(0.0,0.85,0.0))
		for k in range(3):
			normals.append(Vector3(0,0,1))
			colors.append(Color("3e7540") if k < 2 else Color("75a765"))
		indices.append_array(PackedInt32Array([start,start+1,start+2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var grass_mat := _surface(Color.WHITE)
	grass_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	grass_mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0,grass_mat)
	var grass_count := 1900
	var mm := _multimesh(mesh,grass_count)
	for i in range(grass_count):
		var x := scenery_rng.randf_range(-64,64)
		var z := scenery_rng.randf_range(-64,64)
		var h := _height(x,z)
		var scale := scenery_rng.randf_range(0.55,1.3)
		var trans := Transform3D(Basis().rotated(Vector3.UP,scenery_rng.randf_range(-PI,PI)).scaled(Vector3(scale,scale,scale)),Vector3(x,h+0.02,z))
		if h < 0.8 or Vector2(x,z).length() > 64:
			trans.origin.y = -25
		mm.set_instance_transform(i,trans)
		mm.set_instance_color(i,Color("819e61").lerp(Color("b4bc75"),scenery_rng.randf()))
	var field := MultiMeshInstance3D.new()
	field.multimesh = mm
	field.name = "CapimInstanciado"
	add_child(field)

func _relic_station() -> void:
	var station := Node3D.new()
	station.name = "InstalacaoAntigaExploravel"
	station.position = Vector3(23.0,_height(23,-16),-16.0)
	add_child(station)
	_box(station,Vector3(0,0.25,0),Vector3(10.0,0.5,9.2),Color("596763"),0.1)
	for x in [-4.2,4.2]:
		for z in [-3.5,3.5]:
			_box(station,Vector3(x,2.3,z),Vector3(0.5,4.6,0.5),Color("424c50"),0.5)
	_box(station,Vector3(0,4.85,0),Vector3(10.4,0.58,9.6),Color("5d6768"),0.45)
	_box(station,Vector3(0,1.9,-3.65),Vector3(8.1,3.6,0.3),Color("728786"),0.45)
	_box(station,Vector3(0,2.4,-3.45),Vector3(4.7,2.0,0.16),Color("315e73"),0.35)
	_box(station,Vector3(0,0.07,6),Vector3(3.0,0.16,5.0),Color("66645c"))
	for i in range(6):
		var col := -3.7+float(i)*1.45
		_box(station,Vector3(col,2.5,-3.27),Vector3(0.08,2.4,0.09),Color("a6c9c6"),0.55)
	var lab := _box(station,Vector3(0,1.2,0.8),Vector3(2.5,1.0,1.5),Color("2c4752"),0.5)
	lab.name = "MesaDeComando"
	var beacon := OmniLight3D.new()
	beacon.light_color = Color("61c2d6")
	beacon.light_energy = 0.9
	beacon.omni_range = 5
	beacon.position = Vector3(0,2.6,0.6)
	station.add_child(beacon)
