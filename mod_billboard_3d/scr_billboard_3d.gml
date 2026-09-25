/// @description Utilitários de Billboarding 3D via GPU
/// Compatível com GameMaker LTS 2026

/// @function billboard_iniciar_pipeline(_shader_id, _esferico)
/// @description Ativa o shader de billboarding e configura o uniforme esférico/cilíndrico.
function billboard_iniciar_pipeline(_shader_id, _esferico) {
    shader_set(_shader_id);
    var _u_esf = shader_get_uniform(_shader_id, "u_modo_esferico");
    if (_u_esf != -1) {
        shader_set_uniform_f(_u_esf, _esferico ? 1.0 : 0.0);
    }
}

/// @function billboard_encerrar_pipeline()
/// @description Restaura o shader padrão após o desenho de billboards.
function billboard_encerrar_pipeline() {
    shader_reset();
}

/// @function billboard_desenhar_sprite(_sprite, _subimg, _x, _y, _z, _xscale, _yscale, _rot, _cor, _alpha)
/// @description Renderiza um sprite no espaço 3D usando matriz de mundo para translação.
function billboard_desenhar_sprite(_sprite, _subimg, _x, _y, _z, _xscale, _yscale, _rot, _cor, _alpha) {
    var _mat_mundo = matrix_build(_x, _y, _z, 0, 0, _rot, _xscale, _yscale, 1.0);
    var _mat_anterior = matrix_get(matrix_world);

    matrix_set(matrix_world, _mat_mundo);
    draw_sprite_ext(_sprite, _subimg, 0, 0, 1.0, 1.0, 0, _cor, _alpha);
    matrix_set(matrix_world, _mat_anterior);
}
