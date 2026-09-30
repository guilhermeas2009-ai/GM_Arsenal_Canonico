/// @description Módulo Canônico de Geometria 3D Procedural e Colisão de Cenário
/// Compatível com GameMaker LTS 2026 / GML 2.3+

enum LAYOUT_SALA {
    PADRAO_LAVA,
    FOSSOS_CRUZADOS,
    ARENA_PILAR_CENTRAL,
    ARENA_CHEFE
}

/// @function criar_formato_vertice_3d()
/// @description Registra o formato de vértice 3D padrão (Posição 3D + Cor + UV)
function criar_formato_vertice_3d() {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_colour();
    vertex_format_add_texcoord();
    return vertex_format_end();
}

/// @function adicionar_quad_3d(_vb, _x1, _y1, _z1, _x2, _y2, _z2, _x3, _y3, _z3, _x4, _y4, _z4, _cor, _u1, _v1, _u2, _v2)
/// @description Adiciona 2 triângulos (quad) diretamente no Vertex Buffer
function adicionar_quad_3d(_vb, _x1, _y1, _z1, _x2, _y2, _z2, _x3, _y3, _z3, _x4, _y4, _z4, _cor, _u1, _v1, _u2, _v2) {
    // Triângulo 1
    vertex_position_3d(_vb, _x1, _y1, _z1); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u1, _v1);
    vertex_position_3d(_vb, _x2, _y2, _z2); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u2, _v1);
    vertex_position_3d(_vb, _x3, _y3, _z3); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u1, _v2);

    // Triângulo 2
    vertex_position_3d(_vb, _x2, _y2, _z2); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u2, _v1);
    vertex_position_3d(_vb, _x4, _y4, _z4); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u2, _v2);
    vertex_position_3d(_vb, _x3, _y3, _z3); vertex_color(_vb, _cor, 1.0); vertex_texcoord(_vb, _u1, _v2);
}

/// @function eh_area_grade_lava_layout(_gx, _gy, _layout)
/// @description Determina se uma coordenada em grade (32x32) pertence a fosso perigoso
function eh_area_grade_lava_layout(_gx, _gy, _layout) {
    switch (_layout) {
        case LAYOUT_SALA.PADRAO_LAVA:
            var _fosso_esq = (_gx >= 128 && _gx < 192 && _gy >= 224 && _gy < 288);
            var _fosso_dir = (_gx >= 320 && _gx < 384 && _gy >= 224 && _gy < 288);
            return (_fosso_esq || _fosso_dir);

        case LAYOUT_SALA.FOSSOS_CRUZADOS:
            var _f1 = (_gx >= 128 && _gx < 160 && _gy >= 160 && _gy < 192);
            var _f2 = (_gx >= 352 && _gx < 384 && _gy >= 160 && _gy < 192);
            var _f3 = (_gx >= 128 && _gx < 160 && _gy >= 320 && _gy < 352);
            var _f4 = (_gx >= 352 && _gx < 384 && _gy >= 320 && _gy < 352);
            return (_f1 || _f2 || _f3 || _f4);

        case LAYOUT_SALA.ARENA_PILAR_CENTRAL:
            return false;

        case LAYOUT_SALA.ARENA_CHEFE:
            return (_gx >= 64 && _gx < 448 && _gy >= 32 && _gy < 64);

        default:
            return false;
    }
}

/// @function obter_posicoes_pilares_layout(_layout)
/// @description Retorna array com coordenadas centrais dos pilares conforme o layout
function obter_posicoes_pilares_layout(_layout) {
    switch (_layout) {
        case LAYOUT_SALA.PADRAO_LAVA:
            return [[96, 96], [416, 96], [96, 384], [416, 384]];

        case LAYOUT_SALA.FOSSOS_CRUZADOS:
            return [[64, 128], [448, 128], [64, 352], [448, 352]];

        case LAYOUT_SALA.ARENA_PILAR_CENTRAL:
            return [[192, 192], [320, 192], [192, 320], [320, 320]];

        case LAYOUT_SALA.ARENA_CHEFE:
            return [[96, 128], [416, 128], [96, 384], [416, 384]];

        default:
            return [[96, 96], [416, 96], [96, 384], [416, 384]];
    }
}

