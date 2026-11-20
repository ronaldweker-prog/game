# RENASCER: NOVO MUNDO — Unity 6

Nova linha de desenvolvimento em Unity 6 + Universal Render Pipeline (URP). O projeto Godot permanece intacto na branch principal como backup e referencia funcional.

## Direcao de arte
- Jogo de sobrevivencia e exploracao 3D estilizado de alta qualidade, inspirado no equilibrio visual de Subnautica, com identidade original.
- Meta: graficos bonitos no preset Medio, sem depender de Ultra para parecer um jogo finalizado.
- Nao aceitar primitivas (cubos, capsulas) como arte final de personagens, casas, criaturas e vegetacao.
- Utilizar modelos 3D, materiais, animacoes e assets com licencas verificadas.

## Sistemas permanentes previstos
- Mundo com ilhas, oceano, biomas, cavernas e exploracao submarina; carregamento de regioes.
- Personagem customizavel, primeira/terceira pessoa, camera com colisao e animacoes.
- Sobrevivencia, inventario, coleta, crafting, salvamento, missoes e Essencias.
- Relogio NEXUS holografico, scanner, drone e construtor.
- Bases terrestres, submarinas, subterraneas e aereas; casa pousante hibrida.
- Veiculos terrestres, maritimos e aereos; criaturas e NPCs.

## Regra de entrega
Cada etapa exige (1) mudanca visivel em jogo, (2) mecanica jogavel, (3) evidencia de teste real, (4) registro de desempenho e (5) build identificavel. Compilar codigo sem testar visualmente nao equivale a concluir uma etapa.

## Primeiro marco
Cena costeira com terreno, agua, vegetacao, luz e materiais de qualidade; personagem humanoide com animacoes de locomocao; camera e controles PC/Android; exploracao, coleta e salvamento. Usar assets reais licenciados, nunca blocos como resultado final.

## Integracao e limitacoes
ChatGPT/Codex podem editar arquivos C# e configuracoes via GitHub. Para importar cenas e assets, verificar a aparencia, executar Unity e gerar builds e necessario um editor Unity 6 e um runner compativel, local ou na nuvem. Nao ha compilacao Unity gratuita validada neste repositorio ate o momento. Nao anunciar APK ou captura como real sem evidencia.

## Otimizacao
URP; LODs, occlusion culling, batching/instancing, atlas de texturas, streaming de regioes, perfis Android e PC. FPS so deve ser informado apos medicao em dispositivos reais.
