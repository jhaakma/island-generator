shader_type canvas_item;

uniform vec2 pixel_size = vec2(4.0, 4.0); // Size of each pixel "block"

void fragment() {
    vec2 screen_res = 1.0/TEXTURE_PIXEL_SIZE;
    // Snap UV to pixel grid
    vec2 uv = floor(UV * screen_res / pixel_size) * pixel_size / screen_res;

    // Sample the source texture at the snapped UV
    COLOR = texture(TEXTURE, uv);
}