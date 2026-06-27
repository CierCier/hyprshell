// Procedural cmatrix — falling green katakana rain
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform vec2 u_camera;
uniform float u_time;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// SDF for '+' (cross / plus sign)
float plusSDF(vec2 uv) {
    vec2 c = uv - 0.5;
    return min(abs(c.x), abs(c.y)) - 0.035;
}

// SDF for '|' (vertical bar)
float pipeSDF(vec2 uv) {
    return abs(uv.x - 0.5) - 0.035;
}

void main() {
    const float CELL_W    = 12.0;
    const float CELL_H    = 18.0;
    const float LINE_W    = 0.08;
    const int   STREAMS   = 2;
    const float CYCLE     = 120.0;

    // World-space fragment coordinate (matches clouds.glsl pattern)
    vec2 fragCoord = v_coords * size + u_camera;

    // Continuous cell position (not floored — keeps sub-cell fraction)
    vec2 cellPos = fragCoord / vec2(CELL_W, CELL_H);
    vec2 cell    = floor(cellPos);
    vec2 sub     = cellPos - cell;

    // Subtle green ambient glow
    vec3 color = vec3(0.0, 0.005, 0.0);

    for (int s = 0; s < STREAMS; s++) {
        float sf = float(s);

        // Per-column, per-stream deterministic parameters
        float speed    = 1.5 + 2.0 * hash(vec2(cell.x, sf * 71.0));
        float phase    = hash(vec2(cell.x + 1.0, sf * 113.0)) * CYCLE;
        float trailLen = 5.0 + 7.0 * hash(vec2(cell.x + 2.0, sf * 37.0));

        // Continuous head position — fractional, so motion is smooth
        float headY = mod(phase - u_time * speed, CYCLE);
        float cellY = mod(cell.y, CYCLE);
        float dist  = mod(headY - cellY, CYCLE);

        if (dist < trailLen) {
            // Smooth brightness: fade in at head, fade out at tail
            float headFade = smoothstep(0.0, 1.5, dist);
            float tailFade = 1.0 - smoothstep(trailLen - 2.0, trailLen, dist);
            float brightness = headFade * tailFade;

            // Color: near-white at head, pure green in trail
            float headProx = 1.0 - smoothstep(0.0, 2.0, dist);
            vec3 charColor = mix(
                vec3(0.0, brightness * 0.7, 0.0),
                vec3(0.3, 1.0, 0.2),
                headProx
            );

            // Head → '+', trail → '|', smooth crossfade
            float pSdf = plusSDF(sub);
            float bSdf = pipeSDF(sub);
            float blend = smoothstep(0.5, 1.5, dist);
            float sdf   = mix(pSdf, bSdf, blend);

            float alpha = 1.0 - smoothstep(0.0, LINE_W, max(sdf, 0.0));
            color = mix(color, charColor, alpha * brightness);
        }
    }

    gl_FragColor = vec4(color, 1.0);
}
