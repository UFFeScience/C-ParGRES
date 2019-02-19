PASSO 1:

SELECT CD2010ADOMI.CODUFCENSO GEOGRAFIA_COD , 9032 GEOGRAFIA_DIM_COD , 'Unidade da Federação' GEOGRAFIA_DIM_DESC , CD2010ADOMI.CODANOPESQ TEMPO_COD , 8030 TEMPO_DIM_COD , NVL(CD2010ADOMI.CODV4001, -1) COL1 , SUM(CD2010APESS.V6036 * CD2010APESS.PESOPESS) / SUM(CD2010APESS.PESOPESS) COL2 , SUM(CD2010ADOMI.V6531 * CD2010ADOMI.PESODOMI) / SUM(CD2010ADOMI.PESODOMI) COL3 , SUM(CD2010APESS.PESOPESS) frequencia , count(*) contagem FROM IBGE.CD2010APESS , IBGE.CD2010ADOMI WHERE CD2010ADOMI.CODUFCENSO in (select Codigo from G032 where IND_EXIBICAO = 'S' ) AND (CD2010ADOMI.CODV4001 = '1' OR CD2010ADOMI.CODV4001 = '2' OR CD2010ADOMI.CODV4001 = '3' OR CD2010ADOMI.CODV4001 = '4') AND (CD2010ADOMI.V6531 <= 140) AND (CD2010APESS.V0006 = CD2010ADOMI.V0006 AND CD2010APESS.V0007 = CD2010ADOMI.V0007 AND CD2010APESS.CODSETOR = CD2010ADOMI.CODSETOR) GROUP BY CD2010ADOMI.CODUFCENSO , CD2010ADOMI.CODANOPESQ , NVL(CD2010ADOMI.CODV4001, -1)

PASSO 2:

SELECT BMM_TMP_872985.GEOGRAFIA_COD , BMM_TMP_872985.GEOGRAFIA_DIM_COD , BMM_TMP_872985.GEOGRAFIA_DIM_DESC , G032.Denominacao geografia_desc , BMM_TMP_872985.TEMPO_COD , BMM_TMP_872985.TEMPO_DIM_COD , T030.Denominacao tempo_desc , tab1.Denominacao COL1 , tab1.Ordem COL1_ord , tab1.Codigo COL1_cod , BMM_TMP_872985.COL2 , BMM_TMP_872985.COL3 , BMM_TMP_872985.FREQUENCIA , BMM_TMP_872985.CONTAGEM FROM G032 , T030 , CD275200 tab1 , BMM_TMP_872985 WHERE BMM_TMP_872985.GEOGRAFIA_DIM_COD = 9032 AND (BMM_TMP_872985.TEMPO_COD = '2010') AND BMM_TMP_872985.TEMPO_DIM_COD = 8030 AND BMM_TMP_872985.COL1 = tab1.Codigo AND BMM_TMP_872985.TEMPO_COD = T030.Codigo AND BMM_TMP_872985.GEOGRAFIA_COD = G032.Codigo