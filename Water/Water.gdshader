shader_type canvas_item;

uniform sampler2D island_mask; // the mask
uniform float time;
uniform float foam_width = 3.0; // in UV space

uniform vec3 water_color = vec3(0.15, 0.35, 0.85);
uniform vec3 foam_color = vec3(1.0, 1.0, 1.0);


// Function to blur the mask
vec4 blurred(sampler2D mask, vec2 uv, float radius) {
    vec4 color = vec4(0.0);
    float total = 0.0;

    // Sample around the pixel in a square
    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            vec2 offset = vec2(x, y) / vec2(textureSize(mask, 0));
            vec4 sample = texture(mask, uv + offset);
            color += sample;
            total += 1.0;
        }
    }
    // Average the samples
    return color / total;
}


void fragment() {
    vec2 uv = UV;
    float land = texture(island_mask, uv).a;
    float foam_mask = blurred(island_mask, uv, 2).a;

    // Simple multi-sine "noise" waves
    float wave = (
        sin((uv.x + time * 0.12) * 40.0) +
        sin((uv.y - time * 0.10) * 70.0) +
        sin((uv.x + uv.y + time * 0.08) * 25.0)
    ) * 0.025;

    // Animate water color
    vec3 anim_water = water_color + wave;

    // Depth-based tint (darker far from shore)
    float depth = 1.0 - blurred(island_mask, uv, 12).a;
    vec3 deep_water = water_color * 0.6;
    anim_water = mix(anim_water, deep_water, pow(depth, 1.5));

    // Blend with foam
    vec3 final_color = mix(anim_water, foam_color, foam_mask);

    //if (land > 0.5) {
        //discard;
    //}
    COLOR = vec4(final_color, 0.95);
}