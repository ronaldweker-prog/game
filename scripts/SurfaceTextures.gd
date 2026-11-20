extends RefCounted
## Carrega texturas reais CC0, incluídas durante a compilação, com fallback local.
## O protótipo pode abrir offline mesmo quando as texturas externas não existem.
static var cache: Dictionary = {}

static func surface(kind: String) -> Texture2D:
	if cache.has(kind):
		return cache[kind]
	var names := {"sand":"sand_03","grass":"grass_ground","rock":"rock_ground"}
	var asset: String = str(names.get(kind,"sand_03"))
	var path := "res://assets/materials/%s_diff_1k.jpg" % asset
	var result: Texture2D
	if ResourceLoader.exists(path):
		var source = load(path)
		if source is Texture2D:
			result = source
	if result == null:
		result = _fallback(kind)
	cache[kind] = result
	return result

static func _fallback(kind: String) -> Texture2D:
	var colors := {
		"sand":[Color("b9a47f"),Color("d5c6a1"),Color("8f8063")],
		"grass":[Color("455f3a"),Color("647c48"),Color("382f29")],
		"rock":[Color("65645b"),Color("9b9a87"),Color("454945")]
	}
	var palette: Array = colors.get(kind,colors["sand"])
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.seed = 42017 if kind == "sand" else (13579 if kind == "grass" else 24680)
	n.frequency = 0.06
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = 5
	n.fractal_gain = 0.48
	var fine := FastNoiseLite.new()
	fine.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fine.seed = n.seed + 9
	fine.frequency = 0.3
	var img := Image.create(256,256,false,Image.FORMAT_RGB8)
	for y in range(256):
		for x in range(256):
			var base := clampf(0.5 + 0.5*n.get_noise_2d(float(x),float(y)),0.0,1.0)
			var g := fine.get_noise_2d(float(x),float(y))
			var tint: Color = palette[0].lerp(palette[1],base)
			if g < -0.35:
				tint = tint.lerp(palette[2],minf(0.5,absf(g)))
			img.set_pixel(x,y,tint)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)
