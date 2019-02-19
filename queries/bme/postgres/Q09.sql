SELECT 76 AS geografia_cod,
       9000 AS geografia_dim_cod,
       'Pais' AS geografia_dim_desc,
       g000.denominacao AS geografia_desc,
       cd2010adomi.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       tab1.denominacao AS col1,
       tab1.ordem AS col1_ord,
       tab1.codigo AS col1_cod,
       tab2.denominacao AS col2,
       tab2.ordem AS col2_ord,
       tab2.codigo AS col2_cod,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g000,
     t030,
     cd279500 tab1,
     cd275000 tab2,
     cd2010apess,
     cd2010adomi
WHERE (cd2010apess.v0300 = cd2010adomi.v0300
       AND cd2010apess.codmunicipio = cd2010adomi.codmunicipio)
  AND cd2010adomi.codanopesq = 2010
  AND cd2010apess.codv0601 = tab1.codigo
  AND cd2010adomi.codv1006 = tab2.codigo
  AND cd2010adomi.codanopesq = t030.codigo
GROUP BY g000.denominacao,
         cd2010adomi.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo,
         tab2.denominacao,
         tab2.ordem,
         tab2.codigo;