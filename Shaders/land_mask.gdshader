shader_type canvas_item;

uniform sampler2D height_map;

void fragment() {
    float height = texture(height_map, UV).r * 2.0 - 1.0; // Assuming red channel, remapped from [0,1] to [-1,1]
    if (height >= 0.0) {
        COLOR = vec4(1.0, 1.0, 1.0, 1.0); // Land: white
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Water: black
    }
}