/// @description Módulo Canônico de Máquina de Estados Finita (FSM/HSM)
/// Projetado para GameMaker LTS 2026 / GML 2.3+
/// Diretrizes: Funções curtas (<50 linhas), vinculação estrita de escopo (method/with), zero booleans conflitantes.

/// @function fsm_criar(_estado_inicial, _escopo)
/// @description Cria uma nova instância de Máquina de Estados Finita vinculada ao dono.
function fsm_criar(_estado_inicial, _escopo = undefined) {
    var _dono = _escopo;
    if (_dono == undefined) {
        _dono = variable_instance_exists(self, "id") ? id : self;
    }
    return {
        dono: _dono,
        estado_atual: _estado_inicial,
        estado_anterior: _estado_inicial,
        tempo_no_estado: 0,
        estados: {},
        mudou_de_estado_neste_frame: false
    };
}

/// @function fsm_adicionar_estado(_fsm, _nome_estado, _config)
/// @description Registra um novo estado vinculando os ganchos ao escopo da instância dona.
function fsm_adicionar_estado(_fsm, _nome_estado, _config) {
    var _dono = _fsm.dono;
    var _ent = (variable_struct_exists(_config, "on_enter") && is_callable(_config.on_enter)) ? method(_dono, _config.on_enter) : undefined;
    var _stp = (variable_struct_exists(_config, "on_step")  && is_callable(_config.on_step))  ? method(_dono, _config.on_step)  : undefined;
    var _drw = (variable_struct_exists(_config, "on_draw")  && is_callable(_config.on_draw))  ? method(_dono, _config.on_draw)  : undefined;
    var _lea = (variable_struct_exists(_config, "on_leave") && is_callable(_config.on_leave)) ? method(_dono, _config.on_leave) : undefined;

    _fsm.estados[$ _nome_estado] = {
        on_enter: _ent,
        on_step:  _stp,
        on_draw:  _drw,
        on_leave: _lea
    };
    return _fsm;
}

/// @function fsm_mudar_estado(_fsm, _novo_estado)
/// @description Transiciona a máquina para um novo estado com ganchos de saída e entrada.
function fsm_mudar_estado(_fsm, _novo_estado) {
    if (_fsm.estado_atual == _novo_estado) return;

    var _dados_atual = _fsm.estados[$ _fsm.estado_atual];
    if (_dados_atual != undefined && is_callable(_dados_atual.on_leave)) {
        with (_fsm.dono) _dados_atual.on_leave();
    }

    _fsm.estado_anterior = _fsm.estado_atual;
    _fsm.estado_atual = _novo_estado;
    _fsm.tempo_no_estado = 0;
    _fsm.mudou_de_estado_neste_frame = true;

    var _dados_novo = _fsm.estados[$ _novo_estado];
    if (_dados_novo != undefined && is_callable(_dados_novo.on_enter)) {
        with (_fsm.dono) _dados_novo.on_enter();
    }
}

/// @function fsm_executar_step(_fsm)
/// @description Executa a lógica de step do estado atual no escopo do dono e incrementa o contador.
function fsm_executar_step(_fsm) {
    _fsm.mudou_de_estado_neste_frame = false;
    var _dados = _fsm.estados[$ _fsm.estado_atual];
    if (_dados != undefined && is_callable(_dados.on_step)) {
        with (_fsm.dono) _dados.on_step();
    }
    _fsm.tempo_no_estado++;
}

/// @function fsm_executar_draw(_fsm)
/// @description Executa a rotina de desenho associada ao estado atual no escopo do dono.
function fsm_executar_draw(_fsm) {
    var _dados = _fsm.estados[$ _fsm.estado_atual];
    if (_dados != undefined && is_callable(_dados.on_draw)) {
        with (_fsm.dono) _dados.on_draw();
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
