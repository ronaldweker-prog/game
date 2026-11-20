extends RefCounted
## Tema de interface para substituir o HUD de botoes quadrados por UI legivel.
## Sem dependencias de fontes externas, funciona offline no Android.
static func style_button(button: Button, primary: bool = false) -> void:
	var idle := StyleBoxFlat.new()
	idle.bg_color = Color(0.015,0.075,0.115,0.86) if not primary else Color(0.055,0.30,0.38,0.94)
	idle.border_color = Color(0.43,0.69,0.72,0.45) if not primary else Color(0.47,0.85,0.86)
	idle.set_border_width_all(1)
	idle.set_corner_radius_all(12)
	idle.content_margin_left = 9
	idle.content_margin_right = 9
	idle.content_margin_top = 5
	idle.content_margin_bottom = 5
	var focus: StyleBoxFlat = idle.duplicate() as StyleBoxFlat
	focus.bg_color = Color(0.075,0.35,0.43,0.97)
	focus.border_color = Color(0.61,0.97,0.98)
	button.add_theme_stylebox_override("normal",idle)
	button.add_theme_stylebox_override("hover",focus)
	button.add_theme_stylebox_override("pressed",focus)
	button.add_theme_stylebox_override("focus",focus)
	button.add_theme_color_override("font_color",Color("edfcff"))
	button.add_theme_color_override("font_hover_color",Color.WHITE)
	button.add_theme_color_override("font_pressed_color",Color.WHITE)
	button.add_theme_font_size_override("font_size",18)

static func style_label(label: Label) -> void:
	label.add_theme_color_override("font_color",Color("effbff"))
	label.add_theme_color_override("font_shadow_color",Color(0.0,0.025,0.04,0.92))
	label.add_theme_constant_override("shadow_offset_x",1)
	label.add_theme_constant_override("shadow_offset_y",2)

static func menu_overlay() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 uv=UV;
	vec3 top=vec3(0.012,0.045,0.067);
	vec3 bottom=vec3(0.018,0.087,0.107);
	float edge=smoothstep(0.12,0.9,uv.x);
	float alpha=mix(0.96,0.38,edge);
	COLOR=vec4(mix(top,bottom,uv.y),alpha);
}
"""
	material.shader = shader
	return material
