shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Check neighboring pixels for alpha
    float alpha = sprite_color.a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    
    // Smoothstep to limit the outline
    vec4 final_color = mix(sprite_color, outline_color, step(sprite_color.a, 0.5) * step(1.0, alpha));
    COLOR = final_color;
}
