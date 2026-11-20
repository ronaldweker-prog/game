# O RECOMEÇO — Estado real, aceitação e testes

## Situação
- **Código atual no GitHub:** primeiro protótipo 3D monolítico Godot 4.4, ainda sem validação em Godot.
- **APK disponível para instalar:** NÃO CONFIRMADO.
- **Testes num POCO M7 Pro 5G:** NÃO EXECUTADOS.
- **Multiplayer real:** NÃO IMPLEMENTADO.
- **Fidelidade visual das imagens de referência:** NÃO ALCANÇADA.

## Definição de pronto (não negociável)
Marcar uma tarefa concluída somente quando compilou, funciona por toque e/ou teclado, possui testes de jogo e persistência aplicável, não causa regressão e foi medida no dispositivo quando afetar desempenho.

## Etapas com critérios de aceitação

| Etapa | Sistemas a entregar | Estado |
|---|---|---|
| 0. Build | CI GitHub Actions, Godot export Android, assinatura de teste, APK instalável, teste físico POCO | Preparação; **pendente validação** |
| 1. Ilha | exploração 3D, colisões, movimento, câmera 1ª/3ª, HUD, touch, qualidade, salvamento e menu | Protótipo em código; **não validado** |
| 2. Sobrevivência | coleta, recursos, inventário organizado, peso/capacidade, água, fome, energia, oxigênio, fabricação/estações, abrigo | Parcial em código; restante pendente |
| 3. Oceano | natação/mergulho, correntes, oxigênio, biomas aquáticos, jangada modular física, baú, veículos náuticos e base aquática | Jangada simples em código; restante pendente |
| 4. Ecossistema | IA individual de criaturas, populações abstratas longe do jogador, clima, migração, chefes únicos | Pendente |
| 5. Construção | prévias, snap modular, colocação/cancelamento, estruturas internas funcionais, móveis, eletricidade, água, estabilidade | Abrigo básico no código; restante pendente |
| 6. Bases | terrestres, subaquáticas, aéreas, subterrâneas, móveis e híbridas, interior navegável, PAC, aterrissagem/acoplamento | Pendente |
| 7. Veículos | carros, 6x6, caminhões, barcos, submarinos, aviões, drones, suspensão/combustível, pilotagem/câmeras/manutenção | Pendente |
| 8. NPCs | rotinas, resgates, suprimentos, comunidades, comércio, facções/piratas, desenvolvimento econômico | Pendente |
| 9. Pesquisa e indústria | fábricas, agricultura, automação, energia, rede, comunicação, relógio, IA administrativa | Pendente |
| 10. Narrativa | colapso, bomba de nitrogênio, ruínas emergentes, missões, chefes, Essências e VISÃO | Pendente |
| 11. Multiplayer | co-op, voz opcional/texto, servidor, sincronização, salvamento, papéis, permissões, anti-duplicação | Pendente |
| 12. Polimento | arte 3D original, luzes, áudio, interface, acessibilidade, FPS, estabilidade, correção de falhas | Pendente |

## Testes mínimos antes de anunciar um APK
- Godot abre `project.godot`, importa todos recursos e reconhece scripts.
- Exportar sem erro e gerar um APK ARM64 não vazio com assinatura de teste.
- Instalar e abrir no POCO; iniciar menu e nova partida.
- Andar, olhar livremente e alternar 1ª/3ª pessoa.
- Coletar e conferir inventário; tentar fabricar SEM recursos (sem gerar item) e COM recursos (gerar e descontar).
- Construir abrigo, cancelamento/colisão, jangada, embarcar/navegar e desembarcar.
- Salvar, fechar app, reabrir e validar inventário, posição, jangada/baú, abrigos e configurações.
- Ajustar qualidade e medir FPS no dispositivo por pelo menos alguns minutos.
- Verificar ausência de travamentos críticos e abuso de RAM/bateria.

## Não fazer
Não marcar todos os sistemas como completos só porque os nomes aparecem no documento mestre; não criar telas falsas no lugar de mecânicas; não prometer fidelidade AAA em hardware móvel limitado.
