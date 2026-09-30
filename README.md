# 🛡️ GM_Arsenal_Canonico (GameMaker LTS 2026)

> **Acervo Canônico de Ferramentas, Módulos GML e Skills para Produção de Jogos no GameMaker LTS 2026**

Este repositório consolida uma biblioteca modular e profissional para criação de jogos de qualquer gênero no GameMaker (plataforma, top-down, isométrico, combate estilo Souls, ação 2.5D, roguelites e arcades).

Construído sob as diretrizes **Modo Ponytail (Engenharia Enxuta)**, **Clean Code** (funções menores que 50 linhas, structs nativas, zero dependências externas) e **Validação Determinística** (suíte de testes Python para validação contínua e sem mocks).

---

## 📦 1. Módulos de Engenharia e Shaders (`mod_*`)

### 1. `mod_fsm_estados` (Máquina de Estados Finita e Hierárquica)
*   **Arquivo:** `fsm_maquina_estados.gml`
*   **Objetivo:** Substitui a proliferação de booleans pelo gerenciamento centralizado de estados para qualquer entidade (jogadores, inimigos, chefes, projéteis).
*   **Funções:** `fsm_criar`, `fsm_adicionar_estado`, `fsm_mudar_estado`, `fsm_executar_step`, `fsm_executar_draw`, `fsm_obter_tempo`.

### 2. `mod_billboard_3d` (Billboarding via GPU Puro)
*   **Arquivos:** `shd_billboard_puro.vsh`, `shd_billboard_puro.fsh`, `scr_billboard_3d.gml`
*   **Objetivo:** Zera a rotação da matriz de visualização diretamente no Vertex Shader da GPU, renderizando centenas de sprites 2D no espaço 3D com zero overhead de CPU.
*   **Modos:** Cilíndrico (preserva a verticalidade do mundo) e Esférico (alinhamento total com a câmera).

### 3. `mod_combate_souls` (Hitbox, Hurtbox, i-frames e Telegrafia)
*   **Arquivo:** `scr_combate_souls.gml`
*   **Objetivo:** Combate determinístico com cálculo vetorial de knockback, controle estrito de frames de invulnerabilidade (`iframes`), detecção de acerto em arco cônico e janelas de telegrafia visual de golpes.

### 4. `mod_combate_feedback` (Hitstop, Screenshake, Partículas 3D e Sombras)
*   **Arquivo:** `scr_combate_feedback.gml`
*   **Objetivo:** Feedback físico e visual visceral de impacto com congelamento temporário de quadros (`hitstop`), tremor de tela amortecido (`screenshake`), sistema de partículas 3D em Vertex Buffers e projeção de sombras no solo.
*   **Funções:** `aplicar_hitstop`, `disparar_screenshake`, `desenhar_sombra_projetada_3d`, `desenhar_sombra_projetada_silhueta_3d`, `sistema_efeitos_3d_spawn`, `sistema_efeitos_3d_atualizar`, `sistema_efeitos_3d_desenhar`.

### 5. `mod_habilidades_combate` (Ataques Especiais, Invocações e Habilidades em Área)
*   **Arquivo:** `scr_habilidades_combate.gml`
*   **Objetivo:** Roteador e execução de habilidades canônicas reutilizáveis: Slam Sísmico (atordoamento em cone), Fenda Vórtice (atração gravitacional ao centro), Onda de Choque (expansão semicircular), Lunge com Corte (avanço rápido com detecção de dano crítico pelas costas) e Erupção em Área (leque simultâneo de projéteis).

### 6. `mod_hud_dinamico` (Orbes Místicos, Radar Tático e Cooldowns)
*   **Arquivo:** `scr_hud_dinamico.gml`
*   **Objetivo:** Interface 2D de alta densidade informativa para qualquer jogo: orbe de vitalidade/recursos, painel de cooldowns de habilidades com atalhos de teclado e radar/minimapa tático vetorial.

