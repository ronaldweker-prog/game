extends Node3D

# O RECOMEÇO — protótipo 0.1. Código concentrado para permitir o primeiro build Android.
# Expansões (bases, criaturas, NPCs, céu e subterrâneo) ainda não implementadas.
const SAVE := "user://save.json"
const CONFIG_PATH := "res://config/gameplay.json"
var game_config: Dictionary = {}
var playing := false
var player: CharacterBody3D
var body: MeshInstance3D
var player_visuals: Node3D
var pivot: Node3D
var cam: Camera3D
var hud: CanvasLayer
var menu: Control
var hud_panel: Control
var joystick := Vector2.ZERO
var mobile_look := -1
var first_person := false
var items := {"madeira": 0, "pedra": 0, "fibra": 0, "comida": 0, "agua": 0}
var gathered: Array = []
var pickups: Array = []
var huts: Array = []
var has_tool := false
var raft: Node3D
var aboard := false
var raft_chest := false
var stats := Vector3(100,100,100)
var time_of_day := 0.0
var sun: DirectionalLight3D
var status: Label
var info: Label
var alert: Label
var quality := 0
var autosave := 0.0
var held := {"left": false, "right": false, "forward": false, "back": false}
var key_map := {}
var world_root: Node3D
var icon_materials := {}

func setting(section: String, key: String, fallback: Variant) -> Variant:
	var group: Variant = game_config.get(section, {})
	if group is Dictionary:
		return group.get(key, fallback)
	return fallback

func recipe(name: String, fallback: Dictionary) -> Dictionary:
	var recipes: Variant = game_config.get("recipes", {})
	if recipes is Dictionary:
		var result: Variant = recipes.get(name, fallback)
		if result is Dictionary:
			return result
	return fallback

