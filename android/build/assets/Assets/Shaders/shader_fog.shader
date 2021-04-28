shader_type canvas_item;

uniform vec4 color:hint_color;
uniform int detail = 4;
uniform int zoom_out = 20;
const float speed = 0.6;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(56, 35)) * 98.4) * 84.5);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * f;
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < detail; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 coord = UV * float(zoom_out);
	vec2 motion = vec2( fbm(coord + vec2(TIME * -0.5, TIME * 0.5)) );
	float final = fbm(coord + motion);
	COLOR = vec4(color.rgb, final * 0.5);
}