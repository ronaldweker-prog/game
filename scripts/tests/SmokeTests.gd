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
	_check(game.player_visuals.get_node_or_null("JaquetaDeExplorador") != null, "Modelo humanoide detalhado carregado")
	game._camera_collision(0.016)
	_check(game.cam.position.z >= 0.0, "Camera em terceira pessoa com detecção de obstáculos")
	_check(game.character_motion != null, "Sistema de animacao do personagem criado")
	_check(FileAccess.file_exists("res://assets/app_icon.png"), "Icone PNG gerado e incluido no projeto")
	_check(str(game.game_config.get("game_title","")) == "RENASCER: NOVO MUNDO", "Novo nome configurado")
	_check(game.pickups.size() > 0, "Recursos criados na ilha")
	_check(game.action_buttons.size() == 9, "Menu de ações compacto instalado")
	_check(not game.action_buttons[0].visible, "Ações extras ocultas inicialmente")
	game._toggle_actions()
	_check(game.action_buttons[0].visible and game.action_backdrop.visible, "Abrir painel de ações no celular")
	game._toggle_actions()
	_check(not game.action_buttons[0].visible and not game.action_backdrop.visible, "Fechar painel de ações")
	_check(game.world_root.get_node_or_null("IlhaVisual/TerrenoNatural").material_override.get_shader_parameter("sand_map") != null, "Material natural da areia carregado")
	_check(game.pickups[0]["node"].get("kind") == "madeira", "Recursos possuem identidade visual própria")
	_check(game.pickups[0]["node"].get_node_or_null("ModeloDeRecurso") != null, "Modelos 3D dos recursos carregados")
	_check(game.world_root.get_node_or_null("IlhaVisual/TerrenoNatural") != null, "Novo terreno visual criado")
	_check(game.world_root.get_node_or_null("IlhaVisual/MarComOndas") != null, "Oceano animado criado")
	_check(game.world_root.get_node_or_null("IlhaVisual/TroncosInstanciados") != null, "Vegetacao instanciada criada")
	_check(game.world_root.get_node_or_null("IlhaVisual/PalmeirasCosteiras/FolhasPalmeiras") != null, "Palmeiras costeiras carregadas")
	_check(game.world_root.get_node_or_null("IlhaVisual/InstalacaoAntigaExploravel") != null, "Estacao antiga criada")
	if ResourceLoader.exists("res://assets/models/rock_09/rock_09_1k.gltf"):
		_check(game.world_root.get_node_or_null("IlhaVisual/ModeloReal_rock_09_0") != null, "Rocha fotogrametrica importada e posicionada")
	if ResourceLoader.exists("res://assets/models/tree_stump_01/tree_stump_01_1k.gltf"):
		_check(game.world_root.get_node_or_null("IlhaVisual/ModeloReal_tree_stump_01_0") != null, "Tronco fotogrametrico importado e posicionado")
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
	game.player.global_position = Vector3(85.0,-2.6,0.0)
	game.swim_down_held = true
	game._physics_process(0.1)
	_check(game.swimming, "Entrar em modo natação quando jogador está no mar")
	_check(game.player.velocity.y < 0.0,"Mergulho por botão de toque")
	game.swim_down_held = false
	game.swim_up_held = true
	game._physics_process(0.1)
	_check(game.player.velocity.y > 0.0,"Subir à superfície por botão de toque")
	game.swim_up_held = false
	game.player.position = Vector3(85.0,-3.0,0.0)
	game._physics_process(0.01)
	var oxygen_before: float = game.oxygen
	game._process(0.5)
	_check(game.oxygen < oxygen_before,"Oxigênio diminui enquanto submerso")
	game.items["madeira"] = 70
	game.items["fibra"] = 70
	game.player.position = Vector3(6.0,game._height(6.0,24.0)+2.0,24.0)
	var construction_cell: Vector3 = game.building_system.call("candidate",game.player)
	_check(bool(game.building_system.call("can_place","piso",construction_cell,0)), "Piso modular aceito em terreno valido")
	var budget_before: int = int(game.items["madeira"])
	game.build_mode = true
	game.build_kind = "piso"
	game._place_modular_piece()
	_check(game.building_system.records.size() == 1,"Construir piso modular")
	_check(int(game.items["madeira"]) == budget_before-3,"Construção consome materiais do inventario")
	game.build_kind = "parede"
	game._place_modular_piece()
	_check(game.building_system.records.size() == 2,"Construir parede sobre fundacao")
	_check(not bool(game.building_system.call("can_place","parede",construction_cell,0)),"Impedir parede duplicada")
	game.build_kind = "porta"
	game.build_side = 1
	game._place_modular_piece()
	_check(game.building_system.records.size() == 3,"Instalar porta modular")
	game.build_kind = "teto"
	game._place_modular_piece()
	_check(game.building_system.records.size() == 4,"Instalar teto modular")
	game.player.global_position = construction_cell + Vector3(0,1.5,0)
	game._open_door()
	var saved_buildings: Array = game.building_system.call("serialize")
	_check(bool(saved_buildings[2]["opened"]), "Porta modular abre quando jogador aproxima")
	game.build_mode = false
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
	game.player.global_position = Vector3(23.0,game._height(23.0,-16.0)+1.0,-16.0)
	game._investigate_ruins()
	_check(game.ruins_visited, "Investigacao de ruinas completa")
	_check(game._mission_text().begins_with("OBJETIVO CONCLUÍDO"), "Objetivo de exploracao atualizado")
	var original_wood: int = int(game.items["madeira"])
	var energy_before_save: float = game.stamina
	var oxygen_before_save: float = game.oxygen
	var boat_pos: Vector3 = game.raft.position
	game._save(true)
	_check(FileAccess.file_exists(game.SAVE), "Arquivo de salvamento criado")
	game._continue_game()
	var energy_just_loaded: float = game.stamina
	var oxygen_just_loaded: float = game.oxygen
	await process_frame
	_check(int(game.items["madeira"]) == original_wood, "Recursos restaurados do save")
	_check(game.raft_chest, "Bau restaurado do save")
	_check(int(game.chest_items["madeira"]) == 1, "Conteudo do bau restaurado do save")
	_check(game.huts.size() == 1, "Abrigo restaurado do save")
	_check(game.raft.position.distance_to(boat_pos) < 0.1, "Posicao da jangada restaurada")
	_check(game.first_person, "Camera restaurada do save")
	_check(game.outfit_style == 1, "Aparencia restaurada do save")
	_check(game.ruins_visited, "Registro da missao preservado no save")
	_check(game.building_system.records.size() == 4,"Construções modulares restauradas do save")
	_check(bool(game.building_system.records[2]["opened"]),"Estado da porta persistido no save")
	_check(absf(energy_just_loaded-energy_before_save) < 0.01,"Energia restaurada do save")
	_check(absf(oxygen_just_loaded-oxygen_before_save) < 0.01,"Oxigênio restaurado do save")
	print("RESUMO DOS TESTES: ", failures, " falhas")
	quit(1 if failures > 0 else 0)
