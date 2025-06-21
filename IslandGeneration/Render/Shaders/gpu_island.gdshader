//Godot 4.4.1 gdshader

shader_type canvas_item;

uniform sampler2D height_map : hint_default_white;
uniform sampler2D temperature_map : hint_default_white;
uniform sampler2D biome_thresholds : hint_default_white;
uniform sampler2D biome_colors : hint_default_white;

uniform float outline_color_multi = 0.6;
uniform float outline_thickness = 0.3;
uniform int biome_count = 0;
uniform float pixel_size = 1.0;
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
    // Snap UV to pixel grid with half-pixel offset
    vec2 pix_size = max(vec2(pixel_size, pixel_size), vec2(0.0001, 0.0001));
    vec2 grid = screen_uv * screen_res / pix_size;
    grid = floor(grid) + 0.5;
    return grid * pix_size / screen_res;
}

/* Outline effect

    Draw a single black pixel outline at the edge of 0.0 height
*/
float outline_shoreline(vec2 uv) {
    vec2 tex_size = vec2(textureSize(height_map, 0));
    float h = texture(height_map, uv).r * 2.0 - 1.0;

    // Offsets for 8-connected neighbors (one texel in each direction)dww
    vec2 offsets[8] = vec2[](
        vec2(-1, -1), vec2(0, -1), vec2(1, -1),
        vec2(-1,  0),              vec2(1,  0),
        vec2(-1,  1), vec2(0,  1), vec2(1,  1)
    );

    bool has_land = false;
    bool has_water = false;
    for (int i = 0; i < 8; i++) {
        vec2 neighbor_uv = uv + offsets[i] / tex_size * outline_thickness;
        float neighbor_h = texture(height_map, neighbor_uv).r * 2.0 - 1.0;
        if (neighbor_h < 0.0) {
            has_water = true;
        } else if (neighbor_h > 0.0) {
            has_land = true;
        }
    }
    return float(has_land && has_water);
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