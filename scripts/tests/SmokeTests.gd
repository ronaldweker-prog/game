extends SceneTree

# Testes de integracao do prototipo. Executados no CI com Godot --headless.
# Estes testes NAO substituem testes graficos e de toque em um aparelho Android.
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, description: String) -> void:
	if value:
		print("PASSOU: ", description)
	else:
		failures += 1
		push_error("FALHOU: " + description)

func _run() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("A cena inicial nao abriu")
		quit(1)
		return
	var game: Node = packed.instantiate()
	root.add_child(game)
	await process_frame
	_check(game.is_inside_tree(), "A cena principal abre")
	_check(game.cam != null, "Camera 3D criada")
	_check(game.pickups.size() > 0, "Recursos criados na ilha")
	_check(int(game.setting("visuals", "mobile_fps", 0)) >= 24, "Config de FPS carregada")
	game._new_game()
	await process_frame
	_check(game.playing, "Iniciar partida")
	var entry: Dictionary = game.pickups[0]
	var kind: String = entry["kind"]
	var before: int = int(game.items[kind])
	game.player.global_position = entry["node"].global_position + Vector3(0,2,0)
	game._collect()
	_check(int(game.items[kind]) == before + 1, "Coleta altera inventario")
	game.items["madeira"] = 25
	game.items["pedra"] = 10
	game.items["fibra"] = 25
	game._craft()
	_check(game.has_tool, "Fabricar ferramenta")
	game._shelter()
	_check(game.huts.size() == 1, "Construir abrigo")
	game._build_raft()
	_check(is_instance_valid(game.raft), "Construir jangada")
	game._chest()
	_check(game.raft_chest, "Instalar bau")
	game.player.global_position = game.raft.global_position + Vector3(0,2,0)
	game._board()
	_check(game.aboard, "Embarcar na jangada")
	game._action("camera")
	_check(game.first_person, "Trocar para primeira pessoa")
	var original_wood: int = int(game.items["madeira"])
	var boat_pos: Vector3 = game.raft.position
	game._save(true)
	_check(FileAccess.file_exists(game.SAVE), "Arquivo de salvamento criado")
	game._continue_game()
	await process_frame
	_check(int(game.items["madeira"]) == original_wood, "Recursos restaurados do save")
	_check(game.raft_chest, "Bau restaurado do save")
	_check(game.huts.size() == 1, "Abrigo restaurado do save")
	_check(game.raft.position.distance_to(boat_pos) < 0.1, "Posicao da jangada restaurada")
	_check(game.first_person, "Camera restaurada do save")
	print("RESUMO DOS TESTES: ", failures, " falhas")
	quit(1 if failures > 0 else 0)
