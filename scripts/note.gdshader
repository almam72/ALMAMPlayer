shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude_y = 50.0;
uniform float amplitude_x = 25.0;
uniform float inclination = 50.0;
uniform bool happy = false;

void vertex() {
	if (happy) {
		VERTEX.y += sin((UV.x - TIME * speed) * frequency_y) * amplitude_y;
		VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude_x;
		VERTEX.x -= UV.y * inclination;
	}
}