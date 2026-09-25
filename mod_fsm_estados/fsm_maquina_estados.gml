/// @description Módulo Canônico de Máquina de Estados Finita (FSM/HSM)
/// Projetado para GameMaker LTS 2026 / GML 2.3+
/// Diretrizes: Funções curtas (<50 linhas), structs nativas, zero booleans conflitantes.

/// @function fsm_criar(_estado_inicial)
/// @description Cria uma nova instância de Máquina de Estados Finita.
function fsm_criar(_estado_inicial) {
    return {
        estado_atual: _estado_inicial,
        estado_anterior: _estado_inicial,
        tempo_no_estado: 0,
        estados: {},
        mudou_de_estado_neste_frame: false
    };
}

/// @function fsm_adicionar_estado(_fsm, _nome_estado, _config)
/// @description Registra um novo estado com seus ganchos de ciclo de vida.
function fsm_adicionar_estado(_fsm, _nome_estado, _config) {
    _fsm.estados[$ _nome_estado] = {
        on_enter: variable_struct_exists(_config, "on_enter") ? _config.on_enter : undefined,
        on_step:  variable_struct_exists(_config, "on_step")  ? _config.on_step  : undefined,
        on_draw:  variable_struct_exists(_config, "on_draw")  ? _config.on_draw  : undefined,
        on_leave: variable_struct_exists(_config, "on_leave") ? _config.on_leave : undefined
    };
    return _fsm;
}

/// @function fsm_mudar_estado(_fsm, _novo_estado)
/// @description Transiciona a máquina para um novo estado com ganchos de saída e entrada.
function fsm_mudar_estado(_fsm, _novo_estado) {
    if (_fsm.estado_atual == _novo_estado) return;

    var _dados_atual = _fsm.estados[$ _fsm.estado_atual];
    if (_dados_atual != undefined && is_callable(_dados_atual.on_leave)) {
        _dados_atual.on_leave();
    }

    _fsm.estado_anterior = _fsm.estado_atual;
    _fsm.estado_atual = _novo_estado;
    _fsm.tempo_no_estado = 0;
    _fsm.mudou_de_estado_neste_frame = true;

    var _dados_novo = _fsm.estados[$ _novo_estado];
    if (_dados_novo != undefined && is_callable(_dados_novo.on_enter)) {
        _dados_novo.on_enter();
    }
}

/// @function fsm_executar_step(_fsm)
/// @description Executa a lógica de step do estado atual e incrementa o contador temporal.
function fsm_executar_step(_fsm) {
    _fsm.mudou_de_estado_neste_frame = false;
    var _dados = _fsm.estados[$ _fsm.estado_atual];
    if (_dados != undefined && is_callable(_dados.on_step)) {
        _dados.on_step();
    }
    _fsm.tempo_no_estado++;
}

/// @function fsm_executar_draw(_fsm)
/// @description Executa a rotina de desenho associada ao estado atual, se definida.
function fsm_executar_draw(_fsm) {
    var _dados = _fsm.estados[$ _fsm.estado_atual];
    if (_dados != undefined && is_callable(_dados.on_draw)) {
        _dados.on_draw();
    }
}

/// @function fsm_obter_estado(_fsm)
/// @description Retorna o nome identificador do estado atual da FSM.
function fsm_obter_estado(_fsm) {
    return _fsm.estado_atual;
}

/// @function fsm_obter_estado_anterior(_fsm)
/// @description Retorna o identificador do estado imediatamente anterior.
function fsm_obter_estado_anterior(_fsm) {
    return _fsm.estado_anterior;
}

/// @function fsm_obter_tempo(_fsm)
/// @description Retorna o número de frames decorridos no estado ativo.
function fsm_obter_tempo(_fsm) {
    return _fsm.tempo_no_estado;
}
