# Skills
- Antes de instalar uma skill ou plugin, analisa-a com `skill-inspector`. APPROVE: instala e resume.
  CAUTION/REJECT: explica os riscos em português e só instala se o utilizador confirmar.
- Se o hook `skill-guard` avisar, segue as instruções dele.
- O plugin `ponytail` está desligado por defeito. Quando uma tarefa de programação beneficiar dele, avisa o
  utilizador e pergunta antes de o ligar (`/ponytail`) e de começar a tarefa.
- O skill `lemo-opuscar` (vídeos em código) está escondido por defeito. Quando o utilizador pedir um vídeo,
  avisa que gasta muitos tokens e, se confirmar, liga-o (`skillOverrides` "lemo-opuscar:lemo-opuscar") só nessa sessão.
