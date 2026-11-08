# Skills
- Antes de instalar uma skill ou plugin, analisa-a com `skill-inspector`. APPROVE: instala e resume.
  CAUTION/REJECT: explica os riscos em português e só instala se o utilizador confirmar.
- Se o hook `skill-guard` avisar, segue as instruções dele.
- Os plugins `ponytail` (código simples) e `lemo-opuscar` (vídeos em código) estão desligados por defeito.
  Quando forem úteis, avisa o utilizador (o lemo-opuscar gasta muitos tokens) e só com confirmação liga-os
  nessa sessão: `claude plugin enable <plugin>` e depois o utilizador corre `/reload-plugins`.
