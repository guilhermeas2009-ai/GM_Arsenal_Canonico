#!/usr/bin/env python3
"""
🧙‍♂️ MERLIN / TÁVOLA REDONDA — PIPELINE DE FORJA DE ENTIDADES HD (PENITENTES)
Pipeline padronizado e reutilizável para criação de novos personagens e inimigos.
Converte concept arts em spritesheets anatômicos com metadados do GameMaker LTS 2026.
"""

import os, sys, math, json, uuid, argparse
from PIL import Image, ImageOps, ImageEnhance

# Dimensões e Proporções Canônicas por Tier de Entidade
TIERS_CANONICOS = {
    "comum": {
        "largura": 96,
        "altura": 128,
        "xorigin": 48,
        "yorigin": 124,
        "largura_3d": 32,
        "altura_3d": 48,
        "descricao": "Soldado comum / Fodder / Protagonista Base"
    },
    "elite": {
        "largura": 112,
        "altura": 140,
        "xorigin": 56,
        "yorigin": 136,
        "largura_3d": 48,
        "altura_3d": 56,
        "descricao": "Bruiser / Carrasco / Mini-Chefe"
    },
    "chefe": {
        "largura": 160,
        "altura": 192,
        "xorigin": 80,
        "yorigin": 186,
        "largura_3d": 64,
        "altura_3d": 80,
        "descricao": "Colosso / Eidolon / Chefe de Círculo"
    }
}

def isolar_silhueta_adaptativa(img, tolerancia=45):
    """
    Remove o fundo (seja escuro, neutro de estúdio ou chiaroscuro) isolando o personagem com alfa suave.
    Utiliza flood-fill das bordas comparando com as amostras dos 4 cantos e vizinhança.
    """
    img_rgba = img.convert("RGBA")
    w, h = img_rgba.size
    pixels = img_rgba.load()

    # Amostra dos 4 cantos da imagem
    cantos = [pixels[0, 0][:3], pixels[w - 1, 0][:3], pixels[0, h - 1][:3], pixels[w - 1, h - 1][:3]]

    # Máscara de pixels de fundo
    mascara = [[False for _ in range(w)] for _ in range(h)]
    fila = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    for x, y in fila:
        mascara[y][x] = True

    idx = 0
    while idx < len(fila):
        cx, cy = fila[idx]
        cr, cg, cb, ca = pixels[cx, cy]
        idx += 1
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not mascara[ny][nx]:
                r, g, b, a = pixels[nx, ny]
                brilho = r * 0.299 + g * 0.587 + b * 0.114
                dist_cantos = min(math.sqrt((r - cr0)**2 + (g - cg0)**2 + (b - cb0)**2) for cr0, cg0, cb0 in cantos)
                dist_pai = math.sqrt((r - cr)**2 + (g - cg)**2 + (b - cb)**2)
                # Critério adaptativo: próximo aos cantos OU continuidade com o pixel pai de fundo sob baixa luminância
                if dist_cantos < tolerancia or (dist_pai < 15 and brilho < 85):
                    mascara[ny][nx] = True
                    fila.append((nx, ny))

    # Aplica transparência suave nas bordas detectadas
    for y in range(h):
        for x in range(w):
            if mascara[y][x]:
                pixels[x, y] = (0, 0, 0, 0)

    # Recorta o bounding box real do conteúdo
    bbox = img_rgba.getbbox()
    if bbox:
        return img_rgba.crop(bbox)
    return img_rgba

def normalizar_em_grid(img_crop, target_w, target_h, margem_topo=0.08, margem_baixo=0.04):
    """
    Redimensiona a silhueta preservando a proporção de aspecto, ancorando os pés na base.
    """
    orig_w, orig_h = img_crop.size
    max_h_util = int(target_h * (1.0 - margem_topo - margem_baixo))
    max_w_util = int(target_w * 0.88)

    escala = min(max_w_util / orig_w, max_h_util / orig_h)
    novo_w = max(1, int(orig_w * escala))
    novo_h = max(1, int(orig_h * escala))

    img_redim = img_crop.resize((novo_w, novo_h), Image.Resampling.LANCZOS)

    # Cria canvas transparente final
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    pos_x = (target_w - novo_w) // 2
    pos_y = target_h - int(target_h * margem_baixo) - novo_h

    canvas.paste(img_redim, (pos_x, pos_y), img_redim)
    return canvas

