extends SceneTree
## Gera o PNG do icone no CI a partir do vetor original.
## Godot utiliza a mesma arte em 192px no launcher do Android.
func _initialize() -> void:
	var path := "res://assets/icon_renascer.svg"
	if not FileAccess.file_exists(path):
		push_error("Logo SVG ausente")
		quit(1)
		return
	var data := FileAccess.get_file_as_bytes(path)
	var img := Image.new()
	var result := img.load_svg_from_buffer(data)
	if result != OK:
		push_error("Falha ao interpretar a logo SVG: %d" % result)
		quit(1)
		return
	img.resize(192,192,Image.INTERPOLATE_LANCZOS)
	var save_result := img.save_png("res://assets/app_icon.png")
	if save_result != OK:
		push_error("Falha ao gravar icone do Android: %d" % save_result)
		quit(1)
		return
	print("Icone gerado com sucesso em assets/app_icon.png")
	quit(0)
