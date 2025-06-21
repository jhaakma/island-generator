//Godot 4.4.1 gdshader

shader_type canvas_item;

uniform sampler2D height_map : hint_default_white;
uniform sampler2D temperature_map : hint_default_white;
uniform sampler2D biome_thresholds : hint_default_white;
uniform sampler2D biome_colors : hint_default_white;

uniform float outline_color_multi = 0.6;
uniform float outline_thickness = 0.3;
uniform int biome_count = 0;
uniform vec2 pixel_size = vec2(1.0, 1.0);
const int MAX_BIOMES = 16;

vec3 get_biome_color(float height, float temp) {
    vec3 color = vec3(0.0);
    float best_height = -1000.0;
    for(int i = 0; i < MAX_BIOMES; i++) {
        if(i >= biome_count) break;
        vec4 t = texelFetch(biome_thresholds, ivec2(i, 0), 0);
        bool temp_ok = temp >= t.b && temp <= t.a;
        bool height_ok = height >= t.r;
        if(temp_ok && height_ok && t.r > best_height) {
            best_height = t.r;
            color = texelFetch(biome_colors, ivec2(i, 0), 0).rgb;
        }
    }
    return color;
}

vec2 pixelate(vec2 screen_res, vec2 screen_uv) {
    // Snap UV to pixel grid
    vec2 pix_size = max(pixel_size, vec2(0.0001, 0.0001));
    return floor(screen_uv * screen_res / pix_size) * pix_size / screen_res;
}

/* Outline effect

    Draw a single black pixel outline at the edge of 0.0 height
*/
float outline_shoreline(vec2 uv) {
    vec2 tex_size = vec2(textureSize(height_map, 0));
    vec2 texel = 1.0 / tex_size * outline_thickness;

    float h = texture(height_map, uv).r * 2.0 - 1.0;
    if (h < 0.0)
        return 0.0;

    // Scan all 8 neighbors
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            float neighbor_h = texture(height_map, uv + vec2(float(x) * texel.x, float(y) * texel.y)).r * 2.0 - 1.0;
            if (neighbor_h < 0.0) return 1.0;
        }
    }
    return 0.0;
}

void fragment() {

    vec2 uv = pixelate(1.0/SCREEN_PIXEL_SIZE, UV);
    vec4 world_map =  texture(height_map, uv);
    float h = world_map.r * 2.0 - 1.0;
    //float is_river = step(0.9, world_map.b);
    float temp = texture(temperature_map, uv).r;
    COLOR.rgb = get_biome_color(h, temp);
    // Apply outline effect for land
    COLOR.rgb = COLOR.rgb * mix(1.0, outline_color_multi, outline_shoreline(uv));
    COLOR.a = 1.0;
}