def gerar_frames_animacao(canvas_base, num_frames=4):
    """
    Gera o ciclo de animação anatômica (Idle/Breathe, Walk L/R) preservando a identidade 100%.
    """
    w, h = canvas_base.size
    frames = [canvas_base]

    for f in range(1, num_frames):
        fase = f / num_frames
        if f == 1:
            # Frame 1: Respiração / Squash (contração vertical leve de 2%, expansão lateral de 1%)
            novo_h = int(h * 0.98)
            novo_w = int(w * 1.01)
            temp = canvas_base.resize((novo_w, novo_h), Image.Resampling.BILINEAR)
            frame_c = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            frame_c.paste(temp, ((w - novo_w) // 2, h - novo_h), temp)
            frames.append(frame_c)
        elif f == 2:
            # Frame 2: Marcha Esquerda (-2.0 graus de pêndulo + 2px elevação nos passos)
            temp = canvas_base.rotate(-2.0, resample=Image.Resampling.BICUBIC, expand=False, center=(w // 2, h - 10))
            frame_c = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            frame_c.paste(temp, (0, -2), temp)
            frames.append(frame_c)
        elif f == 3:
            # Frame 3: Marcha Direita (+2.0 graus de pêndulo + 2px elevação nos passos)
            temp = canvas_base.rotate(2.0, resample=Image.Resampling.BICUBIC, expand=False, center=(w // 2, h - 10))
            frame_c = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            frame_c.paste(temp, (0, -2), temp)
            frames.append(frame_c)

    return frames

def gravar_no_gamemaker(caminho_projeto, nome_sprite, frames, cfg_tier):
    """
    Salva os PNGs e o arquivo .yy do sprite dentro do projeto GameMaker LTS 2026.
    """
    dir_sprites = os.path.join(caminho_projeto, "sprites", nome_sprite)
    os.makedirs(dir_sprites, exist_ok=True)

    w = cfg_tier["largura"]
    h = cfg_tier["altura"]
    xorigin = cfg_tier["xorigin"]
    yorigin = cfg_tier["yorigin"]

    frames_meta = []
    keyframes_meta = []

    for i, f_img in enumerate(frames):
        f_nome = f"{nome_sprite}_{i:04d}"
        png_path = os.path.join(dir_sprites, f"{f_nome}.png")
        f_img.save(png_path, "PNG", optimize=True)

        frames_meta.append({
            "$GMSpriteFrame": "v1",
            "%Name": f_nome,
            "name": f_nome,
            "resourceType": "GMSpriteFrame",
            "resourceVersion": "2.0"
        })

        keyframes_meta.append({
            "$Keyframe<SpriteFrameKeyframe>": "",
            "Channels": {
                "0": {
                    "$SpriteFrameKeyframe": "",
                    "Id": {
                        "name": f_nome,
                        "path": f"sprites/{nome_sprite}/{nome_sprite}.yy"
                    },
                    "resourceType": "SpriteFrameKeyframe",
                    "resourceVersion": "2.0"
                }
            },
            "Disabled": False,
            "id": str(uuid.uuid4()),
            "IsCreationKey": False,
            "Key": float(i),
            "Length": 1.0,
            "resourceType": "Keyframe<SpriteFrameKeyframe>",
            "resourceVersion": "2.0",
            "Stretch": False
        })

    # Constrói metadados .yy oficial do GameMaker LTS 2026
    yy_data = {
        "$GMSprite": "v2",
        "%Name": nome_sprite,
        "bboxMode": 0,
        "bbox_bottom": h - 1,
        "bbox_left": 0,
        "bbox_right": w - 1,
        "bbox_top": 0,
        "collisionKind": 1,
        "collisionTolerance": 0,
        "DynamicTexturePage": False,
        "edgeFiltering": False,
        "For3D": False,
        "frames": frames_meta,
        "gridX": 0,
        "gridY": 0,
        "height": h,
        "HTile": False,
        "layers": [
            {
                "$GMImageLayer": "",
                "%Name": str(uuid.uuid4()),
                "blendMode": 0,
                "displayName": "default",
                "isLocked": False,
                "name": str(uuid.uuid4()),
                "opacity": 100.0,
                "resourceType": "GMImageLayer",
                "resourceVersion": "2.0",
                "visible": True
            }
        ],
        "name": nome_sprite,
        "nineSlice": None,
        "origin": 0,
        "parent": {
            "name": "Sprites",
            "path": "folders/Sprites.yy"
        },
        "preMultiplyAlpha": False,
        "resourceType": "GMSprite",
        "resourceVersion": "2.0",
        "sequence": {
            "$GMSequence": "v1",
            "%Name": nome_sprite,
            "autoRecord": True,
            "backdropHeight": 768,
            "backdropImageOpacity": 0.5,
            "backdropImagePath": "",
            "backdropWidth": 1366,
            "backdropXOffset": 0.0,
            "backdropYOffset": 0.0,
            "events": {
                "$KeyframeStore<MessageEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MessageEventKeyframe>",
                "resourceVersion": "2.0"
            },
            "eventStubScript": None,
            "eventToFunction": {},
            "length": float(len(frames)),
            "lockOrigin": False,
            "moments": {
                "$KeyframeStore<MomentsEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MomentsEventKeyframe>",
                "resourceVersion": "2.0"
            },
            "name": nome_sprite,
            "playback": 1,
            "playbackSpeed": 6.0,
            "playbackSpeedType": 0,
            "resourceType": "GMSequence",
            "resourceVersion": "2.0",
            "showBackdrop": True,
            "showBackdropImage": False,
            "timeUnits": 1,
            "tracks": [
                {
                    "$GMSpriteFramesTrack": "",
                    "builtinName": 0,
                    "events": [],
                    "inheritsTrackColour": True,
                    "interpolation": 1,
                    "isCreationTrack": False,
                    "keyframes": {
                        "$KeyframeStore<SpriteFrameKeyframe>": "",
                        "Keyframes": keyframes_meta,
                        "resourceType": "KeyframeStore<SpriteFrameKeyframe>",
                        "resourceVersion": "2.0"
                    },
                    "modifiers": [],
                    "name": "frames",
                    "resourceType": "GMSpriteFramesTrack",
                    "resourceVersion": "2.0",
                    "spriteId": None,
                    "trackColour": 0,
                    "tracks": [],
                    "traits": 0
                }
            ],
            "visibleRange": None,
            "volume": 1.0,
            "xorigin": xorigin,
            "yorigin": yorigin
        },
        "swatchColours": None,
        "swfPrecision": 2.525,
        "textureGroupId": {
            "name": "Default",
            "path": "texturegroups/Default"
        },
        "type": 0,
        "VTile": False,
        "width": w
    }

    yy_path = os.path.join(dir_sprites, f"{nome_sprite}.yy")
    with open(yy_path, "w", encoding="utf-8") as f:
        json.dump(yy_data, f, indent=2)

    # Registra no arquivo .yyp se ainda não estiver registrado
    yyp_path = os.path.join(caminho_projeto, "PenitenciaLTS.yyp")
    with open(yyp_path, "r", encoding="utf-8") as f:
        yyp_conteudo = f.read()

    ref_sprite = f'sprites/{nome_sprite}/{nome_sprite}.yy'
    if ref_sprite not in yyp_conteudo:
        bloco_novo = f'    {{"id":{{"name":"{nome_sprite}","path":"{ref_sprite}",}},}},'
        pos = yyp_conteudo.find('"resources":[')
        if pos != -1:
            pos_depois = yyp_conteudo.find('\n', pos) + 1
            novo_yyp = yyp_conteudo[:pos_depois] + bloco_novo + '\n' + yyp_conteudo[pos_depois:]
            with open(yyp_path, "w", encoding="utf-8") as f:
                f.write(novo_yyp)

    print(f"✅ Sprite '{nome_sprite}' ({w}x{h}px, {len(frames)} frames) gravado e registrado com sucesso no GameMaker!")

def main():
    parser = argparse.ArgumentParser(description="Pipeline de Forja de Entidades HD - Penitentes")
    parser.add_argument("--imagem", required=True, help="Caminho para a imagem de concept art mestra")
    parser.add_argument("--nome", required=True, help="Nome do sprite no GameMaker (ex: spr_inimigo_carrasco_hd)")
    parser.add_argument("--tier", choices=["comum", "elite", "chefe"], default="elite", help="Tier de escala da entidade")
    parser.add_argument("--tolerancia", type=int, default=45, help="Tolerância de cor euclidiana para isolamento de fundo")
    parser.add_argument("--frames", type=int, default=4, help="Número de frames de animação a gerar")
    parser.add_argument("--projeto", default="/mnt/c/GameMakerProjects/PenitenciaLTS", help="Caminho do projeto GameMaker")

    args = parser.parse_args()

    assert os.path.isfile(args.imagem), f"Arquivo de imagem não encontrado: {args.imagem}"
    cfg_tier = TIERS_CANONICOS[args.tier]

    print(f"🧙‍♂️ Processando entidade '{args.nome}' no Tier '{args.tier}' ({cfg_tier['largura']}x{cfg_tier['altura']}px)...")
    img_orig = Image.open(args.imagem)
    img_isolada = isolar_silhueta_adaptativa(img_orig, tolerancia=args.tolerancia)
    img_grid = normalizar_em_grid(img_isolada, cfg_tier["largura"], cfg_tier["altura"])
    frames = gerar_frames_animacao(img_grid, num_frames=args.frames)

    gravar_no_gamemaker(args.projeto, args.nome, frames, cfg_tier)

if __name__ == "__main__":
    main()
