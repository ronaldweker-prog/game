#!/usr/bin/env python3
"""Baixa dois modelos 3D reais de Poly Haven para os builds Android.
O jogo usa cenário procedural se os modelos estiverem indisponíveis.
"""
import json
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.parse import urlsplit
from urllib.error import URLError, HTTPError

ROOT = Path("assets/models")
ROOT.mkdir(parents=True, exist_ok=True)
MODELS = ("rock_09", "tree_stump_01")
HEADERS = {"User-Agent": "RenascerNovoMundoGameBuild/0.3"}

def read(url: str, cap: int = 35_000_000) -> bytes:
    with urlopen(Request(url, headers=HEADERS), timeout=45) as reply:
        data = reply.read(cap + 1)
    if len(data) > cap:
        raise ValueError("model exceeds size budget")
    return data

for model in MODELS:
    folder = ROOT / model
    try:
        manifest = json.loads(read(f"https://api.polyhaven.com/files/{model}", 3_000_000))
        asset = manifest["gltf"]["1k"]["gltf"]
        filename = Path(urlsplit(asset["url"]).path).name
        included = asset.get("include", {})
        if not isinstance(included, dict):
            raise ValueError("unrecognized dependency manifest")
        files = {filename: asset}
        for relative, entry in included.items():
            if not isinstance(entry, dict):
                continue
            if str(relative).startswith("/") or ".." in Path(str(relative)).parts:
                raise ValueError("unsafe model path")
            files[str(relative)] = entry
        staged = []
        for relative, entry in files.items():
            url = entry.get("url", "")
            if not url.startswith("https://dl.polyhaven.org/"):
                raise ValueError("unexpected source url")
            path = folder / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            data = read(url)
            if len(data) < 100:
                raise ValueError("empty dependency")
            path.write_bytes(data)
            staged.append(path)
        print(f"MODELO_3D_REAL_OK={model},arquivos={len(staged)},total_bytes={sum(x.stat().st_size for x in staged)}", flush=True)
    except (HTTPError, URLError, TimeoutError, KeyError, TypeError, ValueError, OSError, json.JSONDecodeError) as exc:
        if folder.exists():
            for f in sorted(folder.rglob("*"),reverse=True):
                if f.is_file(): f.unlink()
                elif f.is_dir():
                    try: f.rmdir()
                    except OSError: pass
        print(f"MODELO_3D_FALLBACK={model},motivo={type(exc).__name__}:{exc}", flush=True)
