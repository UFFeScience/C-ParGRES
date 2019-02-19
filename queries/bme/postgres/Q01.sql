SELECT 76 AS geografia_cod,
       9000 AS geografia_dim_cod,
       'Pais' AS geografia_dim_desc,
       g000.denominacao AS geografia_desc,
       cd2010adomi.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       tab1.denominacao AS col1_den,
       tab1.ordem AS col1_ord,
       tab1.codigo AS col1_cod,
       SUM(cd2010adomi.pesodomi) AS frequencia,
       COUNT(*) AS contagem
FROM g000,
     t030,
     cd275000 tab1,
     cd2010adomi
WHERE cd2010adomi.codanopesq = 2010
  AND cd2010adomi.codv1006 = tab1.codigo
  AND cd2010adomi.codanopesq = t030.codigo
GROUP BY g000.denominacao,
         cd2010adomi.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo;