SELECT A.CODPAIS,
A.sidra_0001_13_00 AS sidra_0001_13, 
A.sidra_0137_05_00 AS sidra_0137_05, 
A.sidra_0065_05_01 AS sidra_0065_05, 
A.sidra_0074_02_00 AS sidra_0074_02, 
A.sidra_0471_04_00 AS sidra_0471_04, 
SUM(PESODOMI) AS V884,
SUM(V6529 * A.PESODOMI) / SUM(PESODOMI) AS V878, 
SUM(V0401 * A.PESODOMI) AS V1883
FROM CD2010ADOMI A
WHERE A.CODANOPESQ = 2010 AND A.CODV4001 = 1 AND A.V6529 > 0 AND A.V6529 <= 9999999
GROUP BY 
A.CODPAIS, A.sidra_0001_13_00, A.sidra_0137_05_00, A.sidra_0065_05_01, A.sidra_0074_02_00, A.sidra_0471_04_00
HAVING ( 
(A.sidra_0001_13_00 <> -1) AND (A.sidra_0137_05_00 <> -1) AND (A.sidra_0065_05_01 <> -1) AND (A.sidra_0074_02_00 <> -1) AND (A.sidra_0471_04_00 <> -1));