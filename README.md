# 🛡️ GM_Arsenal_Canonico (GameMaker LTS 2026)

Acervo modular canônico de arquitetura, renderização 2.5D, máquinas de estado, combate visceral e pipelines de assets para o ecossistema GameMaker LTS 2026.

Construído sob as diretrizes **Modo Ponytail (Engenharia Enxuta)**, **Clean Code** (funções menores que 50 linhas, structs nativas, sem dependências externas) e **Validação Determinística** (suíte de testes Python para validação contínua e sem mocks).

---

## 📦 Catálogo de Módulos Canônicos

### 1. `mod_fsm_estados` (Máquina de Estados Finita e Hierárquica)
*   **Arquivo:** `fsm_maquina_estados.gml`
*   **Objetivo:** Substitui completamente a proliferação de booleans para gerenciar estados de jogadores, chefes e invocações (Eidolons).
*   **Funções:** `fsm_criar`, `fsm_adicionar_estado`, `fsm_mudar_estado`, `fsm_executar_step`, `fsm_executar_draw`, `fsm_obter_tempo`.

### 2. `mod_billboard_3d` (Billboarding 3D via GPU Puro)
*   **Arquivos:** `shd_billboard_puro.vsh`, `shd_billboard_puro.fsh`, `scr_billboard_3d.gml`
*   **Objetivo:** Zera a rotação da matriz `MATRIX_WORLD_VIEW` diretamente no Vertex Shader da GPU, permitindo renderizar centenas de sprites 2D no espaço 3D com zero overhead de CPU.
*   **Modos:** Cilíndrico (preserva a verticalidade) e Esférico (alinhamento total com a câmera).

### 3. `mod_combate_souls` (Hitbox, Hurtbox, i-frames e Telegrafia)
*   **Arquivo:** `scr_combate_souls.gml`
*   **Objetivo:** Combate determinístico com cálculo vetorial de knockback, controle de quadros de invulnerabilidade (`iframes`), detecção de acerto cônico e janelas de telegrafia visual de golpes perigosos.

### 4. `mod_combate_feedback` (Hitstop, Screenshake, Partículas 3D e Sombras)
*   **Arquivo:** `scr_combate_feedback.gml`
*   **Objetivo:** Feedback visceral de impacto com congelamento físico de frames (`hitstop`), tremor de tela amortecido (`screenshake`), sistema de partículas 3D no espaço (faíscas, cinzas, decais de impacto) e sombras dinâmicas projetadas no solo deformadas por fontes de luz.
*   **Funções:** `aplicar_hitstop`, `disparar_screenshake`, `desenhar_sombra_projetada_3d`, `desenhar_sombra_projetada_silhueta_3d`, `sistema_efeitos_3d_spawn`, `sistema_efeitos_3d_atualizar`, `sistema_efeitos_3d_desenhar`.

### 5. `mod_hud_dinamico` (Orbes Místicos, Radar Tático e Cooldowns)
*   **Arquivo:** `scr_hud_dinamico.gml`
*   **Objetivo:** Interface de alta densidade informativa e estilo Dark Fantasy / ARPG clássico com orbe de vitalidade/recursos, painel de cooldowns de habilidades com atalhos de teclado e radar/minimapa tático vetorial.
*   **Funções:** `hud_desenhar_status_orbe`, `hud_desenhar_topo_direito`, `hud_desenhar_painel_habilidades`, `hud_desenhar_minimapa_tatico`.

### 6. `mod_eidolon_ataques` (Ataques Especiais, Invocações e Habilidades)
*   **Arquivo:** `scr_eidolon_ataques.gml`
*   **Objetivo:** Roteador e execução desacoplada dos 5 arquétipos de habilidades de invocações (Slam Sísmico com atordoamento, Fenda Gravitacional de atração, Onda Harmônica em leque, Retaliação Dupla com crítico pelas costas e Erupção de Espinhos com peçonha).

### 7. `mod_geometria_3d` (Malhas 3D Procedurais e Colisão de Arena)
*   **Arquivo:** `scr_geometria_3d.gml`
*   **Objetivo:** Criação procedural de malhas 3D em Vertex Buffers na GPU para pisos, fossos de lava e paredes verticais fechando a câmara, além de resolução matemática de colisão cilíndrica com pilares de sustentação.

### 8. `mod_room_loader_runtime` (Instanciador Dinâmico de Câmaras)
*   **Arquivo:** `scr_room_loader_runtime.gml`
*   **Objetivo:** Permite instanciar e alternar o layout de salas e prefabs em tempo de execução sem invocar `room_goto()`, preservando variáveis globais, buffers de áudio e shaders ativos.

### 9. `mod_camera_retro_3d` (Câmera 3D em Perspectiva Tática Elevada)
*   **Arquivo:** `scr_camera_retro_3d.gml`
*   **Objetivo:** Gerencia matrizes `matrix_build_lookat` e `matrix_build_projection_perspective_fov` com interpolação suave de foco e decaimento determinístico de Screenshake.

### 10. `mod_pipeline_forja_sprites` (Pipeline Python de Assets e Spritesheets)
*   **Arquivo:** `pipeline_forja_entidade.py`
*   **Objetivo:** CLI e pipeline automatizado em Python para conversão de concept arts em spritesheets compatíveis com a especificação VERSIONED GMSC LTS 2026.
*   **Capacidades:** Tiers anatômicos canônicos (comum 96x128, elite 112x140, chefe 160x192), isolamento adaptativo de silhueta, compensação de área óptica em poses estreitas e injeção de ancoragem rígida nos pés.

---

## 🧪 Validação Determinística

Para validar a integridade sintática, balanceamento e conformidade estrita com Clean Code (< 50 linhas por função):

```bash
python3 testes/validar_arsenal_determinismo.py
```
