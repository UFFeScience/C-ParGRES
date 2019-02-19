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
       tab2.denominacao AS col2,
       tab2.ordem AS col2_ord,
       tab2.codigo AS col2_cod,
       tab3.denominacao AS col3,
       tab3.ordem AS col3_ord,
       tab3.codigo AS col3_cod,
       tab4.denominacao AS col4,
       tab4.ordem AS col4_ord,
       tab4.codigo AS col4_cod,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g032,
     t030,
     cd281800 tab1,
     cd281500 tab2,
     cd275000 tab3,
     cd275300 tab4,
     cd2010apess,
     cd2010adomi
WHERE (cd2010apess.v0300 = cd2010adomi.v0300
       AND cd2010apess.codmunicipio = cd2010adomi.codmunicipio)
  AND g032.ind_exibicao = 'S'
  AND cd2010adomi.codanopesq = 2010
  AND ((cd2010apess.codv0617 = 1)
       OR (cd2010apess.codv0615 = 1
           OR cd2010apess.codv0615 = 2
           OR cd2010apess.codv0615 = 3))
  AND (cd2010adomi.codv4002 = 11
       OR cd2010adomi.codv4002 = 12
       OR cd2010adomi.codv4002 = 13
       OR cd2010adomi.codv4002 = 14
       OR cd2010adomi.codv4002 = 15
       OR cd2010adomi.codv4002 = 51
       OR cd2010adomi.codv4002 = 52
       OR cd2010adomi.codv4002 = 53
       OR cd2010adomi.codv4002 = 61
       OR cd2010adomi.codv4002 = 62
       OR cd2010adomi.codv4002 = 63
       OR cd2010adomi.codv4002 = 64
       OR cd2010adomi.codv4002 = 65
       OR cd2010adomi.codv4002 = 71
       OR cd2010adomi.codv4002 = 72
       OR cd2010adomi.codv4002 = 73
       OR cd2010adomi.codv4002 = 74)
  AND cd2010apess.codv0617 = tab1.codigo
  AND cd2010apess.codv0615 = tab2.codigo
  AND cd2010adomi.codv1006 = tab3.codigo
  AND cd2010adomi.codv4002 = tab4.codigo
  AND cd2010adomi.codanopesq = t030.codigo
  AND cd2010adomi.codufcenso = g032.codigo
GROUP BY cd2010adomi.codufcenso,
         g032.denominacao,
         cd2010adomi.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo,
         tab2.denominacao,
         tab2.ordem,
         tab2.codigo,
         tab3.denominacao,
         tab3.ordem,
         tab3.codigo,
         tab4.denominacao,
         tab4.ordem,
         tab4.codigo;