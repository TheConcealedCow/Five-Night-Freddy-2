#pragma header

const int Zoom = 200;
const float p = 3.1415;
vec2 uv = openfl_TextureCoordv;
vec2 iResolution = openfl_TextureSize;
void main() { // PANORAMA
	float sY = iResolution.y / 768;
	
	vec2 fragCoord = floor(uv * iResolution);
    float CurrentSinStep = ((fragCoord.x - (iResolution.x / 2)) / (iResolution.x / p)) + (p / 2);
    float CurrentHeight = max(1, iResolution.y + sin(CurrentSinStep) * Zoom - Zoom);
    float yThing = iResolution.y / 2 - CurrentHeight / 2;
	float newY = uv.y - ((uv.y - 0.5) * (yThing * 2 / iResolution.y) * sY);
	
	if (newY > 1 || newY < 0) {
		gl_FragColor = vec4(0);
	} else {
		gl_FragColor = flixel_texture2D(bitmap, vec2(uv.x, newY));
	}
}
