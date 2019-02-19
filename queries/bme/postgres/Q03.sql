SELECT 76 AS geografia_cod,
       9000 AS geografia_dim_cod,
       'Pais' AS geografia_dim_desc,
       g000.denominacao AS geografia_desc,
       cd2010apess.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       SUM(cd2010apess.v6036 * cd2010apess.pesopess) / SUM(cd2010apess.pesopess) AS col1,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g000,
     t030,
     cd2010apess
WHERE cd2010apess.codanopesq = 2010
  AND cd2010apess.codanopesq = t030.codigo
GROUP BY g000.denominacao,
         cd2010apess.codanopesq,
         t030.denominacao;