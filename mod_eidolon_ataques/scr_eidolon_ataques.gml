/// @description Módulo Canônico de Ataques Especiais, Invocações e Habilidades de Eidolons
/// Compatível com GameMaker LTS 2026 / GML 2.3+

enum TIPO_ATAQUE_EIDOLON {
    SLAM_SISMICO,
    FENDA_GRAVITACIONAL,
    ONDA_HARMONICA,
    RETALHACAO_DUPLA,
    ERUPCAO_ESPINHOS
}

/// @function eidolon_executar_slam_colosso()
/// @description Impacto Sísmico: Esmagamento que gera fenda no solo e atordoamento em cone
function eidolon_executar_slam_colosso() {
    timer_vida--;
    squash_x = 1.35;
    squash_y = 0.85;

    if (!atingiu && timer_vida <= duracao_ataque * 0.6) {
        atingiu = true;
        var _alc = alcance_habilidade;
        var _dano_esp = dano;

        for (var i = 1; i <= 4; i++) {
            var _px = x + lengthdir_x((_alc * 0.25) * i, direcao_ataque);
            var _py = y + lengthdir_y((_alc * 0.25) * i, direcao_ataque);
            efeito_3d_spawn(_px, _py, 0.5, 0, 0, 0.4, cor_eidolon, 14, 10, EFEITO_3D.ONDA_CHOQUE);
            efeito_3d_spawn(_px, _py, 0.5, random_range(-0.5, 0.5), random_range(-0.5, 0.5), 0.6, c_dkgray, 8, 12, EFEITO_3D.POEIRA);
        }

        var _obj_alvo = variable_instance_exists(id, "obj_alvo_inimigos") ? obj_alvo_inimigos : -1;
        if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
            with (_obj_alvo) {
                var _dist = point_distance(other.x, other.y, x, y);
                if (_dist <= _alc) {
                    var _dir_alvo = point_direction(other.x, other.y, x, y);
                    if (abs(angle_difference(_dir_alvo, other.direcao_ataque)) <= 35) {
                        hp -= _dano_esp;
                        timer_atordoamento = 45;
                        squash_y = 0.6;
                        flash_timer = 6;
                    }
                }
            }
        }
        disparar_screenshake(8);
        aplicar_hitstop(4);
    }

    if (timer_vida <= 0) instance_destroy();
}

/// @function eidolon_executar_fenda_vortice()
/// @description Fenda Gravitacional: Puxa inimigos ao centro e explode com queimadura
function eidolon_executar_fenda_vortice() {
    timer_vida--;
    var _obj_alvo = variable_instance_exists(id, "obj_alvo_inimigos") ? obj_alvo_inimigos : -1;

    // Pulso e sucção periódica
    if (timer_vida mod 4 == 0) {
        var _ang_orb = random(360);
        var _dist_orb = random_range(20, 80);
        efeito_3d_spawn(x + lengthdir_x(_dist_orb, _ang_orb), y + lengthdir_y(_dist_orb, _ang_orb), z + 12, lengthdir_x(-3.0, _ang_orb), lengthdir_y(-3.0, _ang_orb), 0.4, cor_eidolon, 6, 12, EFEITO_3D.FAISCA);

        if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
            with (_obj_alvo) {
                var _dist = point_distance(x, y, other.x, other.y);
                if (_dist < 110 && _dist > 8) {
                    var _dir_pux = point_direction(x, y, other.x, other.y);
                    x += lengthdir_x(3.2, _dir_pux);
                    y += lengthdir_y(3.2, _dir_pux);
                    hp -= 3;
                    flash_timer = 2;
                }
            }
        }
    }

    // Colapso final com explosão abissal
    if (timer_vida <= 1 && !atingiu) {
        atingiu = true;
        efeito_3d_spawn(x, y, 0.6, 4.0, 0, 0, make_color_rgb(180, 50, 240), 28, 16, EFEITO_3D.ONDA_CHOQUE);
        if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
            with (_obj_alvo) {
                var _dist = point_distance(x, y, other.x, other.y);
                if (_dist < 90) {
                    hp -= other.dano;
                    flash_timer = 8;
                    timer_queimadura = 60;
                }
            }
        }
        disparar_screenshake(6);
        aplicar_hitstop(3);
    }

    if (timer_vida <= 0) instance_destroy();
}

