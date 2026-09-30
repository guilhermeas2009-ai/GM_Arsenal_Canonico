/// @description Módulo Canônico de Feedback de Combate, Hitstop, Screenshake e Efeitos 3D
/// Compatível com GameMaker LTS 2026 / GML 2.3+

enum EFEITO_3D {
    FAISCA,
    CINZAS,
    POEIRA,
    RETICULA_CHAO,
    ONDA_CHOQUE
}

/// @function aplicar_hitstop(_frames)
/// @description Congela a ação global temporariamente para impacto físico visceral
function aplicar_hitstop(_frames) {
    if (!variable_global_exists("hitstop_timer")) global.hitstop_timer = 0;
    global.hitstop_timer = max(global.hitstop_timer, _frames);
}

/// @function disparar_screenshake(_forca)
/// @description Aplica tremor de tela direcional ou estocástico com amortecimento
function disparar_screenshake(_forca) {
    if (!variable_global_exists("screenshake_forca")) global.screenshake_forca = 0;
    global.screenshake_forca = max(global.screenshake_forca, _forca);
}

/// @function obter_vb_dinamico()
/// @description Obtém ou aloca o Vertex Buffer dinâmico compartilhado para efeitos 3D
function obter_vb_dinamico() {
    if (!variable_global_exists("vb_dinamico") || global.vb_dinamico == -1) {
        global.vb_dinamico = vertex_create_buffer();
    }
    return global.vb_dinamico;
}

/// @function desenhar_quad_horizontal_3d(_x, _y, _z, _raio_x, _raio_y, _cor, _alpha)
/// @description Renderiza um plano horizontal no chão (Z) para sombras e impactos
function desenhar_quad_horizontal_3d(_x, _y, _z, _raio_x, _raio_y, _cor, _alpha) {
    if (_alpha <= 0) return;
    var _vb = obter_vb_dinamico();
    vertex_begin(_vb, global.formato_vertice_3d);

    vertex_position_3d(_vb, _x - _raio_x, _y - _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 0);
    vertex_position_3d(_vb, _x + _raio_x, _y - _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 0);
    vertex_position_3d(_vb, _x - _raio_x, _y + _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 1);

    vertex_position_3d(_vb, _x + _raio_x, _y - _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 0);
    vertex_position_3d(_vb, _x + _raio_x, _y + _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 1);
    vertex_position_3d(_vb, _x - _raio_x, _y + _raio_y, _z); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 1);

    vertex_end(_vb);
    vertex_submit(_vb, pr_trianglelist, -1);
}

/// @function desenhar_sombra_projetada_3d(_x, _y, _z, _raio_x, _raio_y, _alpha)
/// @description Desenha sombra elíptica projetada diretamente sob a entidade
function desenhar_sombra_projetada_3d(_x, _y, _z, _raio_x, _raio_y, _alpha) {
    desenhar_quad_horizontal_3d(_x, _y, _z, _raio_x, _raio_y, make_color_rgb(10, 8, 14), _alpha);
}

/// @function desenhar_sombra_projetada_silhueta_3d(_sprite, _subimg, _x, _y, _z, _largura, _altura, _luz_x, _luz_y, _alpha)
/// @description Projeta a silhueta da sprite no solo deformada pela posição de uma luz
function desenhar_sombra_projetada_silhueta_3d(_sprite, _subimg, _x, _y, _z, _largura, _altura, _luz_x, _luz_y, _alpha) {
    if (_alpha <= 0.01) return;

    var _dir_luz = point_direction(_luz_x, _luz_y, _x, _y);
    var _dist_luz = point_distance(_luz_x, _luz_y, _x, _y);
    var _comprimento = clamp(24 + (180 / max(40, _dist_luz)) * 22, 20, 54);

    var _sx = lengthdir_x(_comprimento, _dir_luz);
    var _sy = lengthdir_y(_comprimento, _dir_luz);
    var _half_w = abs(_largura) * 0.42;
    var _perpx = lengthdir_x(_half_w, _dir_luz + 90);
    var _perpy = lengthdir_y(_half_w, _dir_luz + 90);

    var _uvs = sprite_get_uvs(_sprite, _subimg);
    var _u1 = _uvs[0]; var _v1 = _uvs[1];
    var _u2 = _uvs[2]; var _v2 = _uvs[3];
    var _cor_sombra = make_color_rgb(12, 10, 16);
    var _z_chao = 0.22;

    var _vb = obter_vb_dinamico();
    vertex_begin(_vb, global.formato_vertice_3d);

    vertex_position_3d(_vb, _x + _sx - _perpx * 0.7, _y + _sy - _perpy * 0.7, _z_chao); vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u1, _v1);
    vertex_position_3d(_vb, _x + _sx + _perpx * 0.7, _y + _sy + _perpy * 0.7, _z_chao); vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u2, _v1);
    vertex_position_3d(_vb, _x - _perpx, _y - _perpy, _z_chao);                           vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u1, _v2);

    vertex_position_3d(_vb, _x + _sx + _perpx * 0.7, _y + _sy + _perpy * 0.7, _z_chao); vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u2, _v1);
    vertex_position_3d(_vb, _x + _perpx, _y + _perpy, _z_chao);                           vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u2, _v2);
    vertex_position_3d(_vb, _x - _perpx, _y - _perpy, _z_chao);                           vertex_color(_vb, _cor_sombra, _alpha); vertex_texcoord(_vb, _u1, _v2);

    vertex_end(_vb);
    vertex_submit(_vb, pr_trianglelist, sprite_get_texture(_sprite, _subimg));
}

