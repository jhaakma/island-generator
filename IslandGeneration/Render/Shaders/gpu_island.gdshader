shader_type canvas_item;

uniform sampler2D height_map : hint_default_white;
uniform sampler2D temperature_map : hint_default_white;
uniform sampler2D biome_thresholds : hint_default_white;
uniform sampler2D biome_colors : hint_default_white;

uniform float height_scale = 20.0;
uniform int biome_count = 0;
uniform vec2 pixel_size = vec2(1.0, 1.0);
const int MAX_BIOMES = 16;

void vertex() {
    float h = texture(height_map, UV).r * 2.0 - 1.0;
    VERTEX.y -= h * height_scale;
}

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

void fragment() {

    vec2 uv = pixelate(1.0/SCREEN_PIXEL_SIZE, UV);
    vec4 world_map =  texture(height_map, uv);
    float h = world_map.r * 2.0 - 1.0;
    //float is_river = step(0.9, world_map.b);
    float temp = texture(temperature_map, uv).r;
    COLOR.rgb = get_biome_color(h, temp);
    //COLOR.rgb = mix(COLOR.rgb, vec3(0.5, 0.5, 1.0), is_river);


   // COLOR.rgb = vec3(is_river, is_river,is_river);

    COLOR.a = 1.0;
}