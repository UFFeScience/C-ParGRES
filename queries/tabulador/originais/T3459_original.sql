CREATE TABLE RT_CD2010_T3459_12234b AS (
 SELECT  CASE WHEN CD2010APESS.CODV6121 IN (110, 111, 112) THEN 1 WHEN CD2010APESS.CODV6121 IN (210, 219, 220, 221, 222, 223, 224, 225, 229, 230, 231, 232, 239, 240, 241, 242, 243, 244, 245, 249, 250, 251, 259, 260, 261, 262, 269, 270, 279, 280, 289, 300, 310, 311, 312, 319, 320, 329, 330, 339, 340, 349, 350, 359, 360, 369, 370, 379, 380, 389, 390, 399, 400, 401, 409, 420, 429, 430, 439, 440, 449, 450, 451, 452, 453, 454, 455, 460, 469, 470, 479, 480, 489, 490, 492, 499) THEN 2 WHEN CD2010APESS.CODV6121 IN (610, 619) THEN 6 WHEN CD2010APESS.CODV6121 IN (620, 629, 630, 639, 640, 641, 649) THEN 7 WHEN CD2010APESS.CODV6121 IN (120, 130, 140, 149, 199, 510, 519, 520, 529, 530, 590, 599, 710, 711, 719, 740, 741, 749, 750, 751, 752, 753, 754, 755, 759, 760, 761, 762, 763, 764, 765, 766, 790, 791, 792, 793, 799, 810, 811, 819, 820, 821, 829, 830, 831, 832, 833, 834, 839, 850, 890, 891, 892, 893, 894, 895, 896) THEN 8 WHEN CD2010APESS.CODV6121 IN (0, 1, 2) THEN 9 WHEN CD2010APESS.CODV6121 = 990 THEN 10 WHEN CD2010APESS.CODV6121 = 999 THEN 11 ELSE -1 END AS INDICADORA_A00, 
 CASE WHEN CD2010APESS.CODV6121 IN (210, 219, 220, 221, 222, 223, 224, 225, 229, 230, 231, 232, 239, 240, 241, 242, 243, 244, 245, 249, 250, 251, 259, 260, 261, 262, 269, 270, 279, 280, 289) THEN 3 WHEN CD2010APESS.CODV6121 IN (300, 310, 311, 312, 319, 320, 329, 330, 339, 340, 349, 350, 359, 360, 369, 370, 379, 380, 389, 390, 399, 400, 401, 409, 420, 429, 430, 439, 440, 449, 450, 451, 452, 453, 454, 455, 460, 469, 470, 479, 480, 489) THEN 4 WHEN CD2010APESS.CODV6121 IN (490, 492, 499) THEN 5 ELSE -1 END AS INDICADORA_A01, 
 CASE WHEN CD2010APESS.CODV0601 = 1 THEN 1 WHEN CD2010APESS.CODV0601 = 2 THEN 2 ELSE -1 END AS INDICADORA_B00, 
 CASE WHEN CD2010APESS.CODV0648 IN (1, 2, 3, 4) THEN 1 WHEN CD2010APESS.CODV0648 = 7 THEN 7 WHEN CD2010APESS.CODV0644 = 1 THEN 8 WHEN CD2010APESS.CODV0648 = 6 THEN 6 WHEN CD2010APESS.CODV0648 = 5 THEN 5 ELSE -1 END AS INDICADORA_C00, 
 CASE WHEN CD2010APESS.CODV0648 = 1 THEN 2 WHEN CD2010APESS.CODV0648 IN (2, 3) THEN 3 WHEN CD2010APESS.CODV0648 = 4 THEN 4 ELSE -1 END AS INDICADORA_C01, 
 CASE WHEN CD2010APESS.V6525 > 0 AND CD2010APESS.V6525 <= 255 THEN 1 WHEN CD2010APESS.V6525 > 255 AND CD2010APESS.V6525 <= 510 THEN 2 WHEN CD2010APESS.V6525 > 510 AND CD2010APESS.V6525 <= 1020 THEN 3 WHEN CD2010APESS.V6525 > 1020 AND CD2010APESS.V6525 <= 1530 THEN 11 WHEN CD2010APESS.V6525 > 1530 AND CD2010APESS.V6525 <= 2550 THEN 4 WHEN CD2010APESS.V6525 > 2550 AND CD2010APESS.V6525 <= 5100 THEN 5 WHEN CD2010APESS.V6525 > 5100 AND CD2010APESS.V6525 <= 7650 THEN 6 WHEN CD2010APESS.V6525 > 7650 AND CD2010APESS.V6525 <= 10200 THEN 7 WHEN CD2010APESS.V6525 > 10200 AND CD2010APESS.V6525 <= 15300 THEN 8 WHEN CD2010APESS.V6525 > 15300 THEN 9 WHEN CD2010APESS.V6525 = 0 THEN 10 ELSE -1 END AS INDICADORA_D00, 
CD2010APESS.V6036, 
CD2010APESS.CODV6910, 
CD2010APESS.PESOPESS, 
CD2010APESS.CODPAIS AS INDICADORA_GEOG1, 
CD2010APESS.CODANOPESQ AS INDICADORA_TEMPORAL
 FROM IBGE.CD2010APESS
 WHERE CD2010APESS.CODANOPESQ = 2010 AND (CD2010APESS.V6036 >= 10 AND CD2010APESS.CODV6910 = 1)
);


---------------------------------------------------------------------


SELECT A.INDICADORA_GEOG1, 
A.INDICADORA_A00, 
A.INDICADORA_A01, 
A.INDICADORA_B00, 
A.INDICADORA_C00, 
A.INDICADORA_C01, 
A.INDICADORA_D00, 
SUM(A.PESOPESS) AS V916
 FROM 
RT_CD2010_T3459_12234b A 
 GROUP BY 
A.INDICADORA_GEOG1,
 GROUPING SETS ( 
(A.INDICADORA_A00, A.INDICADORA_B00, A.INDICADORA_C00, A.INDICADORA_D00), 
(A.INDICADORA_A00, A.INDICADORA_B00, A.INDICADORA_C01, A.INDICADORA_D00), 
(A.INDICADORA_A01, A.INDICADORA_B00, A.INDICADORA_C00, A.INDICADORA_D00), 
(A.INDICADORA_A01, A.INDICADORA_B00, A.INDICADORA_C01, A.INDICADORA_D00) ) 
 HAVING ( 
( NVL(A.INDICADORA_A00, -1) <> -1 OR NVL(A.INDICADORA_A01, -1) <> -1 ) AND
( NVL(A.INDICADORA_B00, -1) <> -1 ) AND
( NVL(A.INDICADORA_C00, -1) <> -1 OR NVL(A.INDICADORA_C01, -1) <> -1 ) AND
( NVL(A.INDICADORA_D00, -1) <> -1 ) )
;
