--------------- Electra Power ---------------

-- Timerange: 23:00-07:00 
-- Weekdays: Sunday, Monday, Thursday, Wednsday, Tuesday, Friday, Saturday (all)
-- Discount Ratio: 8%

;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				--DATEPART(DAY,date) AS 'day',
				DATENAME(MONTH,date) AS 'month',
				--DATEPART(YEAR,date) AS 'year',
				--DATEPART(QUARTER,date) AS 'quarter_date',
					CASE WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-17:00'
				END AS time_range
	FROM electricity_usage)

SELECT  month,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		DENSE_RANK() OVER(ORDER BY SUM(kwh_consumption) DESC) AS 'DRANK_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',

		CASE WHEN time_range ='23:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.08
		ELSE 0
		END AS 'ElectraPower_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN time_range ='23:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.08
		ELSE 0
		END AS 'ElectraPower_price_after_discount'

FROM electricity_cte
GROUP BY month, time_range
ORDER BY DRANK_consumption_price, month,time_range


