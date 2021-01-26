shader_type canvas_item;

uniform bool is_highlighted = false;
uniform float threshold = 0.02;
uniform float highlight_multiplier = 2.0;

void fragment() {
	
	COLOR = texture(TEXTURE,UV);
	
	if (is_highlighted) {
		if (COLOR.r * COLOR.g * COLOR.b < threshold) {
			COLOR += 2.0 * vec4(1.0,1.0,1.0,0.0);
		}
		else {
			COLOR += highlight_multiplier * vec4(1.0,1.0,1.0,1.0);
		}
	}
	
}