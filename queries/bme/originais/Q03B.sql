PASSO 1:

SELECT 76 GEOGRAFIA_COD , 9000 GEOGRAFIA_DIM_COD , 'País' GEOGRAFIA_DIM_DESC , CD2010APESS.CODANOPESQ TEMPO_COD , 8030 TEMPO_DIM_COD , NVL(CD2010APESS.CODV6036, -1) COL1 , SUM(CD2010APESS.V6036 * CD2010APESS.PESOPESS) / SUM(CD2010APESS.PESOPESS) COL2 , SUM(CD2010APESS.PESOPESS) frequencia , count(*) contagem FROM IBGE.CD2010APESS GROUP BY 76 , CD2010APESS.CODANOPESQ , NVL(CD2010APESS.CODV6036, -1)

PASSO 2:

SELECT BMM_TMP_872965.GEOGRAFIA_COD , BMM_TMP_872965.GEOGRAFIA_DIM_COD , BMM_TMP_872965.GEOGRAFIA_DIM_DESC , G000.Denominacao geografia_desc , BMM_TMP_872965.TEMPO_COD , BMM_TMP_872965.TEMPO_DIM_COD , T030.Denominacao tempo_desc , tab1.Denominacao COL1 , tab1.Ordem COL1_ord , tab1.Codigo COL1_cod , BMM_TMP_872965.COL2 , BMM_TMP_872965.FREQUENCIA , BMM_TMP_872965.CONTAGEM FROM G000 , T030 , CD549400 tab1 , BMM_TMP_872965 WHERE BMM_TMP_872965.GEOGRAFIA_DIM_COD = 9000 AND (BMM_TMP_872965.TEMPO_COD = '2010') AND BMM_TMP_872965.TEMPO_DIM_COD = 8030 AND BMM_TMP_872965.COL1 = tab1.Codigo AND BMM_TMP_872965.TEMPO_COD = T030.Codigo