### 7. `mod_geometria_3d` (Malhas 3D Procedurais e Colisão de Cenário)
*   **Arquivo:** `scr_geometria_3d.gml`
*   **Objetivo:** Construção procedural de malhas 3D em Vertex Buffers na GPU para pisos quadriculados, áreas perigosas e paredes verticais fechando a sala, com resolução matemática de colisão cilíndrica com pilares.

### 8. `mod_room_loader_runtime` (Instanciador Dinâmico de Câmaras)
*   **Arquivo:** `scr_room_loader_runtime.gml`
*   **Objetivo:** Permite instanciar e alternar o layout de salas e prefabs em tempo de execução sem invocar `room_goto()`, preservando variáveis globais, buffers de áudio e shaders ativos.

### 9. `mod_camera_retro_3d` (Câmera 3D em Perspectiva Tática Elevada)
*   **Arquivo:** `scr_camera_retro_3d.gml`
*   **Objetivo:** Gerencia matrizes `matrix_build_lookat` e `matrix_build_projection_perspective_fov` com interpolação suave de foco e decaimento determinístico de Screenshake.

---

## 🛠️ 2. Ferramentas e Pipelines CLI (`mod_pipeline_forja_sprites`)

*   **Arquivo:** `pipeline_forja_entidade.py`
*   **Objetivo:** CLI e pipeline em Python para transformar imagens brutas e concept arts em spritesheets anatômicos com metadados VERSIONED para GameMaker LTS 2026.
*   **Capacidades:**
    - Tiers anatômicos canônicos: *Comum* (96×128 ou 64×64), *Elite* (112×140 ou 96×96) e *Chefe* (160×192 ou 128×128).
    - Isolamento de silhueta adaptativo via alfa e segmentação por IA.
    - Ancoragem determinística nos pés (`xorigin` e `yorigin`).
    - Geração automática de arquivos `.yy` v2 com tracks de frames e UUIDs determinísticos.

---

## 🧠 3. Catálogo de Skills para Produção de Jogos (`skills/`)

Este repositório contém as skills completas para guiar agentes de IA e desenvolvedores na criação de jogos no GameMaker:

1. **[`skills/gamemaker-expert/`](skills/gamemaker-expert/SKILL.md)**:
   - Enciclopédia e referência técnica sobre GameMaker Studio 2 / LTS 2026, sintaxe GML 2.3+, padrões arquiteturais SOLID adaptados para GML, managers com construtores, shaders, networking e otimização.
2. **[`skills/sprite-forge/`](skills/sprite-forge/SKILL.md)**:
   - Forja e pipeline de sprites 2D e 2.5D para qualquer gênero de jogo. Governa as 3 Leis Inegociáveis da Forja: compensação de área óptica em poses dorsais (+18% a +28%), ancoragem rígida de solo nos pés sem duplo-offset e orientação canônica Facing Right.
3. **[`skills/pixel-art/`](skills/pixel-art/SKILL.md)**:
   - Conhecimento avançado de pixel art: paletas limitadas, técnicas de dithering, autotile, iluminação seletiva (selout), pillow shading prevention e pipelines HD-2D.
4. **[`skills/pixel-art-sprites/`](skills/pixel-art-sprites/SKILL.md)**:
   - Especialista em criação e animação frame-a-frame de personagens, criaturas, ciclos de corrida, ataque e idle.
5. **[`skills/pixel-art-generation/`](skills/pixel-art-generation/SKILL.md)**:
   - Workflows de geração de assets, tilesets, itens e cenários completos.
6. **[`skills/sprite-processing/`](skills/sprite-processing/SKILL.md)**:
   - Operações de processamento, recorte, divisão de spritesheets, transparência e otimização de atlas de textura.

---

## 🧪 4. Validação Determinística

Para validar a integridade de todos os 12 módulos de código e shaders, além das 6 skills do acervo:

```bash
python3 testes/validar_arsenal_determinismo.py
```
