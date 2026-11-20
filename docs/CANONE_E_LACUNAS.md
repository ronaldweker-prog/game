# O RECOMEÇO — CÂNONE, HISTÓRICO E LACUNAS

> Referência de desenvolvimento. Este documento não afirma que uma funcionalidade está implementada. Para implementação/validação, consultar `docs/STATUS_E_TESTES.md`.

## Fontes preservadas
- `docs/PROMPT_MESTRE_COMPLETO.txt` — documento mestre unificado.
- `docs/historico/PROMPT_MESTRE_ANTIGO.txt` — prompt antigo, com a organização original.
- `docs/historico/COMPLEMENTO_HISTORIA_CRIATURAS_ECONOMIA.txt` — complemento mais antigo sobre história, criaturas, economia e resgates.
- Imagens compartilhadas de painel PAC, base subterrânea, veículo de exploração 6x6, cidades subaquáticas, base submarina, cidade aérea e plataforma aérea: referências visuais da conversa, ainda não importadas como modelos 3D.
- Conversas anteriores com o criador: manter o que está explicitamente registrado; nunca inventar decisões ausentes.

## CONFIRMADO — visão do jogo
- **Nome:** O RECOMEÇO. Lema: sobreviva, explore, construa, evolua.
- **Gênero:** sobrevivência, exploração, construção, simulação, estratégia, mistério e ficção científica em mundo persistente.
- **Quatro ambientes completos e interligados:** terra, oceano, céu e subterrâneo. Cada um com vida, NPCs/ecossistemas, economia, pesquisa, agricultura, produção, bases e progressão.
- **Começar pequeno e crescer:** ilha, coleta, abrigo, construção modular de jangada, barco/navio/iate, bases móveis, cidades e civilizações.
- **Ações funcionais, não decorativas:** construções, máquinas, portas, equipamentos, veículos, mecânicas de pouso/acoplamento, computação, comércio e cooperação.
- **Câmeras e acessibilidade:** primeira pessoa jogável com mãos/equipamentos, terceira pessoa jogável com ajustes de ângulo/altura/distância, câmera de observação e câmeras coerentes de veículos/aeronaves/embarcações/bases; controles personalizáveis, interface Android por toque e PC por teclado/mouse.
- **Android prioritário**, visando POCO M7 Pro 5G com 12 GB de RAM: visual bonito **com otimização**. PC também previsto. A meta de 30 FPS precisa de testes reais, não é desempenho medido. Não depender de PlayDrop nem Unreal.

## CONFIRMADO — história e progressão
- Mundo após o colapso de uma civilização tecnologicamente avançada, com ruínas emergentes, laboratórios antigos, descobertas, registros e eventos persistentes.
- Na história estabelecida, uma **bomba de nitrogênio** caiu e libertou chefes que estavam congelados no Ártico; são criaturas especiais relacionadas à catástrofe, não simplesmente zumbis. Preservar a premissa ficcional sem criar uma explicação definitiva por conta própria.
- **Essências** permanecem parte da progressão; não trocar por várias classes genéricas.
- **Classe VISÃO** e suas **cinco evoluções permanentes** precisam ser preservadas.
- **Clarividência:** esquiva automática de certos ataques, chance limitada e crescente com experiência; requer recarga, não é invencibilidade e pode ser superada por ataques especiais.
- Criaturas específicas e chefes antigos devem ser preservados quando seus detalhes forem recuperados.

## CONFIRMADO — economia, comunicação e sociedade
- **Economia principal:** produção, recursos, serviços, contratos, comércio e transporte.
- **Segunda moeda:** separada da economia do mundo, obtida **somente durante partidas**, utilizável em **pontos específicos de compra**. Não inventar conversão entre moedas.
- NPCs com necessidades, horários, trabalho, resgates e comunidades que evoluem autonomamente. Civilizações marítimas, pessoas que moram em embarcações, portos, comércio, grupos de piratas e transportadoras.
- Missões/resgates de jogadores e NPCs, entregas de suprimentos, solicitação de ajuda e preparação de expedições.
- Relógio multifuncional: comunicação por texto, chamadas privadas/grupo, voz por proximidade opcional, alertas, navegação, economia, controle de veículos/bases, pesquisa, permissões, rede e inventário.
- Rede Global construída pelos jogadores, com servidores/antenas/energia/alcance real no universo; segurança digital **fictícia**, sem técnicas reais.
- Multiplayer cooperativo, compartilhamento de veículos com papéis proprietário/segundo administrador/piloto, permissões em bases, sincronização de mundo e persistência em servidores.
- Indústria, máquinas, energia, hidropônicos/agricultura nos quatro meios, drones, clima/desastres, IA de bases/PAC e piloto automático com limites físicos.

## PROPOSTAS — NÃO CONFUNDIR COM CÂNONE DEFINITIVO
- **Projeto NÉVOA ZERO:** proposta histórica anterior, não confirmado como explicação definitiva da catástrofe.
- Identidades sugeridas de chefes: **Brutamontes** (Ártico), **Abissal** (ruínas submersas), **Caçador** (floresta inundada), **Guardião** (complexo científico), **Rei da Infecção** (mistério da infecção) e **Observador** (ligação possível com VISÃO).
- Suas aparências, origens, habilidades e função na narrativa devem permanecer propostas até confirmação do criador.

## PENDENTE — RECUPERAR O QUE NÃO ESTÁ DOCUMENTADO
- Nomes, aparência e mecânicas exatas de TODOS os chefes e monstros previamente aprovados que não estejam descritos por completo nas fontes.
- Nomes/efeitos oficiais das cinco evoluções permanentes da classe VISÃO.
- Cronologia definitiva, personagens históricos e explicação do evento do Ártico.
- Origem definitiva da infecção e do sistema de Essências.
- Regras de PvP, servidores, monetização, balançamento e escolhas narrativas ainda não registradas.
- Modelos 3D e direitos de uso de cada arte/áudio antes de distribuição do jogo.

## Regras de preservação
1. Quando confirmado, não substituir por proposta ou conteúdo genérico.
2. Quando proposto, rotular como proposta.
3. Quando não documentado, manter PENDENTE — não inventar nem afirmar concluído.
4. O código implementado deve ser executável, testado e sincronizado ao acompanhamento.
5. Nenhuma imagem conceitual deve ser apresentada como captura do jogo funcionando.
6. Nenhuma exportação deve ser declarada APK antes de compilar, assinar e validar arquivo instalável.
