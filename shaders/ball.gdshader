shader_type spatial;

const float stripWidth = 0.45;
const float offset = 0.f;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	float wave = sin(TIME) * 5.f;
	float width = stripWidth;

	float stripUp = step(width, 1.f - UV.y + offset);
	float stripDown = step(width, UV.y + offset);

	float stripLeft = step(width, 1.f - UV.x);
	float stripRight = step(width, UV.x);

	ALBEDO = vec3(
		(1.f - (stripUp * stripDown)) * (1.f - (stripLeft * stripRight))
	);

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