/// @function sistema_efeitos_3d_inicializar()
/// @description Inicializa o pool de partículas 3D no espaço do jogo
function sistema_efeitos_3d_inicializar() {
    global.particulas_3d = [];
}

/// @function efeito_3d_spawn(_x, _y, _z, _vx, _vy, _vz, _cor, _tam, _vida, _tipo)
/// @description Adiciona uma partícula 3D com física determinística e gravidade
function efeito_3d_spawn(_x, _y, _z, _vx, _vy, _vz, _cor, _tam, _vida, _tipo) {
    if (!variable_global_exists("particulas_3d")) global.particulas_3d = [];
    if (array_length(global.particulas_3d) > 200) return;
    array_push(global.particulas_3d, {
        pos_x: _x, pos_y: _y, pos_z: _z,
        vel_x: _vx, vel_y: _vy, vel_z: _vz,
        cor: _cor, tam: _tam, vida: _vida, vida_max: _vida,
        tipo: _tipo
    });
}

/// @function sistema_efeitos_3d_adicionar(_tipo, _x, _y, _z, _cor)
/// @description Helper rápido para espalhar faíscas ou poeira com dispersão aleatória
function sistema_efeitos_3d_adicionar(_tipo, _x, _y, _z, _cor) {
    var _vx = random_range(-1.0, 1.0);
    var _vy = random_range(-1.0, 1.0);
    var _vz = random_range(1.0, 2.5);
    efeito_3d_spawn(_x, _y, _z, _vx, _vy, _vz, _cor, 8, 14, _tipo);
}

/// @function sistema_efeitos_3d_atualizar()
/// @description Processa física de partículas, amortecimento de atrito e gravidade
function sistema_efeitos_3d_atualizar() {
    if (!variable_global_exists("particulas_3d")) return;
    var _tot = array_length(global.particulas_3d);
    for (var i = _tot - 1; i >= 0; i--) {
        var _p = global.particulas_3d[i];
        _p.vida--;
        if (_p.vida <= 0) {
            array_delete(global.particulas_3d, i, 1);
            continue;
        }
        _p.pos_x += _p.vel_x;
        _p.pos_y += _p.vel_y;
        _p.pos_z += _p.vel_z;
        if (_p.tipo != EFEITO_3D.RETICULA_CHAO && _p.tipo != EFEITO_3D.ONDA_CHOQUE) {
            _p.vel_x *= 0.92;
            _p.vel_y *= 0.92;
            if (_p.pos_z > 0.5) _p.vel_z -= 0.18;
            else { _p.pos_z = 0.5; _p.vel_z = 0; }
        } else if (_p.tipo == EFEITO_3D.ONDA_CHOQUE) {
            _p.tam += _p.vel_x;
        }
    }
}

