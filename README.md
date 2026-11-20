# O RECOMEÇO 🎮

Protótipo experimental de sobrevivência 3D em Godot 4.4, preparado para Android (POCO M7 Pro 5G, 12 GB RAM).

## Baixar a primeira versao Android
- [Ver APKs experimentais em Releases](https://github.com/ronaldweker-prog/game/releases)
- A compilacao e os testes automaticos rodam em [Actions](https://github.com/ronaldweker-prog/game/actions).
- Abra a versao de teste mais recente que constar como **sucesso**. Baixe `O_RECOMECO.apk`.
- O APK é um **protótipo de teste**, não o jogo final e não foi validado fisicamente no POCO M7 Pro 5G.

## Documentação, histórico e tarefas
- [Cânone e lacunas](docs/CANONE_E_LACUNAS.md): decisões confirmadas, propostas e informações antigas ainda faltantes.
- [Mudar o jogo por conversa no ChatGPT](docs/ALTERAR_PELO_CHATGPT.md): como solicitar alterações e receber APKs atualizados.
- [Configurações editáveis](config/gameplay.json): desempenho, receitas, mundo, sobrevivência e controles.
- [Estado e testes](docs/STATUS_E_TESTES.md): critérios para considerar uma função realmente concluída.
- [Referências visuais](docs/REFERENCIAS_VISUAIS.md): bases submarinas, aéreas, cavernas, painel PAC e veículo 6x6.
- [Prompt mestre unificado](docs/PROMPT_MESTRE_COMPLETO.txt).
- [Prompt mestre antigo](docs/historico/PROMPT_MESTRE_ANTIGO.txt).
- [Complemento antigo](docs/historico/COMPLEMENTO_HISTORIA_CRIATURAS_ECONOMIA.txt).
- [Tarefas técnicas abertas](https://github.com/ronaldweker-prog/game/issues): 6 frentes de desenvolvimento para não perder mecânicas.

## Estado atual
- Código-fonte do protótipo inicial: ilha 3D, ambiente, exploração, coleta, inventário inicial, ferramenta, abrigo, jangada, **baú com armazenamento real**, **joystick virtual para celular**, **fauna pacífica com estados**, roupas básicas configuráveis, câmeras e salvamento.
- O GitHub já compilou e publicou APKs experimentais com sucesso. Testes de integração automatizados foram adicionados e passaram nas execuções verificadas.
- Documento completo do projeto: `docs/PROMPT_MESTRE_COMPLETO.txt`.
- **Compilação de APK e testes automatizados: confirmados em CI. Teste em dispositivo físico: ainda não realizado.**
- As imagens conceituais hiper-realistas ainda não são a aparência real do protótipo.
- Bases aéreas, submarinas e subterrâneas, veículos avançados, NPCs, grandes cidades e multiplayer continuam planejados, sem implementação funcional.

## Otimização
Renderizador OpenGL Compatibility, iluminação sem sombras dinâmicas, formas 3D simples, qualidade ajustável e limite inicial de 30 FPS no modo econômico. O desempenho real depende de testes no aparelho.

## Privacidade
**Atenção: este repositório está público.** Qualquer pessoa pode acessar os arquivos, copiar o código e o documento de ideias. Não adicione senhas, dados pessoais ou credenciais.

## Créditos
Projeto original **O RECOMEÇO**. Desenvolvimento experimental com assistência de IA.
