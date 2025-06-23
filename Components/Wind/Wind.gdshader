shader_type particles;

uniform float distortion = 0.05;
uniform float speed = 2.0;

void fragment() {
    // Extract screen-space position from the transform matrix
    vec2 ppos = TRANSFORM[3].xy;

    float t = TIME * speed;
    float wave = sin(ppos.x * 0.05 + t) * distortion;
    float swirl = cos(ppos.y * 0.03 + t * 0.7) * distortion * 0.5;

    vec2 d_uv = UV + vec2(wave, swirl);
    COLOR = texture(TEXTURE, d_uv); // fragment output
}