/// @function sistema_efeitos_3d_desenhar_decais(_vb, _tot)
/// @description Renderiza lote de anéis de impacto e retículas de solo
function sistema_efeitos_3d_desenhar_decais(_vb, _tot) {
    var _tem = false;
    for (var i = 0; i < _tot; i++) {
        var _tp = global.particulas_3d[i].tipo;
        if (_tp == EFEITO_3D.RETICULA_CHAO || _tp == EFEITO_3D.ONDA_CHOQUE) {
            _tem = true;
            break;
        }
    }
    if (!_tem) return;

    vertex_begin(_vb, global.formato_vertice_3d);
    for (var i = 0; i < _tot; i++) {
        var _p = global.particulas_3d[i];
        if (_p.tipo == EFEITO_3D.RETICULA_CHAO || _p.tipo == EFEITO_3D.ONDA_CHOQUE) {
            var _alpha = clamp(_p.vida / _p.vida_max, 0.0, 1.0) * 0.7;
            var _rx = _p.tam;
            var _ry = _p.tam * 0.7;
            var _px = _p.pos_x;
            var _py = _p.pos_y;
            var _cor = _p.cor;
            vertex_position_3d(_vb, _px - _rx, _py - _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 0);
            vertex_position_3d(_vb, _px + _rx, _py - _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 0);
            vertex_position_3d(_vb, _px - _rx, _py + _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 1);

            vertex_position_3d(_vb, _px + _rx, _py - _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 0);
            vertex_position_3d(_vb, _px + _rx, _py + _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 1, 1);
            vertex_position_3d(_vb, _px - _rx, _py + _ry, 0.6); vertex_color(_vb, _cor, _alpha); vertex_texcoord(_vb, 0, 1);
        }
    }
    vertex_end(_vb);
    vertex_submit(_vb, pr_trianglelist, -1);
}

/// @function sistema_efeitos_3d_desenhar_billboards(_vb, _tot, _cam_x, _cam_y)
/// @description Renderiza lote de partículas billboard cilíndricas (faíscas, cinzas, poeira)
function sistema_efeitos_3d_desenhar_billboards(_vb, _tot, _cam_x, _cam_y) {
    vertex_begin(_vb, global.formato_vertice_3d);
    for (var i = 0; i < _tot; i++) {
        var _p = global.particulas_3d[i];
        if (_p.tipo == EFEITO_3D.FAISCA || _p.tipo == EFEITO_3D.CINZAS || _p.tipo == EFEITO_3D.POEIRA) {
            var _alpha = clamp(_p.vida / _p.vida_max, 0.0, 1.0);
            var _hw = _p.tam * 0.5;
            var _alt = _p.tam;
            var _px = _p.pos_x;
            var _py = _p.pos_y;
            var _pz = _p.pos_z;
            var _dir = point_direction(_px, _py, _cam_x, _cam_y);
            var _dx = lengthdir_x(_hw, _dir + 90);
            var _dy = lengthdir_y(_hw, _dir + 90);

            vertex_position_3d(_vb, _px - _dx, _py - _dy, _pz + _alt); vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 0, 0);
            vertex_position_3d(_vb, _px + _dx, _py + _dy, _pz + _alt); vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 1, 0);
            vertex_position_3d(_vb, _px - _dx, _py - _dy, _pz);        vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 0, 1);

            vertex_position_3d(_vb, _px + _dx, _py + _dy, _pz + _alt); vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 1, 0);
            vertex_position_3d(_vb, _px + _dx, _py + _dy, _pz);        vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 1, 1);
            vertex_position_3d(_vb, _px - _dx, _py - _dy, _pz);        vertex_color(_vb, _p.cor, _alpha); vertex_texcoord(_vb, 0, 1);
        }
    }
    vertex_end(_vb);
    vertex_submit(_vb, pr_trianglelist, -1);
}

/// @function sistema_efeitos_3d_desenhar()
/// @description Despacha os lotes de renderização de efeitos 3D na cena
function sistema_efeitos_3d_desenhar() {
    if (!variable_global_exists("particulas_3d")) return;
    var _tot = array_length(global.particulas_3d);
    if (_tot == 0) return;

    var _vb = obter_vb_dinamico();
    var _cam_x = variable_global_exists("camera_x") ? global.camera_x : 256;
    var _cam_y = variable_global_exists("camera_y") ? global.camera_y : 356;

    sistema_efeitos_3d_desenhar_decais(_vb, _tot);
    sistema_efeitos_3d_desenhar_billboards(_vb, _tot, _cam_x, _cam_y);
}
