SELECT A.CODPAIS, 
A.sidra_0001_13_00  AS sidra_0001_13_00,
A.sidra_0065_05_00  AS sidra_0065_05_00,
A.sidra_12060_05_07 AS sidra_12060_05_00,
SUM(PESODOMI) AS V884, 
SUM(A.V6529 * A.PESODOMI) / SUM(A.PESODOMI) AS V878, 
SUM(A.V0401 * A.PESODOMI) AS V1883
FROM CD2010ADOMI A 
WHERE A.CODANOPESQ = 2010 AND A.CODV4001 = 1 AND A.V6529 > 0 AND A.V6529 <= 9999999
GROUP BY 
A.CODPAIS, A.sidra_0001_13_00, A.sidra_0065_05_00, A.sidra_12060_05_07 
HAVING ( 
A.sidra_0001_13_00 <> -1 AND A.sidra_0065_05_00 <> -1 AND A.sidra_12060_05_07 <> -1);