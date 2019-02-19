SELECT cd2010adomi.codufcenso AS geografia_cod,
       9032 AS geografia_dim_cod,
       'Unidade da Federacao' AS geografia_dim_desc,
       g032.denominacao AS geografia_desc,
       cd2010adomi.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       tab1.denominacao AS col1,
       tab1.ordem AS col1_ord,
       tab1.codigo AS col1_cod,
       SUM(cd2010apess.v6036 * cd2010apess.pesopess) / SUM(cd2010apess.pesopess) AS col2,
       SUM(cd2010adomi.v6531 * cd2010adomi.pesodomi) / SUM(cd2010adomi.pesodomi) AS col3,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g032,
     t030,
     cd275200 tab1,
     cd2010apess,
     cd2010adomi
WHERE (cd2010apess.v0300 = cd2010adomi.v0300
       AND cd2010apess.codmunicipio = cd2010adomi.codmunicipio)
  AND g032.ind_exibicao = 'S'
  AND cd2010adomi.codanopesq = 2010
  AND (cd2010adomi.codv4001 = 1
       OR cd2010adomi.codv4001 = 2
       OR cd2010adomi.codv4001 = 3
       OR cd2010adomi.codv4001 = 4)
  AND (cd2010adomi.v6531 <= 140)
  AND cd2010adomi.codv4001 = tab1.codigo
  AND cd2010adomi.codanopesq = t030.codigo
  AND cd2010adomi.codufcenso = g032.codigo
GROUP BY cd2010adomi.codufcenso,
         g032.denominacao,
         cd2010adomi.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo;