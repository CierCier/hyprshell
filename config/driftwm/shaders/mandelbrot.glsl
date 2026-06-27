// Infinite-zoom Mandelbrot — smooth coloring, continuous zoom into Seahorse Valley
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform vec2 u_camera;
uniform float u_time;

// Cosine palette
vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

// Double-single add: (a.hi, a.lo) + (b.hi, b.lo) → (s.hi, s.lo)
// Preserves ~14 digits of precision using two floats.
vec2 ds_add(vec2 a, vec2 b) {
    float s = a.x + b.x;
    float e = (a.x - s) + b.x + a.y + b.y;
    return vec2(s, e);
}

// Split a float into high and low parts (Dekker splitting)
vec2 ds_split(float a) {
    float t = 4097.0 * a;   // 2^12 + 1
    float hi = t - (t - a);
    return vec2(hi, a - hi);
}

// Double-single multiply: (a.hi, a.lo) * (b.hi, b.lo) → (p.hi, p.lo)
// Uses Dekker's method to recover the rounding error of a.x * b.x.
vec2 ds_mul(vec2 a, vec2 b) {
    float p = a.x * b.x;
    vec2 sa = ds_split(a.x);
    vec2 sb = ds_split(b.x);
    float e = ((sa.x * sb.x - p) + sa.x * sb.y + sa.y * sb.x) + sa.y * sb.y
              + a.x * b.y + a.y * b.x;
    return vec2(p, e);
}

void main() {
    // World-space pixel coordinate (matches clouds.glsl / cmatrix.glsl)
    vec2 fragCoord = v_coords * size + u_camera;
    vec2 uv = (fragCoord - 0.5 * size) / min(size.x, size.y);

    // Zoom target: Seahorse Valley — splits preserve full precision.
    //   real: -0.7453 + 0.00001180 = -0.74528820
    //   imag:  0.1127 + 0.00000310 =  0.11270310
    // These sit right on the filament between the main cardioid and the
    // period-2 bulb — spirals and mini-brots at every scale.
    vec2 tgt_re = vec2(-0.7453, 0.00001180);
    vec2 tgt_im = vec2( 0.1127, 0.00000310);

    // Cyclic zoom: exponent ramps 0→38, then resets.
    // 2^38 ≈ 2.7e11 — stays within float mantissa headroom.
    float zoomExp = mod(u_time * 0.4, 38.0);
    float zoom = pow(2.0, zoomExp);

    // Map pixel to complex plane in double-single precision.
    // c = target + uv * 2.5 / zoom
    float scale = 2.5 / zoom;
    vec2 c_re = ds_add(tgt_re, vec2(uv.x * scale, 0.0));
    vec2 c_im = ds_add(tgt_im, vec2(uv.y * scale, 0.0));

    // Mandelbrot iteration in double-single precision:
    //   z = z^2 + c
    //   z_re' = z_re^2 - z_im^2 + c_re
    //   z_im' = 2 * z_re * z_im + c_im
    vec2 z_re = vec2(0.0);
    vec2 z_im = vec2(0.0);
    float iter = 0.0;
    const int MAX_ITER = 256;
    const float BAILOUT = 256.0;

    for (int i = 0; i < MAX_ITER; i++) {
        vec2 zr2 = ds_mul(z_re, z_re);
        vec2 zi2 = ds_mul(z_im, z_im);

        // Bail on |z|^2 > BAILOUT (single-float check is fine)
        if (zr2.x + zi2.x > BAILOUT) break;

        vec2 zri = ds_mul(z_re, z_im);

        z_re = ds_add(ds_add(zr2, vec2(-zi2.x, -zi2.y)), c_re);
        z_im = ds_add(ds_add(zri, zri), c_im);
        iter += 1.0;
    }

    vec3 col;
    float mag2 = z_re.x * z_re.x + z_im.x * z_im.x;

    if (iter >= float(MAX_ITER)) {
        col = vec3(0.0);
    } else {
        // Smooth iteration count (removes banding)
        float sl = iter - log2(log2(mag2)) + 4.0;

        // Rotate palette with zoom depth so colors evolve
        float t = sl * 0.02 + zoomExp * 0.03;
        col = palette(t);
        col *= smoothstep(0.0, 3.0, sl);
    }

    gl_FragColor = vec4(col, 1.0);
}
