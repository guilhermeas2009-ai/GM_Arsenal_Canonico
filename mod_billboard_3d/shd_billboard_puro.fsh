varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord);
    if (base_color.a < 0.05) discard;
    gl_FragColor = v_vColour * base_color;
}
