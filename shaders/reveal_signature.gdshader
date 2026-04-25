shader_type canvas_item;

uniform float reveal : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// show only pixels left of reveal threshold
	if (UV.x <= reveal) {
		COLOR = tex;
	} else {
		COLOR = vec4(0.0);
	}
}