func cost_text(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for kind in cost:
		parts.append("%d %s" % [int(cost[kind]), String(kind)])
	return ", ".join(parts)

func _load_game_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if parsed is Dictionary:
		game_config = parsed

func _ready() -> void:
	_load_game_config()
	Engine.max_fps = int(setting("visuals", "mobile_fps", 30))
	world_root = Node3D.new()
	world_root.name = "Mundo"
	add_child(world_root)
	_make_world()
	_make_player()
	_make_interface()
	_show_menu(true)

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.92
	return m

func _cube(parent: Node3D, p: Vector3, s: Vector3, c: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = s
	n.mesh = m
	n.material_override = _mat(c)
	n.position = p
	parent.add_child(n)
	return n

func _ball(parent: Node3D, p: Vector3, radius: float, c: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 8
	m.rings = 4
	n.mesh = m
	n.material_override = _mat(c)
	n.position = p
	parent.add_child(n)
	return n

func _height(x: float, z: float) -> float:
	var r := Vector2(x,z).length()
	var t := maxf(0.0, 1.0 - r / 74.0)
	return -2.0 + 13.0 * pow(t, 1.7) + sin(x * 0.18) * cos(z * 0.19) * t

func _make_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("78b6ce")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("b4d5d5")
	env.environment = e
	world_root.add_child(env)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54,-42,0)
	sun.light_energy = 1.25
	sun.shadow_enabled = false
	world_root.add_child(sun)
	var verts := PackedVector3Array()
	var indices := PackedInt32Array()
	var colors := PackedColorArray()
	var side := 62
	for z in range(side + 1):
		for x in range(side + 1):
			var xx := -76.0 + 152.0 * float(x) / float(side)
			var zz := -76.0 + 152.0 * float(z) / float(side)
			var h := _height(xx,zz)
			verts.append(Vector3(xx,h,zz))
			colors.append(Color("c0af7d") if h < 0.5 else Color("3c7750"))
	for z in range(side):
		for x in range(side):
			var a := z * (side + 1) + x
			indices.append_array(PackedInt32Array([a,a+side+1,a+1,a+1,a+side+1,a+side+2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_COLOR] = colors
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var land := MeshInstance3D.new()
	land.mesh = mesh
	var landmat := _mat(Color.WHITE)
	landmat.vertex_color_use_as_albedo = true
	land.material_override = landmat
	world_root.add_child(land)
	var static_ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	static_ground.add_child(shape)
	world_root.add_child(static_ground)
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(420,420)
	water.mesh = plane
	water.position.y = float(setting("world", "ocean_level", -1.2))
	var watmat := _mat(Color("237f9a"))
	watmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	watmat.albedo_color.a = 0.75
	water.material_override = watmat
	world_root.add_child(water)
	var rng := RandomNumberGenerator.new()
	rng.seed = 8675309
	for i in range(int(setting("world", "tree_count", 85))):
		var x := rng.randf_range(-53,53)
		var z := rng.randf_range(-53,53)
		if Vector2(x,z).length() > 61 or (absf(x) < 9 and z > 12 and z < 31):
			continue
		var h := _height(x,z)
		if h < 0.2:
			continue
		var tree := Node3D.new()
		tree.position = Vector3(x,h,z)
		world_root.add_child(tree)
		_cube(tree,Vector3(0,1.45,0),Vector3(0.4,2.9,0.4),Color("69513c"))
		_ball(tree,Vector3(0,3.5,0),1.9,Color("2a6947"))
	_make_pickups()
	var ruins := Node3D.new()
	ruins.position = Vector3(23,_height(23,-16),-16)
	world_root.add_child(ruins)
	_cube(ruins,Vector3(0,0.15,0),Vector3(8,0.3,8),Color("677f84"))
	for xx in [-3.0,3.0]:
		for zz in [-3.0,3.0]:
			_cube(ruins,Vector3(xx,2.2,zz),Vector3(0.5,4.4,0.5),Color("607882"))
	_cube(ruins,Vector3(0,4.5,0),Vector3(8.5,0.45,8.5),Color("6c858c"))

func _make_pickups() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 333
	var kinds := ["madeira","pedra","fibra","comida","agua"]
	for i in range(int(setting("world", "pickup_count", 80))):
		if gathered.has(i):
			continue
		var x := rng.randf_range(-38.0,38.0)
		var z := rng.randf_range(-38.0,38.0)
		if i < 15:
			x = float((i % 5) * 2 - 4)
			z = 22.0 + float(int(i / 5) * 3)
		var kind: String = kinds[i % kinds.size()]
		var n := Node3D.new()
		n.name = "recurso_%d" % i
		n.position = Vector3(x,_height(x,z),z)
		world_root.add_child(n)
		match kind:
			"madeira": _cube(n,Vector3(0,0.25,0),Vector3(0.9,0.35,0.3),Color("866344"))
			"pedra": _ball(n,Vector3(0,0.25,0),0.35,Color("909a98"))
			"fibra": _ball(n,Vector3(0,0.45,0),0.5,Color("55a360"))
			"comida": _ball(n,Vector3(0,0.3,0),0.32,Color("c5a349"))
			"agua": _cube(n,Vector3(0,0.3,0),Vector3(0.34,0.6,0.34),Color("69b8da"))
		pickups.append({"id":i,"kind":kind,"node":n})

func _make_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Sobrevivente"
	player.position = Vector3(0,_height(0,24)+2.0,24)
	player.floor_snap_length = 0.25
	add_child(player)
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.38
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.95
	player.add_child(col)
	player_visuals = Node3D.new()
	player_visuals.name = "VisualDoPersonagem"
	player.add_child(player_visuals)
	body = _cube(player_visuals,Vector3(0,1.0,0),Vector3(0.72,1.7,0.44),Color("54635b"))
	_ball(player_visuals,Vector3(0,1.92,0),0.28,Color("af8b72"))
	_cube(player_visuals,Vector3(0,1.1,0.36),Vector3(0.8,0.95,0.25),Color("47584b"))
	pivot = Node3D.new()
	pivot.position.y = 1.55
	player.add_child(pivot)
	cam = Camera3D.new()
	cam.fov = 75
	cam.far = float(setting("visuals", "camera_far", 175))
	cam.position = Vector3(0,0,4.8)
	pivot.add_child(cam)
	cam.current = true

func _label(parent: Control,t: String,p: Vector2,s: Vector2,sz: int) -> Label:
	var l := Label.new()
	l.text = t
	l.position = p
	l.size = s
	l.add_theme_font_size_override("font_size",sz)
	parent.add_child(l)
	return l

func _btn(parent: Control,t: String,p: Vector2,s: Vector2,method: Callable) -> Button:
	var b := Button.new()
	b.text = t
	b.position = p
	b.size = s
	b.add_theme_font_size_override("font_size",20)
	b.pressed.connect(method)
	parent.add_child(b)
	return b

func _make_interface() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(menu)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.025,0.13,0.15,0.94)
	menu.add_child(bg)
	_label(menu,"O RECOMEÇO",Vector2(85,75),Vector2(780,110),72)
	_label(menu,"SOBREVIVA • EXPLORE • CONSTRUA • EVOLUA",Vector2(90,185),Vector2(860,50),25)
	_btn(menu,"NOVO MUNDO",Vector2(85,290),Vector2(425,62),func(): _new_game())
	_btn(menu,"CONTINUAR",Vector2(85,370),Vector2(425,62),func(): _continue_game())
	_btn(menu,"GRÁFICOS: ECONÔMICO / BONITO",Vector2(85,450),Vector2(425,62),func(): _change_quality())
	_label(menu,"PROTÓTIPO 0.1 • Expansões futuras: bases, céu, oceano e cavernas",Vector2(85,590),Vector2(1100,60),20)
	hud_panel = Control.new()
	hud_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(hud_panel)
	info = _label(hud_panel,"O RECOMEÇO",Vector2(18,15),Vector2(710,46),28)
	status = _label(hud_panel,"SAÚDE 100   ÁGUA 100   FOME 100",Vector2(18,64),Vector2(800,52),23)
	alert = _label(hud_panel,"",Vector2(320,130),Vector2(860,52),24)
	var keys := [["COLETAR","collect"],["FERRAMENTA","craft"],["ABRIGO","shelter"],["JANGADA","raft"],["EMBARCAR","board"],["BAÚ","chest"],["CÂMERA","camera"],["COMER","eat"],["SALVAR","save"]]
	for i in range(keys.size()):
		var method := String(keys[i][1])
		_btn(hud_panel,String(keys[i][0]),Vector2(812 + (i % 3) * 150,490 + int(i / 3) * 66),Vector2(140,58),func(): _action(method))
	_btn(hud_panel,"MENU",Vector2(18,118),Vector2(116,48),func(): _show_menu(true))
	var directions := [["▲","forward",Vector2(115,495)],["◀","left",Vector2(25,573)],["▼","back",Vector2(115,573)],["▶","right",Vector2(205,573)]]
	for spec in directions:
		var b := Button.new()
		b.text = String(spec[0])
		b.position = spec[2]
		b.size = Vector2(81,67)
		hud_panel.add_child(b)
		var k := String(spec[1])
		b.button_down.connect(func(): held[k] = true)
		b.button_up.connect(func(): held[k] = false)
	hud_panel.visible = false

func _show_menu(show: bool) -> void:
	if show and playing:
		_save(true)
	menu.visible = show
	hud_panel.visible = not show
	playing = not show
	if show:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _new_game() -> void:
	items = {"madeira":0,"pedra":0,"fibra":0,"comida":0,"agua":0}
	gathered.clear()
	has_tool = false
	stats = Vector3(100,100,100)
	time_of_day = 0.0
	first_person = false
	cam.position = Vector3(0,0,4.8)
	player_visuals.visible = true
	for h in huts:
		if is_instance_valid(h): h.queue_free()
	huts.clear()
	if is_instance_valid(raft): raft.queue_free()
	raft = null
	raft_chest = false
	aboard = false
	for entry in pickups:
		if is_instance_valid(entry["node"]): entry["node"].queue_free()
	pickups.clear()
	_make_pickups()
	player.position = Vector3(0,_height(0,24)+2,24)
	_show_menu(false)
	_notice("Comece coletando madeira, pedra e fibra!")

func _continue_game() -> void:
	_new_game()
	if FileAccess.file_exists(SAVE):
		var d = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
		if d is Dictionary:
			items = d.get("items",items)
			has_tool = bool(d.get("tool",false))
			var bars: Array = d.get("stats", [100,100,100])
			if bars.size() >= 3:
				stats = Vector3(float(bars[0]),float(bars[1]),float(bars[2]))
			time_of_day = float(d.get("time",0.0))
			quality = int(d.get("quality",0))
			get_viewport().scaling_3d_scale = float(setting("visuals", "quality_scales", [0.70,0.83,1.0])[clampi(quality,0,2)])
			Engine.max_fps = int(setting("visuals", "mobile_fps", 30)) if quality == 0 else int(setting("visuals", "balanced_fps", 45))
			first_person = bool(d.get("first_person",false))
			cam.position = Vector3.ZERO if first_person else Vector3(0,0,4.8)
			player_visuals.visible = not first_person
			var p: Array = d.get("player",[0,2,24])
			player.position = Vector3(float(p[0]),float(p[1]),float(p[2]))
			gathered = d.get("gathered",[])
			for entry in pickups.duplicate():
				if gathered.has(entry["id"]):
					entry["node"].queue_free()
					pickups.erase(entry)
			for pos in d.get("huts",[]):
				_place_hut(Vector3(float(pos[0]),float(pos[1]),float(pos[2])))
			if bool(d.get("raft",false)):
				_place_raft()
				var boat_pos: Array = d.get("raft_position",[0.0,-1.0,70.0])
				if boat_pos.size() >= 3:
					raft.position = Vector3(float(boat_pos[0]),-1.0,float(boat_pos[2]))
				if bool(d.get("chest",false)):
					_install_chest()
				aboard = bool(d.get("aboard",false))
				if aboard:
					player.position = raft.position + Vector3(0,1.4,0)
			_notice("Salvamento carregado.")

func _notice(t: String) -> void:
	alert.text = t
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func():
		if is_instance_valid(alert) and alert.text == t:
			alert.text = ""
	)

func _change_quality() -> void:
	quality = (quality + 1) % 3
	var levels: Array = setting("visuals", "quality_scales", [0.70, 0.83, 1.0])
	get_viewport().scaling_3d_scale = float(levels[quality])
	Engine.max_fps = int(setting("visuals", "mobile_fps", 30)) if quality == 0 else int(setting("visuals", "balanced_fps", 45))
	_notice("Qualidade: " + ["Econômica","Equilibrada","Bonita"][quality])

func _action(kind: String) -> void:
	match kind:
		"collect": _collect()
		"craft": _craft()
		"shelter": _shelter()
		"raft": _build_raft()
		"board": _board()
		"chest": _chest()
		"camera":
			first_person = not first_person
			cam.position = Vector3.ZERO if first_person else Vector3(0,0,4.8)
			player_visuals.visible = not first_person
		"eat":
			if items["comida"] > 0:
				items["comida"] -= 1
				stats.z = minf(100,stats.z + 30)
			if items["agua"] > 0:
				items["agua"] -= 1
				stats.y = minf(100,stats.y + 35)
		"save": _save()

func _collect() -> void:
	var nearest := float(setting("balance", "collect_radius", 4.0))
	var selected := {}
	for r in pickups:
		var p: Vector3 = r["node"].global_position
		var dist := Vector2(p.x-player.position.x,p.z-player.position.z).length()
		if dist < nearest:
			nearest = dist
			selected = r
	if selected.is_empty():
		_notice("Aproxime-se de algum recurso.")
		return
	var k: String = selected["kind"]
	items[k] += 1
	gathered.append(selected["id"])
	selected["node"].queue_free()
	pickups.erase(selected)
	_notice("Coletado: " + k)

func _pay(cost: Dictionary) -> bool:
	for k in cost:
		if int(items.get(k,0)) < int(cost[k]):
			return false
	for k in cost:
		items[k] -= cost[k]
	return true

func _craft() -> void:
	if has_tool:
		_notice("Ferramenta já fabricada.")
	elif _pay(recipe("tool", {"madeira":2,"pedra":1,"fibra":1})):
		has_tool = true
		_notice("Ferramenta pronta!")
	else:
		_notice("Ferramenta: precisa de " + cost_text(recipe("tool", {"madeira":2,"pedra":1,"fibra":1})))

func _place_hut(pos: Vector3) -> void:
	var hut := Node3D.new()
	hut.position = pos
	world_root.add_child(hut)
	huts.append(hut)
	_cube(hut,Vector3(0,0.2,0),Vector3(4,0.3,3.5),Color("785e42"))
	for x in [-1.8,1.8]:
		for z in [-1.5,1.5]:
			_cube(hut,Vector3(x,1.55,z),Vector3(0.19,2.8,0.19),Color("665039"))
	_cube(hut,Vector3(0,2.9,0),Vector3(4.5,0.32,4),Color("405f4a"))

func _shelter() -> void:
	if not has_tool:
		_notice("Fabrique uma ferramenta antes.")
	elif _pay(recipe("shelter", {"madeira":5,"fibra":3})):
		var p := player.position + player.transform.basis * Vector3(0,0,-5)
		_place_hut(Vector3(p.x,_height(p.x,p.z),p.z))
		_notice("Abrigo construído.")
	else:
		_notice("Abrigo: precisa de " + cost_text(recipe("shelter", {"madeira":5,"fibra":3})))

func _place_raft() -> void:
	raft = Node3D.new()
	raft.position = Vector3(0,-1.0,70)
	world_root.add_child(raft)
	for i in range(5):
		_cube(raft,Vector3((i-2)*0.8,0.2,0),Vector3(0.77,0.35,4.2),Color("946b43"))
	_cube(raft,Vector3(0,1.6,0),Vector3(0.14,2.7,0.14),Color("68513d"))

func _build_raft() -> void:
	if is_instance_valid(raft):
		_notice("A jangada já foi construída.")
	elif not has_tool:
		_notice("Precisa fabricar a ferramenta.")
	elif _pay(recipe("raft", {"madeira":6,"fibra":4})):
		_place_raft()
		_notice("Jangada construída na costa sul.")
	else:
		_notice("Jangada: precisa de " + cost_text(recipe("raft", {"madeira":6,"fibra":4})))

func _board() -> void:
	if not is_instance_valid(raft):
		_notice("Construa a jangada primeiro.")
	elif aboard:
		aboard = false
		player.position = raft.position + Vector3(4,1.5,0)
		_notice("Desembarcou.")
	elif player.position.distance_to(raft.position) < 9.0:
		aboard = true
		_notice("Embarcou! Use as setas para navegar.")
	else:
		_notice("Aproxime-se da jangada.")

func _install_chest() -> void:
	raft_chest = true
	_cube(raft,Vector3(-1.1,0.6,0.7),Vector3(0.9,0.7,0.65),Color("705139"))

func _chest() -> void:
	if not is_instance_valid(raft):
		_notice("Construa a jangada primeiro.")
	elif raft_chest:
		_notice("Baú já instalado.")
	elif _pay(recipe("chest", {"madeira":2,"fibra":1})):
		_install_chest()
		_notice("Baú instalado!")
	else:
		_notice("Baú: precisa de " + cost_text(recipe("chest", {"madeira":2,"fibra":1})))

func _save(silent: bool = false) -> void:
	if not playing:
		return
	var boat_pos := [0.0,-1.0,70.0]
	if is_instance_valid(raft):
		boat_pos = [raft.position.x,raft.position.y,raft.position.z]
	var data := {"items":items,"tool":has_tool,"player":[player.position.x,player.position.y,player.position.z],"gathered":gathered,"huts":[],"raft":is_instance_valid(raft),"raft_position":boat_pos,"aboard":aboard,"chest":raft_chest,"stats":[stats.x,stats.y,stats.z],"quality":quality,"first_person":first_person,"time":time_of_day}
	for h in huts:
		data["huts"].append([h.position.x,h.position.y,h.position.z])
	var f := FileAccess.open(SAVE,FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))
		f.close()
		if not silent:
			_notice("Jogo salvo!")

func _process(delta: float) -> void:
	if not playing:
		return
	time_of_day += delta
	sun.rotation.x = -0.7 + sin(time_of_day * float(setting("world", "day_cycle_speed", 0.025))) * 0.38
	stats.y = maxf(0,stats.y - delta * float(setting("balance", "hydration_loss_per_second", 0.027)))
	stats.z = maxf(0,stats.z - delta * float(setting("balance", "hunger_loss_per_second", 0.020)))
	if stats.y <= 0 or stats.z <= 0:
		stats.x = maxf(1.0,stats.x - delta * float(setting("balance", "low_resources_health_loss", 0.1)))
	status.text = "SAÚDE %.0f   ÁGUA %.0f   FOME %.0f   FPS %d" % [stats.x,stats.y,stats.z,Engine.get_frames_per_second()]
	info.text = "O RECOMEÇO  |  Madeira %d  Pedra %d  Fibra %d  Comida %d  Água %d" % [items["madeira"],items["pedra"],items["fibra"],items["comida"],items["agua"]]
	autosave += delta
	if autosave > 90:
		autosave = 0
		_save()

func _physics_process(delta: float) -> void:
	if not playing:
		return
	var move := Vector2.ZERO
	if held["left"] or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1
	if held["right"] or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1
	if held["forward"] or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y += 1
	if held["back"] or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y -= 1
	var dir := (player.transform.basis * Vector3(move.x,0,-move.y)).normalized()
	if aboard and is_instance_valid(raft):
		raft.position += dir * delta * float(setting("balance", "raft_speed", 4.0))
		raft.position.y = -1.0
		player.position = raft.position + Vector3(0,1.4,0)
		player.velocity = Vector3.ZERO
		return
	player.velocity.x = dir.x * float(setting("balance", "player_walk_speed", 5.0))
	player.velocity.z = dir.z * float(setting("balance", "player_walk_speed", 5.0))
	if player.is_on_floor():
		player.velocity.y = 5.0 if Input.is_key_pressed(KEY_SPACE) else -0.3
	else:
		player.velocity.y -= 18.0 * delta
	player.move_and_slide()
	if player.position.y < -4.0:
		player.position = Vector3(0,_height(0,24)+2,24)

func _unhandled_input(event: InputEvent) -> void:
	if not playing:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotation.y -= event.relative.x * float(setting("visuals", "mouse_sensitivity", 0.003))
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * float(setting("visuals", "mouse_sensitivity", 0.003)),-1.1,1.0)
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x > 420 and mobile_look < 0:
			mobile_look = event.index
		elif not event.pressed and event.index == mobile_look:
			mobile_look = -1
	if event is InputEventScreenDrag and event.index == mobile_look:
		player.rotation.y -= event.relative.x * float(setting("visuals", "touch_sensitivity", 0.004))
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * float(setting("visuals", "touch_sensitivity", 0.004)),-1.1,1.0)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E: _action("collect")
			KEY_F: _action("craft")
			KEY_B: _action("shelter")
			KEY_R: _action("raft")
			KEY_T: _action("board")
			KEY_V: _action("camera")
			KEY_F5: _action("save")
			KEY_ESCAPE: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