/// @function eidolon_executar_onda_eco()
/// @description Onda Harmônica: Expansão sônica em leque que silencia e aplica marcação
function eidolon_executar_onda_eco() {
    timer_vida--;
    onda_raio += 4.2;

    if (timer_vida mod 3 == 0) {
        for (var _a = -35; _a <= 35; _a += 18) {
            var _dir_onda = direcao_ataque + _a;
            var _ox = x + lengthdir_x(onda_raio, _dir_onda);
            var _oy = y + lengthdir_y(onda_raio, _dir_onda);
            efeito_3d_spawn(_ox, _oy, z + 8, lengthdir_x(1.2, _dir_onda), lengthdir_y(1.2, _dir_onda), 0.5, cor_eidolon, 8, 10, EFEITO_3D.FAISCA);
        }
    }

    var _obj_alvo = variable_instance_exists(id, "obj_alvo_inimigos") ? obj_alvo_inimigos : -1;
    if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
        with (_obj_alvo) {
            var _dist = point_distance(other.x, other.y, x, y);
            if (abs(_dist - other.onda_raio) < 14) {
                var _dir_alvo = point_direction(other.x, other.y, x, y);
                if (abs(angle_difference(_dir_alvo, other.direcao_ataque)) <= 45) {
                    if (flash_timer <= 0) {
                        hp -= floor(other.dano * 0.5);
                        flash_timer = 5;
                        marcado_sentenca = true;
                    }
                }
            }
        }
    }

    if (timer_vida <= 0) instance_destroy();
}

/// @function eidolon_executar_retalhadora_algoz()
/// @description Retalhação Dupla: Lunge rápido com corte e bônus crítico pelas costas
function eidolon_executar_retalhadora_algoz() {
    timer_vida--;

    if (passo_lunge < 4) {
        passo_lunge++;
        var _vel_dash = 14;
        x += lengthdir_x(_vel_dash, direcao_ataque);
        y += lengthdir_y(_vel_dash, direcao_ataque);
        efeito_3d_spawn(x, y, z + 10, 0, 0, 0.4, make_color_rgb(180, 20, 30), 10, 10, EFEITO_3D.POEIRA);
    }

    if (!atingiu && passo_lunge >= 3) {
        atingiu = true;
        var _obj_alvo = variable_instance_exists(id, "obj_alvo_inimigos") ? obj_alvo_inimigos : -1;
        if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
            with (_obj_alvo) {
                var _dist = point_distance(other.x, other.y, x, y);
                if (_dist <= 52) {
                    var _olhar_ini = variable_instance_exists(id, "olhando_direita") ? (olhando_direita ? 0 : 180) : 0;
                    var _atingiu_costas = abs(angle_difference(other.direcao_ataque, _olhar_ini)) < 60;
                    var _dano_final = _atingiu_costas ? floor(other.dano * 2.0) : other.dano;

                    hp -= _dano_final;
                    flash_timer = 8;
                    disparar_screenshake(_atingiu_costas ? 8 : 4);
                    aplicar_hitstop(_atingiu_costas ? 6 : 3);
                }
            }
        }
    }

    if (timer_vida <= 0) instance_destroy();
}

/// @function eidolon_executar_erupcao_fera()
/// @description Erupção de Espinhos: Raízes ósseas e peçonha em leque frontal
function eidolon_executar_erupcao_fera() {
    timer_vida--;

    if (!atingiu && timer_vida <= duracao_ataque * 0.7) {
        atingiu = true;
        var _alc = alcance_habilidade;

        for (var _dist = 24; _dist <= _alc; _dist += 22) {
            for (var _a = -25; _a <= 25; _a += 25) {
                var _dir_esp = direcao_ataque + _a;
                var _ex = x + lengthdir_x(_dist, _dir_esp);
                var _ey = y + lengthdir_y(_dist, _dir_esp);
                efeito_3d_spawn(_ex, _ey, 0.5, 0, 0, 1.2, make_color_rgb(40, 220, 90), 12, 14, EFEITO_3D.FAISCA);
            }
        }

        var _obj_alvo = variable_instance_exists(id, "obj_alvo_inimigos") ? obj_alvo_inimigos : -1;
        if (_obj_alvo != -1 && instance_exists(_obj_alvo)) {
            with (_obj_alvo) {
                var _dist = point_distance(other.x, other.y, x, y);
                if (_dist <= _alc) {
                    var _dir_alvo = point_direction(other.x, other.y, x, y);
                    if (abs(angle_difference(_dir_alvo, other.direcao_ataque)) <= 35) {
                        hp -= other.dano;
                        flash_timer = 6;
                        timer_veneno = 75;
                    }
                }
            }
        }
        disparar_screenshake(4);
    }

    if (timer_vida <= 0) instance_destroy();
}

/// @function eidolon_despachar_ataque_especial()
/// @description Roteador declarativo dos 5 ataques únicos dos Eidolons
function eidolon_despachar_ataque_especial() {
    switch (tipo_ataque) {
        case TIPO_ATAQUE_EIDOLON.SLAM_SISMICO:
            eidolon_executar_slam_colosso();
            break;
        case TIPO_ATAQUE_EIDOLON.FENDA_GRAVITACIONAL:
            eidolon_executar_fenda_vortice();
            break;
        case TIPO_ATAQUE_EIDOLON.ONDA_HARMONICA:
            eidolon_executar_onda_eco();
            break;
        case TIPO_ATAQUE_EIDOLON.RETALHACAO_DUPLA:
            eidolon_executar_retalhadora_algoz();
            break;
        case TIPO_ATAQUE_EIDOLON.ERUPCAO_ESPINHOS:
            eidolon_executar_erupcao_fera();
            break;
        default:
            eidolon_executar_slam_colosso();
            break;
    }
}
