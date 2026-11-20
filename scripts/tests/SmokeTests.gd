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
	_check(game.character_motion != null, "Sistema de animacao do personagem criado")
	_check(FileAccess.file_exists("res://assets/app_icon.png"), "Icone PNG gerado e incluido no projeto")
	_check(str(game.game_config.get("game_title","")) == "RENASCER: NOVO MUNDO", "Novo nome configurado")
	_check(game.pickups.size() > 0, "Recursos criados na ilha")
	_check(game.world_root.get_node_or_null("IlhaVisual/TerrenoNatural") != null, "Novo terreno visual criado")
	_check(game.world_root.get_node_or_null("IlhaVisual/MarComOndas") != null, "Oceano animado criado")
	_check(game.world_root.get_node_or_null("IlhaVisual/TroncosInstanciados") != null, "Vegetacao instanciada criada")
	_check(game.world_root.get_node_or_null("IlhaVisual/InstalacaoAntigaExploravel") != null, "Estacao antiga criada")
	_check(game.animals.size() >= 1, "Fauna terrestre criada")
	_check(game.animals[0].height_at.is_valid(), "Fauna com terreno associado")
	_check(int(game.setting("visuals", "mobile_fps", 0)) >= 24, "Config de FPS carregada")
	game._new_game()
	await process_frame
	_check(game.playing, "Iniciar partida")
	game.character_motion.call("animate_character",0.1,Vector3(3.0,0.0,0.0),false,false)
	_check(game.character_motion.get("state") == "andando", "Animacao de caminhada")
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
	game._chest()
	_check(game.chest_panel.visible, "Abrir painel do bau")
	var previous: int = int(game.items["madeira"])
	game._transfer_to_chest("madeira", true)
	_check(int(game.chest_items["madeira"]) == 1, "Guardar material no bau")
	_check(int(game.items["madeira"]) == previous - 1, "Inventario descontado ao guardar")
	game._transfer_to_chest("madeira", false)
	_check(int(game.chest_items["madeira"]) == 0, "Retirar material do bau")
	game._transfer_to_chest("madeira", true)
	game._action("camera")
	_check(game.first_person, "Trocar para primeira pessoa")
	game.character_motion.call("animate_character",0.1,Vector3.ZERO,false,true)
	var hands: Node3D = game.character_motion.get("camera_arms")
	_check(hands != null and hands.visible, "Maos de primeira pessoa aparecem")
	game._cycle_outfit()
	_check(game.outfit_style == 1, "Personalizar roupa do personagem")
	game.aboard = false
	game.sprint_held = true
	game.held["forward"] = true
	var old_stamina: float = game.stamina
	game._physics_process(0.2)
	_check(game.stamina < old_stamina, "Corrida consome energia")
	game.sprint_held = false
	game.held["forward"] = false
	game._request_jump()
	_check(game.jump_queued, "Pulo pode ser acionado pelo touch")
	game.jump_queued = false
	var original_wood: int = int(game.items["madeira"])
	var energy_before_save: float = game.stamina
	var boat_pos: Vector3 = game.raft.position
	game._save(true)
	_check(FileAccess.file_exists(game.SAVE), "Arquivo de salvamento criado")
	game._continue_game()
	await process_frame
	_check(int(game.items["madeira"]) == original_wood, "Recursos restaurados do save")
	_check(game.raft_chest, "Bau restaurado do save")
	_check(int(game.chest_items["madeira"]) == 1, "Conteudo do bau restaurado do save")
	_check(game.huts.size() == 1, "Abrigo restaurado do save")
	_check(game.raft.position.distance_to(boat_pos) < 0.1, "Posicao da jangada restaurada")
	_check(game.first_person, "Camera restaurada do save")
	_check(game.outfit_style == 1, "Aparencia restaurada do save")
	_check(absf(game.stamina-energy_before_save) < 0.01,"Energia restaurada do save")
	print("RESUMO DOS TESTES: ", failures, " falhas")
	quit(1 if failures > 0 else 0)
