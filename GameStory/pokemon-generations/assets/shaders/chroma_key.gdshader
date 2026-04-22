shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float softness : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate brightness (grayscale value)
    float gray = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    
    // Smoothstep creates a soft alpha mask based on brightness
    // Discards pixels close to black
    float alpha = smoothstep(threshold, threshold + softness, gray);
    
    COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}
