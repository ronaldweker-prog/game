# O RECOMEÇO — ALTERAR O JOGO CONVERSANDO NO CHATGPT

## Sistema conectado (sem instalar Unreal ou PlayDrop)
O repositório `ronaldweker-prog/game` está conectado ao ChatGPT pelo GitHub.
O criador pode descrever **uma mudança concreta em uma conversa**, como:

- "No O RECOMEÇO, aumente a quantidade de árvores para 120 e preserve os 30 FPS no POCO M7 Pro 5G."
- "Aumente a velocidade da jangada de 4 para 5 e atualize os testes."
- "Diminua o custo da primeira jangada para 5 madeiras e 3 fibras."
- "Adicione um novo módulo de agricultura ao jogo, com menus e salvamento."
- "Confira por que o APK falhou e corrija o erro do GitHub Actions."

## Como o processo funciona
1. O usuário **solicita explicitamente** a alteração no ChatGPT, preferencialmente nesta conversa ou citando o repositório.
2. O assistente analisa o pedido junto com `docs/CANONE_E_LACUNAS.md` e os documentos históricos.
3. O assistente altera `config/gameplay.json` para parâmetros simples, ou escreve novos scripts/recursos para funcionalidades reais.
4. Os arquivos são enviados ao GitHub conectado, com registro do commit.
5. O GitHub Actions executa importação, testes automatizados e tentativa de exportação para ARM64.
6. Após execução bem-sucedida, o GitHub publica um **APK experimental** em Releases. É preciso baixar e instalar a nova versão no celular.
7. O assistente informa **o que mudou, quais testes passaram e quais ainda faltam**.

## O que é editável sem alterar código
O arquivo `config/gameplay.json` contém configurações por nome:
- `balance.player_walk_speed`: velocidade ao andar
- `balance.raft_speed`: velocidade da jangada
- `balance.hydration_loss_per_second` e `hunger_loss_per_second`: sobrevivência
- `world.tree_count`, `world.pickup_count`: vegetação e recursos
- `world.day_cycle_speed`: velocidade do ciclo ambiental
- `visuals.mobile_fps`, `balanced_fps`, `quality_scales`: desempenho
- `visuals.mouse_sensitivity`, `touch_sensitivity`: câmera
- `recipes.tool`, `shelter`, `raft`, `chest`: custos iniciais

Atualizar este arquivo e compilar novamente é **configuração do jogo**, não um sistema de IA dentro do aplicativo.

## Sistemas grandes exigem programação
Bases móveis, submarinos, cidades aéreas, ecossistemas persistentes, NPCs, indústria, histórias e multiplayer precisam de código, modelos, arte, animações, armazenamento em servidor e testes próprios. **Não surgem apenas ao mudar uma linha de configuração.**

## Limitações importantes
- Conversar com o ChatGPT **não modifica automaticamente** uma cópia já instalada no celular. É necessária uma nova compilação e atualização/instalação do APK.
- O assistente trabalha **quando recebe um pedido e usa as ferramentas conectadas**, não fica executando trabalho indefinidamente em segundo plano.
- Alterações que não compilarem não geram APK de teste.
- O APK `Android Debug` é experimental. A assinatura de debug pode mudar entre ambientes; caso mude, atualizações sobre a versão antiga poderão exigir reinstalação, com possível perda de dados. Uma assinatura de lançamento estável exigirá chave segura fora do repositório.
- O repositório é **público**: não inclua senhas, credenciais, documentos pessoais nem arquivos de assinatura.
- **Não trocar** conceitos confirmados por propostas sem aprovação explícita do criador.

## Links
- Código: https://github.com/ronaldweker-prog/game
- Compilações e testes: https://github.com/ronaldweker-prog/game/actions
- APKs experimentais: https://github.com/ronaldweker-prog/game/releases
- Planejamento completo: `docs/PROMPT_MESTRE_COMPLETO.txt`
- Estado real: `docs/STATUS_E_TESTES.md`
