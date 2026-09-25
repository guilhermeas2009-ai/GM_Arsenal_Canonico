# 🛡️ GM_Arsenal_Canonico (GameMaker LTS 2026)

Acervo modular canônico de arquitetura, renderização 2.5D, máquinas de estado e combate para o ecossistema GameMaker LTS 2026.

Construído sob as diretrizes **Modo Ponytail (Engenharia Enxuta)**, **Clean Code** (funções menores que 50 linhas, structs nativas, sem dependências externas) e **Validação Determinística** (suíte de testes Python para validação contínua).

---

## 📦 Módulos Canônicos

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

### 4. `mod_room_loader_runtime` (Instanciador Dinâmico de Câmaras)
*   **Arquivo:** `scr_room_loader_runtime.gml`
*   **Objetivo:** Inspirado no `GMRoomLoader`, permite instanciar e trocar o layout de salas e prefabs em tempo de execução sem invocar `room_goto()`, preservando variáveis globais, buffers de áudio e shaders ativos.

### 5. `mod_camera_retro_3d` (Câmera 3D em Perspectiva Tática Elevada)
*   **Arquivo:** `scr_camera_retro_3d.gml`
*   **Objetivo:** Gerencia matrizes `matrix_build_lookat` e `matrix_build_projection_perspective_fov` com interpolação suave de foco e decaimento determinístico de Screenshake.

---

## 🧪 Validação Determinística

Para validar a integridade sintática e conformidade com Clean Code (< 50 linhas por função):

```bash
python3 testes/validar_arsenal_determinismo.py
```
