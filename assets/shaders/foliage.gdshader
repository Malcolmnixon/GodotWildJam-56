shader_type spatial;

uniform sampler2D tex; 

void fragment() {
	vec4 t = texture(tex, UV); 
	
	ALBEDO = t.rgb; 
	ALPHA = t.w; 
}

void vertex() { 
	//VERTEX.x = cos(TIME + (VERTEX.x - VERTEX.z)); 
}