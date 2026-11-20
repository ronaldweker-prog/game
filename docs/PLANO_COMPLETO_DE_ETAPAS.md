# O RECOMEÇO — Plano de produção completo

> **Regra central:** todas as funcionalidades aprovadas permanecem no escopo. A existência de um requisito neste plano NÃO significa que foi implementado, testado ou publicado.
> Fontes prioritárias: `docs/PROMPT_MESTRE_COMPLETO.txt`, `docs/CANONE_E_LACUNAS.md`, documentos antigos preservados em `docs/historico`.

## Critérios de qualidade para cada entrega
1. Entregar código integrado, sem botões que apenas fingem executar uma mecânica.
2. Compilar para Android ARM64, rodar testes headless e publicar somente builds que passem.
3. Verificar controles por toque, teclado/mouse, câmera, salvamento e regressões de recursos existentes.
4. Testar visual, áudio, FPS, RAM, consumo de bateria e travamentos no POCO M7 Pro 5G quando disponível.
5. Não classificar "fotorrealista", "sem bugs" ou "testado no aparelho" sem evidência verificável.

## Trilha de desenvolvimento completa

| Ordem | Entrega | Principais sistemas preservados | Estado em 20/11/2026 |
|---|---|---|---|
| 0 | Projeto e APK | Godot 4.4, arquitetura, GitHub Actions, testes, APK baixável, configuração pelo ChatGPT | **Compila e tem APK experimental.** Teste físico pendente |
| 1 | Ilha com visual melhor | Terreno 3D, água, céu, vegetação, rochas, ruínas, iluminação, UI moderna, personagem, primeira/terceira pessoa | **Em desenvolvimento**: nova base visual procedural, sem fotorrealismo; comparar no celular |
| 2 | Sobrevivência profunda | Coleta, ferramentas, agricultura, caça/coleta fictícia, alimentação, água, estado físico, peso, estações de fabricação, mochila e baús reais | **Parcial**: coleta, necessidades, ferramenta, baú e salvamento |
| 3 | Construção peça por peça | Abrigos, paredes, pisos, portas, janelas, móveis, elétrica, tubulações, energia, integridade, dimensionamento e construção livre/modular | **Parcial**: abrigo básico |
| 4 | Oceano e embarcações | Nadador, oxigênio, correntes, fauna subaquática, jangada modular, barcos, navios, iates, navegação, portos, transporte, resgate | **Parcial**: jangada simples navegável e baú |
| 5 | Tecnologia e veículos | Veículo explorador 6x6, terrestres, aquáticos, aéreos e submarinos, combustível, manutenção, transporte, painéis, drone, câmeras especiais | Pendente |
| 6 | Bases e cidades | Bases terrestres, subterrâneas, submarinas, aéreas, móveis e híbridas. Quartos, oficinas, laboratórios, elevadores, rampas, acoplamento, hangares, geradores, suporte à vida e PAC funcional | Pendente |
| 7 | Quatro mundos interligados | Terra, oceano, céu e subterrâneo: biomas habitáveis, ecologia, recursos, agricultura, produção, pesquisa, transporte e sociedade próprios | Pendente |
| 8 | Ecossistemas e criaturas | Criaturas variadas, presas e predadores, migração, clima, reprodução, chefes únicos, ecossistema ativo e simulado à distância | **Parcial**: fauna terrestre pacífica simples |
| 9 | NPCs e civilização | Famílias/comunidades, rotinas, empregos, resgates, portos, comércio, facções marítimas ficcionais, cidades que evoluem, transporte e expedições | Pendente |
| 10 | Pesquisa, mercado e rede | Pesquisa, tecnologia, indústria, energia, bases inteligentes, Rede Global, relógio/comunicação, moedas distintas e pontos específicos de compra | Pendente |
| 11 | História, mistério e Essências | Catástrofe, bomba de nitrogênio e chefes congelados do Ártico, ruínas, exploração narrativa, Essências, VISÃO e cinco evoluções, Clarividência limitada | Pendente. Propostas de chefes não são cânone |
| 12 | Multiplayer e permissões | Servidores, mundo persistente, cooperação, grupos, comunicação, inventário sincronizado, economia, papéis, proprietário/administrador/piloto e acesso às bases | Pendente |
| 13 | Acabamento e lançamento | Modelos e animações originais, texturas PBR, áudio, menus, tutoriais, otimização Android/PC, estabilidade, acessibilidade, assinaturas e atualização segura | Pendente |

## Visual almejado e realidade da renderização
- **Alvo artístico:** mundo semi-realista futurista, vegetação natural, vidro e metal convincentes, luz interna quente, oceano azul-esverdeado, montanhas, nuvens, cavernas, instalações e painéis futuristas.
- **Versão atual:** cenário gerado por código e materiais simples; não possui ainda modelagem profissional, texturas fotográficas PBR e animações humanas.
- **Evolução necessária:** modelos originais ou CC0 com licenças verificadas, materiais PBR, água e superfícies avançadas, LOD, culling, renderização por perfil, iluminação adaptada ao hardware, arte consistente.
- **APK grande por si só não melhora a aparência** e pode piorar carregamento e performance. Tamanho deve acompanhar qualidade real.

## Canal de mudanças por chat
O usuário pede "No O RECOMEÇO, ..."; o assistente com GitHub conectado modifica scripts/arquivos de configuração, roda build CI e dá link de um APK experimental **somente quando sucesso confirmado**. Não há atualização invisível do APK já instalado.

## Próximo teste prioritário
Instalar a versão com o novo cenário e verificar no POCO:
- Se o cenário está bem iluminado e visível, sem objetos suspensos ou texturas quebradas.
- Se controles de toque não encobrem a visão e as câmeras funcionam.
- Se itens, baú, jangada, save e menu continuam funcionando.
- Se o FPS e a RAM são aceitáveis com os recursos visuais melhorados.

## O que não deve ser perdido
Não remover ideias aprovadas. Registrar propostas como propostas, itens sem detalhes como lacunas pendentes e diferenças entre arte conceitual e gameplay real. Exigir evidências para declarar a conclusão de cada tarefa.