/// @function resolver_colisao_pilares(_x, _y, _raio, _pils)
/// @description Empurra o ponto para fora do raio dos pilares cilíndricos
function resolver_colisao_pilares(_x, _y, _raio, _pils) {
    var _novo_x = _x;
    var _novo_y = _y;
    var _raio_pilar = 16;
    var _dist_min = _raio + _raio_pilar;

    for (var i = 0; i < array_length(_pils); i++) {
        var _px = _pils[i][0];
        var _py = _pils[i][1];
        var _dist = point_distance(_novo_x, _novo_y, _px, _py);
        if (_dist < _dist_min && _dist > 0.01) {
            var _dir = point_direction(_px, _py, _novo_x, _novo_y);
            _novo_x = _px + lengthdir_x(_dist_min, _dir);
            _novo_y = _py + lengthdir_y(_dist_min, _dir);
        }
    }
    return [_novo_x, _novo_y];
}

/// @function construir_piso_e_lava_catacumba_layout(_vb_chao, _vb_lava, _largura, _altura, _layout, _u_chao, _u_lava)
/// @description Gera a malha quadriculada de piso e perigos em tempo de execução
function construir_piso_e_lava_catacumba_layout(_vb_chao, _vb_lava, _largura, _altura, _layout, _u_chao, _u_lava) {
    vertex_begin(_vb_chao, global.formato_vertice_3d);
    vertex_begin(_vb_lava, global.formato_vertice_3d);

    var _passo = 32;
    for (var _gx = 0; _gx < _largura; _gx += _passo) {
        for (var _gy = 0; _gy < _altura; _gy += _passo) {
            if (eh_area_grade_lava_layout(_gx, _gy, _layout)) {
                adicionar_quad_3d(_vb_lava, _gx, _gy, 0.2, _gx + _passo, _gy, 0.2, _gx, _gy + _passo, 0.2, _gx + _passo, _gy + _passo, 0.2, c_white, _u_lava[0], _u_lava[1], _u_lava[2], _u_lava[3]);
            } else {
                adicionar_quad_3d(_vb_chao, _gx, _gy, 0, _gx + _passo, _gy, 0, _gx, _gy + _passo, 0, _gx + _passo, _gy + _passo, 0, c_white, _u_chao[0], _u_chao[1], _u_chao[2], _u_chao[3]);
            }
        }
    }

    vertex_end(_vb_chao);
    vertex_end(_vb_lava);
}

/// @function construir_paredes_catacumba(_vb, _largura, _altura, _teto_z, _uvs)
/// @description Ergue o perímetro de paredes verticais fechando a câmara 3D
function construir_paredes_catacumba(_vb, _largura, _altura, _teto_z, _uvs) {
    vertex_begin(_vb, global.formato_vertice_3d);
    var _u1 = _uvs[0]; var _v1 = _uvs[1];
    var _u2 = _uvs[2]; var _v2 = _uvs[3];
    var _passo = 32;

    // Parede Norte (Y = 0) e Parede Sul (Y = _altura)
    for (var _gx = 0; _gx < _largura; _gx += _passo) {
        for (var _gz = 0; _gz < _teto_z; _gz += _passo) {
            var _alt = min(_passo, _teto_z - _gz);
            adicionar_quad_3d(_vb, _gx, 0, _gz + _alt, _gx + _passo, 0, _gz + _alt, _gx, 0, _gz, _gx + _passo, 0, _gz, c_white, _u1, _v1, _u2, _v2);
            adicionar_quad_3d(_vb, _gx + _passo, _altura, _gz + _alt, _gx, _altura, _gz + _alt, _gx + _passo, _altura, _gz, _gx, _altura, _gz, c_white, _u1, _v1, _u2, _v2);
        }
    }

    // Parede Oeste (X = 0) e Parede Leste (X = _largura)
    for (var _gy = 0; _gy < _altura; _gy += _passo) {
        for (var _gz = 0; _gz < _teto_z; _gz += _passo) {
            var _alt = min(_passo, _teto_z - _gz);
            adicionar_quad_3d(_vb, 0, _gy + _passo, _gz + _alt, 0, _gy, _gz + _alt, 0, _gy + _passo, _gz, 0, _gy, _gz, c_white, _u1, _v1, _u2, _v2);
            adicionar_quad_3d(_vb, _largura, _gy, _gz + _alt, _largura, _gy + _passo, _gz + _alt, _largura, _gy, _gz, _largura, _gy + _passo, _gz, c_white, _u1, _v1, _u2, _v2);
        }
    }

    vertex_end(_vb);
}
