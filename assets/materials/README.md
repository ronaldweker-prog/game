# Materiais naturais — licença e fontes

Os mapas de albedo são disponibilizados pela **Poly Haven** com licença **CC0 1.0** e são baixados automaticamente no momento da compilação, se houver rede.

| Uso | Asset | Origem |
|---|---|---|
| Areia | sand_03 | https://polyhaven.com/a/sand_03 |
| Vegetação do chão | grass_ground | https://polyhaven.com/a/grass_ground |
| Rochas | rock_ground | https://polyhaven.com/a/rock_ground |

Script: `scripts/tools/fetch_terrain.py`

Quando a rede ou arquivos externos não estão disponíveis, o jogo gera materiais por código em `scripts/SurfaceTextures.gd` para evitar dependência de Internet durante a execução. **Não é necessário conectar o celular à Internet para carregar os materiais já incluídos no APK.**

Texturas escaneadas são apenas uma parte da qualidade visual: modelos 3D, iluminação, animações e direção de arte ainda precisam de polimento.
