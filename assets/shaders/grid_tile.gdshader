shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(0.5, 0.5, 0.5, 0.3);
uniform float border_thickness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec2 uv = UV;
    
    // Create border effect
    float border = 0.0;
    if (uv.x < border_thickness || uv.x > (1.0 - border_thickness) ||
        uv.y < border_thickness || uv.y > (1.0 - border_thickness)) {
        border = 1.0;
    }
    
    COLOR = grid_color * border;
} 