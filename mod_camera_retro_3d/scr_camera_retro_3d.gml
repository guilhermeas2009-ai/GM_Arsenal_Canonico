/// @description Módulo Canônico de Câmera 3D em Perspectiva Tática Elevada
/// Compatível com GameMaker LTS 2026

/// @function camera_3d_criar(_fov, _znear, _zfar, _inclinacao_graus, _distancia)
/// @description Cria uma estrutura para controle da projeção 3D e matriz de visão LookAt.
function camera_3d_criar(_fov, _znear, _zfar, _inclinacao_graus, _distancia) {
    return {
        fov: _fov,
        znear: _znear,
        zfar: _zfar,
        inclinacao: _inclinacao_graus,
        distancia: _distancia,
        alvo_x: 0, alvo_y: 0, alvo_z: 0,
        cam_x: 0, cam_y: 0, cam_z: 0,
        shake_forca: 0,
        shake_offset_x: 0,
        shake_offset_y: 0
    };
}

/// @function camera_3d_atualizar(_cam, _foco_x, _foco_y, _foco_z, _suavizacao)
/// @description Atualiza posição do foco e computa coordenadas da câmera no espaço 3D.
function camera_3d_atualizar(_cam, _foco_x, _foco_y, _foco_z, _suavizacao) {
    _cam.alvo_x = lerp(_cam.alvo_x, _foco_x, _suavizacao);
    _cam.alvo_y = lerp(_cam.alvo_y, _foco_y, _suavizacao);
    _cam.alvo_z = lerp(_cam.alvo_z, _foco_z, _suavizacao);

    // Decaimento determinístico do screenshake
    if (_cam.shake_forca > 0.05) {
        _cam.shake_offset_x = random_range(-_cam.shake_forca, _cam.shake_forca);
        _cam.shake_offset_y = random_range(-_cam.shake_forca, _cam.shake_forca);
        _cam.shake_forca *= 0.88;
    } else {
        _cam.shake_forca = 0;
        _cam.shake_offset_x = 0;
        _cam.shake_offset_y = 0;
    }

    var _rad = degtorad(_cam.inclinacao);
    var _offset_y = cos(_rad) * _cam.distancia;
    var _offset_z = sin(_rad) * _cam.distancia;

    _cam.cam_x = _cam.alvo_x + _cam.shake_offset_x;
    _cam.cam_y = _cam.alvo_y + _offset_y + _cam.shake_offset_y;
    _cam.cam_z = _cam.alvo_z + _offset_z;
}

/// @function camera_3d_aplicar(_cam, _largura_viewport, _altura_viewport)
/// @description Aplica as matrizes de projeção de perspectiva e visão LookAt na GPU.
function camera_3d_aplicar(_cam, _largura_viewport, _altura_viewport) {
    var _aspecto = max(1.0, _largura_viewport) / max(1.0, _altura_viewport);
    var _proj = matrix_build_projection_perspective_fov(-_cam.fov, -_aspecto, _cam.znear, _cam.zfar);
    var _view = matrix_build_lookat(_cam.cam_x, _cam.cam_y, _cam.cam_z, _cam.alvo_x, _cam.alvo_y, _cam.alvo_z, 0, 0, 1);

    camera_set_proj_mat(camera_get_active(), _proj);
    camera_set_view_mat(camera_get_active(), _view);
    camera_apply(camera_get_active());
}

/// @function camera_3d_disparar_shake(_cam, _forca)
/// @description Dispara tremor de câmera com teto máximo determinístico.
function camera_3d_disparar_shake(_cam, _forca) {
    _cam.shake_forca = min(24.0, _cam.shake_forca + _forca);
}
