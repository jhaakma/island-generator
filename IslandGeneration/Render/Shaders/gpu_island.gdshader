shader_type canvas_item;

uniform sampler2D height_map : hint_default_white;
uniform sampler2D temperature_map : hint_default_white;
uniform sampler2D biome_thresholds : hint_default_white;
uniform sampler2D biome_colors : hint_default_white;

uniform float height_scale = 20.0;
uniform int biome_count = 0;

const int MAX_BIOMES = 16;

void vertex() {
    float h = texture(height_map, UV).r * 2.0 - 1.0;
    VERTEX.y -= h * height_scale;
}

vec3 get_biome_color(float height, float temp) {
    for(int i = 0; i < MAX_BIOMES; i++) {
        if(i >= biome_count) break;
        vec4 t = texelFetch(biome_thresholds, ivec2(i, 0), 0);
        if(height >= t.r && height <= t.g && temp >= t.b && temp <= t.a) {
            return texelFetch(biome_colors, ivec2(i, 0), 0).rgb;
        }
    }
    return vec3(0.0);
}

void fragment() {
    float h = texture(height_map, UV).r * 2.0 - 1.0;
    float temp = texture(temperature_map, UV).r;
    COLOR.rgb = get_biome_color(h, temp);
    COLOR.a = 1.0;
}
