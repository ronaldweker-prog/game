#!/usr/bin/env python3
"""Download Poly Haven CC0 photogrammetry albedo maps for the Android build.
The game works offline with a procedural fallback if any file is unavailable.
"""
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

ASSETS = ("sand_03", "grass_ground", "rock_ground")
FOLDER = Path("assets/materials")
FOLDER.mkdir(parents=True, exist_ok=True)

for asset in ASSETS:
    filename = f"{asset}_diff_1k.jpg"
    address = f"https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/{asset}/{filename}"
    target = FOLDER / filename
    try:
        request = Request(address, headers={"User-Agent": "RenascerNovoMundoGameBuild/0.3"})
        with urlopen(request, timeout=35) as response:
            content = response.read(7_000_000)
        if len(content) < 35_000 or not content.startswith(b"\xff\xd8\xff"):
            raise ValueError("unexpected image content")
        target.write_bytes(content)
        print(f"MATERIAL_FOTOGRAFICO_OK={asset},bytes={len(content)}", flush=True)
    except (HTTPError, URLError, TimeoutError, ValueError, OSError) as exc:
        target.unlink(missing_ok=True)
        print(f"MATERIAL_FOTOGRAFICO_FALLBACK={asset},motivo={type(exc).__name__}:{exc}", flush=True)
