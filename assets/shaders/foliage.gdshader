shader_type spatial;

uniform sampler2D tex; 

void fragment() {
	vec4 t = texture(tex, UV); 
	
	ALBEDO = t.rgb; 
	ALPHA = t.w; 
}

void vertex() { 
	float node_offset = NODE_POSITION_WORLD.x + NODE_POSITION_WORLD.z;
	VERTEX.x += cos(TIME * VERTEX.x + node_offset) * 0.1; 
	VERTEX.x += cos(TIME * VERTEX.y + node_offset) * 0.1; 
}