/// @description Módulo Canônico de Combate e Telegrafia Estilo Souls-like
/// Compatível com GameMaker LTS 2026 / GML 2.3+

/// @function combate_iniciar_entidade(_hp_max)
/// @description Inicializa a estrutura de combate em uma entidade (jogador, inimigo ou chefe).
function combate_iniciar_entidade(_hp_max) {
    return {
        hp_max: _hp_max,
        hp_atual: _hp_max,
        iframes: 0,
        telegrafia_timer: 0,
        telegrafia_duracao: 0,
        telegrafia_tipo: 0, // 0 = Inativo, 1 = Aviso Leve, 2 = Ataque Pesado
        em_hitstop: 0,
        vetor_knockback_x: 0,
        vetor_knockback_y: 0
    };
}

/// @function combate_processar_timers(_combate)
/// @description Atualiza timers de invulnerabilidade, telegrafia e decaimento de knockback.
function combate_processar_timers(_combate) {
    if (_combate.iframes > 0) _combate.iframes--;
    if (_combate.telegrafia_timer > 0) {
        _combate.telegrafia_timer--;
        if (_combate.telegrafia_timer == 0) _combate.telegrafia_tipo = 0;
    }
    if (_combate.em_hitstop > 0) _combate.em_hitstop--;

    _combate.vetor_knockback_x *= 0.82;
    _combate.vetor_knockback_y *= 0.82;
    if (abs(_combate.vetor_knockback_x) < 0.1) _combate.vetor_knockback_x = 0;
    if (abs(_combate.vetor_knockback_y) < 0.1) _combate.vetor_knockback_y = 0;
}

/// @function combate_iniciar_telegrafia(_combate, _duracao, _tipo)
/// @description Dispara a janela de preparação telegrafada de um golpe perigoso.
function combate_iniciar_telegrafia(_combate, _duracao, _tipo) {
    _combate.telegrafia_duracao = max(1, _duracao);
    _combate.telegrafia_timer = _combate.telegrafia_duracao;
    _combate.telegrafia_tipo = _tipo;
}

/// @function combate_obter_intensidade_telegrafia(_combate)
/// @description Retorna um valor normalizado (0.0 a 1.0) indicando a proximidade do disparo do golpe.
function combate_obter_intensidade_telegrafia(_combate) {
    if (_combate.telegrafia_timer <= 0 || _combate.telegrafia_duracao <= 0) return 0.0;
    var _progresso = 1.0 - (_combate.telegrafia_timer / _combate.telegrafia_duracao);
    return clamp(_progresso, 0.0, 1.0);
}

/// @function combate_aplicar_dano(_alvo, _combate, _dano, _origem_x, _origem_y, _knockback_forca, _iframes_concedidos)
/// @description Aplica dano com verificação estrita de frames de invulnerabilidade.
function combate_aplicar_dano(_alvo, _combate, _dano, _origem_x, _origem_y, _knockback_forca, _iframes_concedidos) {
    if (_combate.iframes > 0) return false;

    _combate.hp_atual = max(0, _combate.hp_atual - _dano);
    _combate.iframes = max(0, _iframes_concedidos);

    var _dir = point_direction(_origem_x, _origem_y, _alvo.x, _alvo.y);
    _combate.vetor_knockback_x = lengthdir_x(_knockback_forca, _dir);
    _combate.vetor_knockback_y = lengthdir_y(_knockback_forca, _dir);
    return true;
}

/// @function combate_verificar_acerto_cone(_origem_x, _origem_y, _dir, _alcance, _abertura_graus, _alvo_x, _alvo_y)
/// @description Verifica deterministamente se um alvo está dentro do arco cônico de um ataque.
function combate_verificar_acerto_cone(_origem_x, _origem_y, _dir, _alcance, _abertura_graus, _alvo_x, _alvo_y) {
    var _dist = point_distance(_origem_x, _origem_y, _alvo_x, _alvo_y);
    if (_dist > _alcance) return false;

    var _ang_para_alvo = point_direction(_origem_x, _origem_y, _alvo_x, _alvo_y);
    var _dif_ang = abs(angle_difference(_dir, _ang_para_alvo));
    return (_dif_ang <= (_abertura_graus * 0.5));
}
