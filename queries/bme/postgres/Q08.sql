SELECT cd2010apess.codmunicipio AS geografia_cod,
       9235 AS geografia_dim_cod,
       'Municipio (2010)' AS geografia_dim_desc,
       g235.denominacao AS geografia_desc,
       cd2010apess.codanopesq AS tempo_cod,
       8030 AS tempo_dim_cod,
       t030.denominacao AS tempo_desc,
       tab1.denominacao AS col1,
       tab1.ordem AS col1_ord,
       tab1.codigo AS col1_cod,
       tab2.denominacao AS col2,
       tab2.ordem AS col2_ord,
       tab2.codigo AS col2_cod,
       SUM(cd2010apess.v6036 * cd2010apess.pesopess) / SUM(cd2010apess.pesopess) AS col3,
       SUM(cd2010apess.pesopess) AS frequencia,
       COUNT(*) AS contagem
FROM g235,
     t030,
     cd279500 tab1,
     cd284000 tab2,
     cd2010apess
WHERE (cd2010apess.codmunicipio = 2408102
       OR cd2010apess.codmunicipio = 3304557)
  AND cd2010apess.codanopesq = 2010
  AND cd2010apess.codv0601 = tab1.codigo
  AND cd2010apess.codv0633 = tab2.codigo
  AND cd2010apess.codanopesq = t030.codigo
  AND cd2010apess.codmunicipio = g235.codigo
GROUP BY cd2010apess.codmunicipio,
         g235.denominacao,
         cd2010apess.codanopesq,
         t030.denominacao,
         tab1.denominacao,
         tab1.ordem,
         tab1.codigo,
         tab2.denominacao,
         tab2.ordem,
         tab2.codigo;