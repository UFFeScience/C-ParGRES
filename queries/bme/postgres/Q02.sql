SELECT 76 AS geografia_cod,
       9000 AS geografia_dim_cod,
       'Pais' AS geografia_dim_desc,
       g000.denominacao AS geografia_desc,
       cd2010apess.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       tab1.denominacao AS col1_den,
       tab1.ordem AS col1_ord,
       tab1.codigo AS col1_cod,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g000,
     t030,
     cd549400 tab1,
     cd2010apess
WHERE cd2010apess.codanopesq = 2010
  AND cd2010apess.codv6036 = tab1.codigo
  AND cd2010apess.codanopesq = t030.codigo
GROUP BY g000.denominacao,
         cd2010apess.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo;