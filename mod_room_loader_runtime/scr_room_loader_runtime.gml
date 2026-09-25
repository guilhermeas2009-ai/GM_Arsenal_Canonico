/// @description Carregador e Instanciador Dinâmico de Câmaras em Tempo Real
/// Inspirado na arquitetura do GMRoomLoader (Vencedor GM Awards 2025)
/// Permite trocar o layout e conteúdo da sala sem chamar room_goto().

/// @function camara_carregador_criar()
/// @description Cria uma estrutura controladora de carregamento de câmara em runtime.
function camara_carregador_criar() {
    return {
        instancias_geradas: [],
        pontos_spawn: [],
        tochas_registradas: [],
        em_transicao: false,
        layout_atual: "padrao"
    };
}

/// @function camara_carregador_limpar(_carregador)
/// @description Destrói cirurgicamente todas as instâncias e dados da câmara anterior.
function camara_carregador_limpar(_carregador) {
    var _total = array_length(_carregador.instancias_geradas);
    for (var i = 0; i < _total; i++) {
        var _inst = _carregador.instancias_geradas[i];
        if (instance_exists(_inst)) {
            instance_destroy(_inst);
        }
    }
    _carregador.instancias_geradas = [];
    _carregador.pontos_spawn = [];
    _carregador.tochas_registradas = [];
}

/// @function camara_carregador_instanciar_layout(_carregador, _dados_layout, _layer_nome)
/// @description Instancia elementos de um layout predefinido na sala ativa.
function camara_carregador_instanciar_layout(_carregador, _dados_layout, _layer_nome) {
    camara_carregador_limpar(_carregador);
    _carregador.layout_atual = _dados_layout.nome;

    // Registra posições de tochas para o pipeline de iluminação
    if (variable_struct_exists(_dados_layout, "tochas")) {
        var _total_t = array_length(_dados_layout.tochas);
        for (var t = 0; t < _total_t; t++) {
            array_push(_carregador.tochas_registradas, _dados_layout.tochas[t]);
        }
    }

    // Instancia entidades/obstáculos definidos pelo layout
    if (variable_struct_exists(_dados_layout, "entidades")) {
        var _total_e = array_length(_dados_layout.entidades);
        for (var e = 0; e < _total_e; e++) {
            var _item = _dados_layout.entidades[e];
            var _inst = instance_create_layer(_item.x, _item.y, _layer_nome, _item.objeto);
            if (variable_struct_exists(_item, "dados")) {
                var _chaves = variable_struct_get_names(_item.dados);
                for (var k = 0; k < array_length(_chaves); k++) {
                    _inst[$ _chaves[k]] = _item.dados[$ _chaves[k]];
                }
            }
            array_push(_carregador.instancias_geradas, _inst);
        }
    }

    // Registra spawners
    if (variable_struct_exists(_dados_layout, "spawns")) {
        _carregador.pontos_spawn = _dados_layout.spawns;
    }
}
