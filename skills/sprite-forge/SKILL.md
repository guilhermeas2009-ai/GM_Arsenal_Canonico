---
name: sprite-forge
description: Forja e pipeline de sprites 2D/2.5D para jogos no GameMaker LTS 2026. Governa padrões anatômicos por tiers, animação frame-a-frame, ancoragem sub-pixel nos pés, compensação de área óptica, orientação Facing Right e injeção de schemas GMSC LTS 2026. Use para qualquer projeto de jogo no GameMaker (plataforma, top-down, isométrico, ação 2.5D, roguelite, beat'em up).
---

# Forja de Sprites — GameMaker LTS 2026

## 📌 Identidade & Contexto
Esta skill governa o pipeline visual e a integração técnica de sprites e animações frame-a-frame para jogos no **GameMaker LTS 2026**:
- **Motor:** GameMaker LTS 2026 / GML 2.3+ moderno.
- **Formatos:** 2D puro, Top-Down, Plataforma, Isométrico e Ação 2.5D (billboard cilíndrico / esférico no espaço 3D).
- **Compatibilidade:** Serialização estrita de schemas VERSIONED (`$GMSpriteFrame`, tracks de animação e UUIDs determinísticos).

---

## 📐 Tiers Dimensionais e Canvas Canônico

| Tier | Canvas Padrão (px) | Origem Canônica (X, Y) | Dimensões 3D Típicas | Aplicação Típica |
| :--- | :--- | :--- | :--- | :--- |
| **Comum** | 96 × 128 (ou 64 × 64) | (centro_x, base_y) | 32 × 48 | Protagonista, soldados, NPCs, inimigos comuns |
| **Elite** | 112 × 140 (ou 96 × 96) | (centro_x, base_y) | 48 × 56 | Mini-chefes, bruisers, inimigos pesados |
| **Chefe / Colosso** | 160 × 192 (ou 128 × 128) | (centro_x, base_y) | 64 × 80 | Grandes chefes de fase, invocações, colossos |

---

## 🛡️ As 3 Leis Inegociáveis da Forja de Sprites

### 1. Lei da Área Óptica Percebida (Anti-Encolhimento)
* **Causa Raiz:** Em silhuetas dinâmicas, poses dorsais e invertidas têm largura linear até 50% menor, gerando perda de cerca de 47% na massa visual percebida quando mantidas na mesma altura linear.
* **Solução Canônica:** Desacoplar altura linear e aplicar **compensação de aspecto (+18% a +28% de altura nas poses estreitas e invertidas)** para preservar a equivalência de área percebida em tela.

### 2. Lei da Ancoragem de Solo Rígida e Orientação Nativa (Facing Right)
* **Causa Raiz:** Duplo-offset de física (sprite com pulo desenhado no canvas somado a `vel_z` na física do jogo) e orientação invertida de arte causam bugs de deslizamento no chão.
* **Solução Canônica:** Ancorar estritamente o solo na base (`yorigin` canônico) sem offset artificial. Toda arte base deve ser renderizada olhando para a **direita (Facing Right)** para casar 1:1 com `image_xscale = olhando_direita ? 1 : -1`.

### 3. Lei da Segmentação por IA e Recorte Adaptativo
* **Causa Raiz:** Algoritmos ingênuos de *flood fill* ou thresholding de brilho apagam armaduras, chapéus, cabelos e roupas escuras (brilho < 75).
* **Solução Canônica:** Utilizar segmentação por IA (`rembg` com modelo U2Net) e recorte conectado de fronteira estrita contra o fundo, preservando volumes e iluminação chiaroscuro.

---

## 🛠️ Pipeline Automatizado de Injeção no GameMaker LTS
Todo novo conjunto de frames deve ser processado e injetado via o pipeline modular:
- Local no Arsenal: `mod_pipeline_forja_sprites/pipeline_forja_entidade.py`

### Comandos Canônicos:
```bash
# Processar entidade do tier comum (96x128)
python3 mod_pipeline_forja_sprites/pipeline_forja_entidade.py \
  --imagem /caminho/concept.png \
  --nome spr_heroi_idle \
  --tier comum \
  --frames 4 \
  --projeto /caminho/meu_jogo

# Processar chefe ou monstro grande (160x192)
python3 mod_pipeline_forja_sprites/pipeline_forja_entidade.py \
  --imagem /caminho/chefe.png \
  --nome spr_chefe_combate \
  --tier chefe \
  --frames 6 \
  --projeto /caminho/meu_jogo
```

### O que o pipeline garante:
1. **Recorte e Transparência:** Remoção limpa de fundo preservando tons escuros e bordas.
2. **Ancoragem Sub-Pixel:** Cálculo determinístico de `bottom_y` e `foot_center_x`.
3. **Geração de Metadados `.yy` v2:** Recursos `$GMSpriteFrame`, tracks indexadas e UUIDs determinísticos compatíveis com o `Igor.exe` e GameMaker LTS 2026.
