# RENASCER: NOVO MUNDO — Unity 6

**Novo projeto Unity real, independente do antigo Godot.** O conteudo desta branch foi reconstruido do zero. A branch principal preserva o backup Godot.

## Abrir
1. Instale Unity Hub e Unity **6000.0.40f1** (ou versao 6000.0 compativel), com suporte Android se necessario.
2. Abra a pasta deste repositorio como projeto Unity. O bootstrap cria uma cena jogavel automaticamente em Play Mode, sem precisar de cena manual.
3. Em Unity: Play. WASD mover, mouse olhar, Shift correr, E coletar, Tab inventario, F criar kit de abrigo, F5 salvar, F9 carregar, Esc liberar mouse.

## Implementado neste marco (codigo-fonte)
- Estrutura Unity 6 URP e configuracao basica de projeto.
- Terreno insular continuo com malha procedural, praia e montanhas, oceano, luz solar e nevoa.
- Controlador de personagem em primeira pessoa, gravidade, corrida, salto, camera e colisao.
- Recursos coletaveis, inventario, crafting simples e persistencia local em JSON.
- HUD funcional de exploracao e diagnostico.

## Limites reais
**Ainda nao ha APK, build Unity verificada, modelos 3D profissionais, animacoes finais, casa pousante, nem prova de qualidade proxima as artes.** O cenario inicial e uma base tecnica jogavel, nao a qualidade visual aprovada. Nao ha editor Unity ou GPU de nuvem gratuita conectados e validados aqui. As artes conceituais nao sao capturas do jogo.

## Proximos criterios de qualidade
Integrar modelos reais com licencas verificadas (personagem humanoide animado, vegetacao, rochas, casa pousante), materiais de solo/agua, iluminacao e perfis graficos; validar visualmente no editor e medir FPS em Android/PC. Nao publicar como versao visual final antes disso.

## CI
Workflow valida a estrutura e os arquivos C# de maneira estatica. Compilacao Unity requer runner com editor e licenca adequados; a pipeline nao finge gerar APK.
