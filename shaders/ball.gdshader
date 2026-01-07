shader_type spatial;

const float stripWidth = 0.45f;
const float offset = 0.f;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	
	
	float dotprod = dot(VERTEX, vec3(0, 0, 1));

	float wave = abs( sin(TIME * 0.5)) * 0.5f;
	float width = stripWidth;

	float stripUp = step(width, 1.f - UV.y + offset);
	float stripDown = step(width, UV.y + offset);

	float stripLeft = step(width, 1.f - UV.x);
	float stripRight = step(width, UV.x);
	
	//ALBEDO = vec3(
		//1.f - dotprod
	//);

	ALBEDO = vec3(
		(1.f - (stripUp * stripDown)) * (1.f - (stripLeft * stripRight))
	);

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
