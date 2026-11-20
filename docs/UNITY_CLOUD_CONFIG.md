# Cloud: rota gratuita escolhida para RENASCER

## Escolha
Unity 6 Personal + Unity Build Automation (UBA) conectado ao repositorio publico GitHub `ronaldweker-prog/game`, branch `unity6-renascer`.

A Unity informou em 2026 faixa mensal gratuita com 200 minutos de build Windows e 25 GB de armazenamento DevOps. Verifique quotas atuais no painel antes de ativar consumo adicional: https://unity.com/products/pricing-updates

**Build na nuvem nao equivale a editor 3D interativo na nuvem.** Ainda e necessario validar cenas, modelos e animacoes em uma instalacao de Unity com GPU quando houver acesso. Os servicos gratuitos nao garantem isso.

## Configuracao de titular da conta
1. Acesse https://cloud.unity.com e entre com Unity ID, observando os requisitos aplicaveis da plataforma.
2. Em Unity DevOps > Build Automation > Source Control, selecione GitHub, repositorio `ronaldweker-prog/game` e branch `unity6-renascer`.
3. Se pedir autorizacao, conceda **apenas no site oficial**. Nao envie senha nem token no chat. Para repositorio publico, a documentacao permite conexao publica em alguns fluxos.
4. Crie target **Windows x64**, editor Unity `6000.0.40f1` ou atualizacao 6000.0 compativel, pasta raiz `/`. Defina o pre-export method `Renascer.EditorTools.RenascerCloudBuild.PreExport` nas configuracoes avancadas.
5. Selecione Scene `Assets/Scenes/Renascer.unity` quando ela tiver sido gerada pelo editor, ou deixe Build Automation usar o Build Settings criado pelo script. Confirme logs e resultado.
6. Para Android, crie target Android, solicite build de APK para testes (nao AAB), configure SDK/NDK e assinatura de teste pelo servico. Nunca compartilhe chaves de assinatura no repositorio.
7. Acompanhe consumo de minutos e armazenamento. Nao ative cobranca pay-as-you-go sem decisao consciente de responsavel pela conta.

## Arquivos existentes
- `Assets/Editor/RenascerCloudBuild.cs`: gera a cena minima e prepara o Build Settings; inclui comandos locais para Windows e Android.
- `Assets/Scripts/Core/GameBootstrap.cs`: cria o mundo e gameplay ao iniciar.
- `Assets/Scripts/Core/InputBridge.cs`: compatibilidade com Unity Input System novo ou antigo.

## Validade da integracao
Ainda nao foi feita a autorizacao da Unity Cloud nesta conversa; por isso, builds Unity nao foram executadas nem verificadas. O GitHub Actions presente nesta branch verifica **somente arquivos-fonte**.
