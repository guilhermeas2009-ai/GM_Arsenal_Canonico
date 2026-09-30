/// @description Módulo Canônico de HUD Dinâmico e Telemetria Visual 2D
/// Compatível com GameMaker LTS 2026 / GML 2.3+

/// @function hud_desenhar_status_orbe(_x, _y, _hp_pct, _recurso_pct, _val1_nome, _val1_qtd, _val2_nome, _val2_qtd)
/// @description Renderiza orbe gótico com barras de vida, recursos e contadores numéricos
function hud_desenhar_status_orbe(_x, _y, _hp_pct, _recurso_pct, _val1_nome, _val1_qtd, _val2_nome, _val2_qtd) {
    var _cor_ouro = make_color_rgb(212, 175, 55);
    var _cor_fundo = make_color_rgb(18, 18, 22);

    // Orbe Místico no Canto Superior Esquerdo
    var _orbe_cx = _x + 24;
    var _orbe_cy = _y + 24;
    draw_set_color(_cor_fundo);
    draw_circle(_orbe_cx, _orbe_cy, 22, false);

    var _cor_miolo = (_recurso_pct >= 1.0 && (current_time mod 200 < 100)) ? c_yellow : merge_color(make_color_rgb(160, 20, 30), make_color_rgb(255, 140, 20), _recurso_pct);
    draw_set_color(_cor_miolo);
    draw_circle(_orbe_cx, _orbe_cy, 18 * clamp(_recurso_pct, 0.2, 1.0), false);

    draw_set_color(_cor_ouro);
    draw_circle(_orbe_cx, _orbe_cy, 22, true);
    draw_circle(_orbe_cx, _orbe_cy, 20, true);

    // Barra de Vida
    var _bx = _x + 54;
    var _by = _y + 12;
    var _bw = 150;
    draw_set_color(_cor_fundo);
    draw_rectangle(_bx, _by, _bx + _bw, _by + 14, false);
    draw_set_color(make_color_rgb(190, 28, 38));
    draw_rectangle(_bx + 2, _by + 2, _bx + 2 + ((_bw - 4) * clamp(_hp_pct, 0.0, 1.0)), _by + 12, false);
    draw_set_color(_cor_ouro);
    draw_rectangle(_bx, _by, _bx + _bw, _by + 14, true);

    // Barra de Recurso Especial / Mana
    var _by_re = _y + 28;
    var _bw_re = 120;
    draw_set_color(_cor_fundo);
    draw_rectangle(_bx, _by_re, _bx + _bw_re, _by_re + 8, false);
    draw_set_color(make_color_rgb(60, 140, 240));
    draw_rectangle(_bx + 2, _by_re + 2, _bx + 2 + ((_bw_re - 4) * clamp(_recurso_pct, 0.0, 1.0)), _by_re + 6, false);
    draw_set_color(_cor_ouro);
    draw_rectangle(_bx, _by_re, _bx + _bw_re, _by_re + 8, true);

    // Indicadores Numéricos
    draw_set_color(make_color_rgb(160, 210, 255));
    draw_text(_bx, _y + 40, string(_val1_nome) + ": " + string(_val1_qtd));
    draw_set_color(_cor_ouro);
    draw_text(_bx, _y + 54, string(_val2_nome) + ": " + string(_val2_qtd));
}

/// @function hud_desenhar_topo_direito(_x, _y, _titulo, _subtitulo)
/// @description Exibe caixa de informações de câmara ou fase no topo direito da tela
function hud_desenhar_topo_direito(_x, _y, _titulo, _subtitulo) {
    var _cor_ouro = make_color_rgb(212, 175, 55);
    var _w = 120;
    var _h = 42;

    draw_set_color(make_color_rgb(18, 18, 22));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_color(_cor_ouro);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);

    draw_text(_x + 12, _y + 6, string(_titulo));
    draw_text(_x + 12, _y + 22, string(_subtitulo));
}

/// @function hud_desenhar_slot_habilidade(_cx, _y, _cw, _ch, _label, _spr_icone, _cd_segundos)
/// @description Desenha um único slot de habilidade com indicador de recarga
function hud_desenhar_slot_habilidade(_cx, _y, _cw, _ch, _label, _spr_icone, _cd_segundos) {
    var _cor_ouro = make_color_rgb(212, 175, 55);
    draw_set_color(make_color_rgb(15, 16, 20));
    draw_rectangle(_cx, _y, _cx + _cw, _y + _ch, false);
    if (_spr_icone != -1 && sprite_exists(_spr_icone)) {
        draw_sprite_stretched(_spr_icone, 0, _cx, _y, _cw, _ch);
    }
    draw_set_color(_cor_ouro);
    draw_rectangle(_cx, _y, _cx + _cw, _y + _ch, true);

    if (_cd_segundos > 0) {
        draw_set_color(c_black);
        draw_set_alpha(0.68);
        draw_rectangle(_cx, _y, _cx + _cw, _y + _ch, false);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(_cx + (_cw * 0.5), _y + 16, string(_cd_segundos) + "s");
        draw_set_halign(fa_left);
    }
    draw_set_color(c_ltgray);
    draw_set_halign(fa_center);
    draw_text(_cx + (_cw * 0.5), _y + _ch + 4, _label);
    draw_set_halign(fa_left);
}

/// @function hud_desenhar_painel_habilidades(_x, _y, _habilidades)
/// @description Renderiza conjunto de cards de habilidades com atalhos e cooldowns
function hud_desenhar_painel_habilidades(_x, _y, _habilidades) {
    var _cor_ouro = make_color_rgb(212, 175, 55);
    draw_set_color(_cor_ouro);
    draw_text(_x, _y - 18, "HABILIDADES");

    var _cw = 52;
    var _ch = 52;
    var _gap = 12;
    var _tot = array_length(_habilidades);

    for (var i = 0; i < _tot; i++) {
        var _h = _habilidades[i];
        var _cx = _x + (i * (_cw + _gap));
        hud_desenhar_slot_habilidade(_cx, _y, _cw, _ch, _h.nome, _h.icone, _h.cooldown_seg);
    }
}

/// @function hud_desenhar_minimapa_tatico(_x, _y, _larg, _alt, _tam_mundo_x, _tam_mundo_y, _entidades)
/// @description Renderiza radar / minimapa vetorial tático proporcional à arena
function hud_desenhar_minimapa_tatico(_x, _y, _larg, _alt, _tam_mundo_x, _tam_mundo_y, _entidades) {
    var _cor_ouro = make_color_rgb(212, 175, 55);
    draw_set_color(_cor_ouro);
    draw_text(_x, _y - 18, "RADAR TÁTICO");

    draw_set_color(make_color_rgb(14, 15, 18));
    draw_rectangle(_x, _y, _x + _larg, _y + _alt, false);
    draw_set_color(_cor_ouro);
    draw_rectangle(_x, _y, _x + _larg, _y + _alt, true);

    var _escala_x = _larg / max(1, _tam_mundo_x);
    var _escala_y = _alt / max(1, _tam_mundo_y);

    var _tot = array_length(_entidades);
    for (var i = 0; i < _tot; i++) {
        var _e = _entidades[i];
        draw_set_color(_e.cor);
        var _ex = _x + (_e.x * _escala_x);
        var _ey = _y + (_e.y * _escala_y);
        draw_circle(_ex, _ey, _e.raio, false);
    }
}
