#!/usr/bin/env python3
"""
Validador Determinístico de Integridade Sintática e Arquitetural do GM_Arsenal_Canonico
Garante conformidade estrita com Modo Ponytail, Clean Code (<50 linhas por função),
balanceamento sintático e integridade do catálogo de módulos e skills para GameMaker LTS 2026.
"""

import ast
import os
import re
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def checar_balanceamento(texto, caminho_arquivo):
    pares = { '{': '}', '(': ')', '[': ']' }
    pilha = []
    
    # Remove strings e comentários de linha simples
    texto_limpo = re.sub(r'//.*', '', texto)
    texto_limpo = re.sub(r'/\*.*?\*/', '', texto_limpo, flags=re.DOTALL)
    texto_limpo = re.sub(r'"(\\.|[^"\\])*"', '""', texto_limpo)

    for i, char in enumerate(texto_limpo):
        if char in pares.keys():
            pilha.append((char, i))
        elif char in pares.values():
            if not pilha:
                return False, f"Fechamento '{char}' sem abertura correspondente em {caminho_arquivo}"
            abertura, _ = pilha.pop()
            if pares[abertura] != char:
                return False, f"Incompatibilidade '{abertura}' fechado com '{char}' em {caminho_arquivo}"
    
    if pilha:
        abertura, _ = pilha[-1]
        return False, f"Abertura '{abertura}' não foi fechada em {caminho_arquivo}"
    return True, "Balanceamento perfeito"

def validar_funcoes_clean_code(caminho_gml):
    with open(caminho_gml, "r", encoding="utf-8") as f:
        linhas = f.readlines()
    
    erros = []
    em_funcao = False
    nome_funcao = ""
    linhas_funcao = 0
    nivel_chaves = 0

    for idx, linha in enumerate(linhas, 1):
        match_func = re.search(r'function\s+([a-zA-Z0-9_]+)\s*\(', linha)
        if match_func and not em_funcao:
            em_funcao = True
            nome_funcao = match_func.group(1)
            linhas_funcao = 0
            nivel_chaves = 0

        if em_funcao:
            linhas_funcao += 1
            nivel_chaves += linha.count('{') - linha.count('}')
            if nivel_chaves <= 0 and '{' in ''.join(linhas[idx-linhas_funcao:idx]):
                if linhas_funcao > 50:
                    erros.append(f"Função '{nome_funcao}' excede 50 linhas ({linhas_funcao} linhas) no arquivo {os.path.basename(caminho_gml)}")
                em_funcao = False
                nome_funcao = ""
                linhas_funcao = 0

    return erros

def validar_script_python(caminho_py):
    with open(caminho_py, "r", encoding="utf-8") as f:
        conteudo = f.read()
    try:
        ast.parse(conteudo)
        return True, "Sintaxe Python válida (AST)"
    except Exception as e:
        return False, f"Erro de sintaxe Python em {caminho_py}: {e}"

def validar_skill_markdown(caminho_md):
    with open(caminho_md, "r", encoding="utf-8") as f:
        conteudo = f.read()
    if not conteudo.startswith("---"):
        return False, f"Skill sem frontmatter YAML: {caminho_md}"
    if "name:" not in conteudo or "description:" not in conteudo:
        return False, f"Skill sem campos obrigatórios (name, description): {caminho_md}"
    return True, "Skill válida"

def executar_validacao():
    print("=" * 65)
    print("🛡️ VALIDADOR CANÔNICO: GM_ARSENAL_CANONICO (LTS 2026)")
    print("=" * 65)

    modulos_esperados = [
        "mod_fsm_estados/fsm_maquina_estados.gml",
        "mod_billboard_3d/shd_billboard_puro.vsh",
        "mod_billboard_3d/shd_billboard_puro.fsh",
        "mod_billboard_3d/scr_billboard_3d.gml",
        "mod_combate_souls/scr_combate_souls.gml",
        "mod_room_loader_runtime/scr_room_loader_runtime.gml",
        "mod_camera_retro_3d/scr_camera_retro_3d.gml",
        "mod_combate_feedback/scr_combate_feedback.gml",
        "mod_hud_dinamico/scr_hud_dinamico.gml",
        "mod_habilidades_combate/scr_habilidades_combate.gml",
        "mod_geometria_3d/scr_geometria_3d.gml",
        "mod_pipeline_forja_sprites/pipeline_forja_entidade.py"
    ]

    skills_esperadas = [
        "skills/gamemaker-expert/SKILL.md",
        "skills/sprite-forge/SKILL.md",
        "skills/pixel-art/SKILL.md",
        "skills/pixel-art-sprites/SKILL.md",
        "skills/pixel-art-generation/SKILL.md",
        "skills/sprite-processing/SKILL.md"
    ]

    total_itens = 0
    todos_erros = []

    print("📦 MÓDULOS DE ENGENHARIA & SHADERS:")
    for rel_path in modulos_esperados:
        full_path = os.path.join(BASE_DIR, rel_path)
        if not os.path.exists(full_path):
            todos_erros.append(f"Arquivo obrigatório não encontrado: {rel_path}")
            continue

        total_itens += 1
        with open(full_path, "r", encoding="utf-8") as f:
            conteudo = f.read()

        if rel_path.endswith(".py"):
            ok, msg = validar_script_python(full_path)
            if not ok:
                todos_erros.append(msg)
            else:
                print(f"[OK] Validação AST Python: {rel_path}")
            continue

        ok, msg = checar_balanceamento(conteudo, rel_path)
        if not ok:
            todos_erros.append(msg)
        else:
            print(f"[OK] Balanceamento sintático: {rel_path}")

        if rel_path.endswith(".gml"):
            erros_cc = validar_funcoes_clean_code(full_path)
            if erros_cc:
                todos_erros.extend(erros_cc)
            else:
                print(f"[OK] Clean Code (<50 linhas/func): {rel_path}")

    print("\n🧠 SKILLS DE PRODUÇÃO DE JOGOS:")
    for rel_path in skills_esperadas:
        full_path = os.path.join(BASE_DIR, rel_path)
        if not os.path.exists(full_path):
            todos_erros.append(f"Skill obrigatória não encontrada: {rel_path}")
            continue

        total_itens += 1
        ok, msg = validar_skill_markdown(full_path)
        if not ok:
            todos_erros.append(msg)
        else:
            print(f"[OK] Skill YAML & Integridade: {rel_path}")

    print("-" * 65)
    if todos_erros:
        print(f"❌ FALHA: {len(todos_erros)} erro(s) encontrados:")
        for err in todos_erros:
            print(f"  • {err}")
        sys.exit(1)
    else:
        print(f"🏆 SUCESSO: Todos os {total_itens} módulos e skills canônicas foram validados!")
        print("=" * 65)
        sys.exit(0)

if __name__ == "__main__":
    executar_validacao()
