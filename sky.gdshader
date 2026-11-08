shader_type sky;

uniform vec3 sky_color : source_color = vec3(0.005, 0.005, 0.01);
uniform float star_density : hint_range(1.0, 200.0) = 80.0;
uniform float star_brightness : hint_range(0.1, 10.0) = 2.5;

float hash(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

void sky() {
    vec3 col = sky_color;

    vec3 dir = EYEDIR * star_density;
    vec3 grid_id = floor(dir);
    
    float n = hash(grid_id);
    if (n > 0.94) {
        vec3 cell_pos = fract(dir) - 0.5;
        float dist = length(cell_pos);
        float star = smoothstep(0.15, 0.0, dist) * star_brightness;
        
        col += vec3(star);
    }

    COLOR = col;
}