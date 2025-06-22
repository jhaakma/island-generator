shader_type canvas_item;

uniform float pixel_size = 1.0;

void fragment() {
   
    
    vec2 screen_res = 1.0/TEXTURE_PIXEL_SIZE;
    vec2 p = vec2(pixel_size, pixel_size);
    // Snap UV to pixel grid
    vec2 uv = UV;
    if (pixel_size > 0.0) {
        uv = floor(UV * screen_res / p) * p / screen_res;
    }

    // Sample the source texture at the snapped UV
    COLOR = texture(TEXTURE, uv);
}