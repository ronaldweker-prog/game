extends SceneTree
## Busca modelos 3D CC0 durante o build Godot.
## Nao depende de Python: utiliza o wget presente no container Godot-CI.
## O download e opcional. Um asset faltando nao impede o jogo de compilar.
const IDS := ["rock_09", "tree_stump_01"]

func _initialize() -> void:
	var root_path := ProjectSettings.globalize_path("res://assets/models/")
	DirAccess.make_dir_recursive_absolute(root_path)
	for id in IDS:
		_fetch_model(id, root_path)
	quit(0)

func _wget(url: String, output: String) -> bool:
	var log: Array = []
	var code := OS.execute("wget", ["--quiet", "--timeout=35", "--tries=2", "--user-agent=RenascerNovoMundoGameBuild/0.3", "-O", output, url], log, true)
	if code != 0:
		if FileAccess.file_exists(output):
			DirAccess.remove_absolute(output)
		return false
	return FileAccess.file_exists(output) and FileAccess.get_file_as_bytes(output).size() > 100

func _fetch_model(id: String, root_path: String) -> void:
	var folder := root_path.path_join(id)
	DirAccess.make_dir_recursive_absolute(folder)
	var manifest_file := folder.path_join("manifest.json")
	if not _wget("https://api.polyhaven.com/files/%s" % id, manifest_file):
		print("MODELO_3D_FALLBACK=",id,", motivo=manifesto indisponivel")
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_file))
	if not data is Dictionary:
		print("MODELO_3D_FALLBACK=",id,", motivo=manifesto invalido")
		return
	var formats: Dictionary = data.get("gltf",{})
	var resolutions: Dictionary = formats.get("1k",{})
	var selected: Dictionary = resolutions.get("gltf",{})
	if selected.is_empty() or not selected.has("url"):
		print("MODELO_3D_FALLBACK=",id,", motivo=sem glTF 1K")
		return
	var assets := {}
	var source_url: String = selected.get("url","")
	var root_name: String = source_url.get_file()
	assets[root_name] = selected
	var included: Variant = selected.get("include",{})
	if included is Dictionary:
		for relative in included:
			var entry: Variant = included[relative]
			if entry is Dictionary:
				assets[str(relative)] = entry
	var downloaded := 0
	for relative in assets:
		var rel: String = str(relative)
		if rel.begins_with("/") or rel.find("..") >= 0:
			print("MODELO_3D_FALLBACK=",id,", motivo=path invalido")
			return
		var entry: Dictionary = assets[relative]
		var url: String = entry.get("url","")
		if not url.begins_with("https://dl.polyhaven.org/"):
			print("MODELO_3D_FALLBACK=",id,", motivo=origem inesperada")
			return
		var target := folder.path_join(rel)
		DirAccess.make_dir_recursive_absolute(target.get_base_dir())
		if not _wget(url,target):
			print("MODELO_3D_FALLBACK=",id,", arquivo=",rel)
			return
		downloaded += 1
	print("MODELO_3D_REAL_OK=",id,", arquivos=",downloaded)
