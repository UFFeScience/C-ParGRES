PASSO 1:

SELECT CD2010APESS.CODMUNICIPIO GEOGRAFIA_COD , 9235 GEOGRAFIA_DIM_COD , 'Município (2010)' GEOGRAFIA_DIM_DESC , CD2010APESS.CODANOPESQ TEMPO_COD , 8030 TEMPO_DIM_COD , NVL(CD2010APESS.CODV0601, -1) COL1 , NVL(CD2010APESS.CODV0633, -1) COL2 , SUM(CD2010APESS.V6036 * CD2010APESS.PESOPESS) / SUM(CD2010APESS.PESOPESS) COL3 , SUM(CD2010APESS.PESOPESS) frequencia , count(*) contagem FROM IBGE.CD2010APESS WHERE (CD2010APESS.CODMUNICIPIO = '2408102' OR CD2010APESS.CODMUNICIPIO = '3304557') GROUP BY CD2010APESS.CODMUNICIPIO , CD2010APESS.CODANOPESQ , NVL(CD2010APESS.CODV0601, -1) , NVL(CD2010APESS.CODV0633, -1)

PASSO 2:

SELECT BMM_TMP_872975.GEOGRAFIA_COD , BMM_TMP_872975.GEOGRAFIA_DIM_COD , BMM_TMP_872975.GEOGRAFIA_DIM_DESC , G235.Denominacao geografia_desc , BMM_TMP_872975.TEMPO_COD , BMM_TMP_872975.TEMPO_DIM_COD , T030.Denominacao tempo_desc , tab1.Denominacao COL1 , tab1.Ordem COL1_ord , tab1.Codigo COL1_cod , tab2.Denominacao COL2 , tab2.Ordem COL2_ord , tab2.Codigo COL2_cod , BMM_TMP_872975.COL3 , BMM_TMP_872975.FREQUENCIA , BMM_TMP_872975.CONTAGEM FROM G235 , T030 , CD279500 tab1 , CD284000 tab2 , BMM_TMP_872975 WHERE (BMM_TMP_872975.GEOGRAFIA_COD = '2408102' OR BMM_TMP_872975.GEOGRAFIA_COD = '3304557') AND BMM_TMP_872975.GEOGRAFIA_DIM_COD = 9235 AND (BMM_TMP_872975.TEMPO_COD = '2010') AND BMM_TMP_872975.TEMPO_DIM_COD = 8030 AND BMM_TMP_872975.COL1 = tab1.Codigo AND BMM_TMP_872975.COL2 = tab2.Codigo AND BMM_TMP_872975.TEMPO_COD = T030.Codigo AND BMM_TMP_872975.GEOGRAFIA_COD = G235.Codigo