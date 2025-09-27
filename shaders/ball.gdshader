shader_type spatial;

const float stripWidth = 0.48;
const float offset = 0.f;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float wave = sin(TIME) * 5.f;
	float width = stripWidth;
	
	float stripUp = step(width, 1.f - UV.y +  + offset);
	float stripDown = step(width, UV.y +  + offset);
	
	ALBEDO = vec3(
		1.f - (stripUp * stripDown)
	);
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
