DECLARE 
      @currentDATE DATETIME = CAST(GETDATE() AS SMALLDATETIME)

DECLARE
	  @DataHoraInicial	DATETIME = DATEADD(MI,-30, @currentDATE)
	, @DataHoraFinal	DATETIME = @currentDATE

SELECT @DataHoraInicial AS IniDate,@DataHoraFinal AS EndDate, 'Minutes' AS Slices, DATEDIFF(MI,@DataHoraInicial,@DataHoraFinal) AS TimeSliceSize

;WITH 
		Digits(d) AS (
			SELECT 0 AS d UNION ALL
			SELECT 1 UNION ALL
			SELECT 2 UNION ALL
			SELECT 3 UNION ALL
			SELECT 4 UNION ALL
			SELECT 5 UNION ALL
			SELECT 6 UNION ALL
			SELECT 7 UNION ALL
			SELECT 8 UNION ALL
			SELECT 9
		)
		,Sequence(s) AS (
			SELECT 
			TOP (DATEDIFF(MI,@DataHoraInicial,@DataHoraFinal))
				D1.d + (D2.d * 10) + (D3.d * 100) + (D4.d * 1000) AS s
			FROM Digits D1
				CROSS JOIN Digits D2
				CROSS JOIN Digits D3
				CROSS JOIN Digits D4
			ORDER BY s
		)
SELECT
	 s		AS [TimeSlice]
	,DATEADD(mi, s, @DataHoraInicial)	AS [TimePeriodStart]
	,CASE WHEN LEAD(s	, 1,0) OVER (ORDER BY s	) = 0 THEN @DataHoraFinal ELSE DATEADD(mi, LEAD(s	, 1,0) OVER (ORDER BY s	), @DataHoraInicial) END	AS [TimePeriodEnd]
FROM Sequence	


