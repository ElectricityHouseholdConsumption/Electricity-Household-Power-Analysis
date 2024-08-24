USE electricity_usage
GO

-------------GENERAL DATA------------------

SELECT *
FROM [dbo].[electricity_usage]

--------------Calculated Consumption and price--------------------


;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS price_per_kWh_ils,
				0.5252 * kwh_consumption AS price_per_beat_ils,
				DATENAME(WEEKDAY,date) AS week_day,
				DATEPART(DAY,date) AS day,
				DATENAME(MONTH,date) AS month,
				DATEPART(YEAR,date) AS year,
				DATEPART(QUARTER,date) AS quarter_date,
				CASE WHEN beat_start_time BETWEEN '07:00:00' AND '17:00:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:01:00' AND '23:00:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range		
	FROM electricity_usage)

SELECT  month,time_range,
		SUM(kwh_consumption) AS total_month_consumption,
		SUM(price_per_beat_ils) AS total_month_price,
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS pct_of_total_consumption_price,
		DENSE_RANK() OVER(ORDER BY SUM(kwh_consumption) DESC) AS DRANK_consumption_price

FROM electricity_cte
GROUP BY month,time_range
ORDER BY DRANK_consumption_price, month

------------------------Plan A Discount Overview-----------------------
-- Timerange: 07:00-17:00, 17:00-23:00, 23:00-07:00 (All Day)
-- Weekdays: Sunday, Monday, Thursday, Wednsday, Tuesday, Friday, Saturday (all)
-- Discount Ratio: 7%

;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATEPART(DAY,date) AS 'day',
				DATENAME(MONTH,date) AS 'month',
				DATEPART(YEAR,date) AS 'year',
				DATEPART(QUARTER,date) AS 'quarter_date',
				CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range		
	FROM electricity_usage)

SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		DENSE_RANK() OVER(ORDER BY SUM(kwh_consumption) DESC) AS 'DRANK_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_discount_in_Shekel',
		SUM(price_per_beat_ils)-CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_price_after_discount'

FROM electricity_cte
GROUP BY  month,
		week_day,
		time_range
ORDER BY DRANK_consumption_price, month


------------------------Plan B Discount Overview-----------------------
-- Timerange: 07:00-17:00
-- Weekdays: Sunday, Monday, Thursday, Wednsday, Tuesday
-- Discount Ratio: 15%


;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATENAME(MONTH,date) AS 'month',
					CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range
	FROM electricity_usage)

SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		DENSE_RANK() OVER(ORDER BY SUM(kwh_consumption) DESC) AS 'DRANK_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_price_after_discount'

FROM electricity_cte
GROUP BY month, week_day, time_range
ORDER BY DRANK_consumption_price, month,time_range



------------------------Plan C Discount Overview-----------------------

-- Timerange:  23:00-07:00
-- Weekdays: Sunday, Monday, Thursday, Wednsday, Tuesday,
-- Discount Ratio: 20%

;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATENAME(MONTH,date) AS 'month',
					CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range	
	FROM electricity_usage)

SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		DENSE_RANK() OVER(ORDER BY SUM(kwh_consumption) DESC) AS 'DRANK_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_price_after_discount'

FROM electricity_cte
GROUP BY month, week_day, time_range
ORDER BY DRANK_consumption_price, month,time_range


-------------- Plan A + B + C Discount Overview ----------------------------------
;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATEPART(DAY,date) AS 'day',
				DATENAME(MONTH,date) AS 'month',
				DATEPART(YEAR,date) AS 'year',
				DATEPART(QUARTER,date) AS 'quarter_date',
				CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range		
	FROM electricity_usage), discount_cte AS

(SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		SUM(price_per_beat_ils)-CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_price_after_discount',
		CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_discount_in_Shekel'


FROM electricity_cte
GROUP BY month, week_day, time_range)

SELECT *
FROM discount_cte


-------------- Yearly A+B+C Discount Overview ----------------------------------


;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATEPART(DAY,date) AS 'day',
				DATENAME(MONTH,date) AS 'month',
				DATEPART(YEAR,date) AS 'year',
				DATEPART(QUARTER,date) AS 'quarter_date',
				CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range		
	FROM electricity_usage), discount_cte AS

(SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		SUM(price_per_beat_ils)-CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_price_after_discount',
		CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_discount_in_Shekel'


FROM electricity_cte
GROUP BY month, week_day, time_range)

SELECT SUM(total_month_price_before_discount) AS total_yearly_with_no_discount,
	   SUM(plan_A_price_after_discount)AS total_yearly_plan_A,
	   SUM(plan_A_discount_in_Shekel) AS total_yearly_discount_plan_A,
	   SUM(plan_B_price_after_discount)AS total_yearly_plan_B,
	   SUM(plan_B_discount_in_Shekel) AS total_yearly_discount_plan_B,
	   SUM(plan_C_price_after_discount) AS total_yearly_plan_C,
	   SUM(plan_C_discount_in_Shekel) AS total_yearly_discount_plan_C

FROM discount_cte

-------------- Monthly A+B+C Discount Overview ----------------------------------

;WITH electricity_cte AS
	(SELECT * ,
				0.5252 AS 'price_per_kWh_ils',
				0.5252 * kwh_consumption AS 'price_per_beat_ils',
				DATENAME(WEEKDAY,date) AS 'week_day',
				DATEPART(DAY,date) AS 'day',
				DATENAME(MONTH,date) AS 'month',
				DATEPART(YEAR,date) AS 'year',
				DATEPART(QUARTER,date) AS 'quarter_date',
				CASE WHEN beat_start_time BETWEEN '07:00:00' AND '16:59:00' THEN '07:00-17:00'
					 WHEN beat_start_time BETWEEN '17:00:00' AND '22:59:00' THEN '17:00-23:00'
					 ELSE '23:00-07:00'
				END AS time_range		
	FROM electricity_usage), discount_cte AS

(SELECT  month,
		week_day,
		time_range,
		SUM(kwh_consumption) AS 'total_month_consumption',
		FORMAT((CAST(SUM(kwh_consumption) AS float)/ SUM(SUM(kwh_consumption)) OVER() *1.0 ),'P') AS 'pct_of_total_consumption_price',
		SUM(price_per_beat_ils) AS 'total_month_price_before_discount',
		SUM(price_per_beat_ils)-CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_price_after_discount',
		CAST(SUM(price_per_beat_ils) AS FLOAT) *0.07 AS 'plan_A_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='07:00-17:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.15
		ELSE 0
		END AS 'plan_B_discount_in_Shekel',

		SUM(price_per_beat_ils)-
		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_price_after_discount',

		CASE WHEN week_day NOT IN ('Friday', 'Saturday')
		AND time_range ='23:00-07:00' THEN CAST(SUM(price_per_beat_ils)AS FLOAT) *0.20
		ELSE 0
		END AS 'plan_C_discount_in_Shekel'


FROM electricity_cte
GROUP BY month, week_day, time_range)

SELECT month,
	   SUM(total_month_price_before_discount) AS total_price,
	   SUM(plan_A_price_after_discount)AS total_price_plan_A,
	   SUM(plan_A_discount_in_Shekel) AS total_discount_plan_A,
	   DENSE_RANK() OVER(ORDER BY  SUM(plan_A_discount_in_Shekel) DESC) AS DRANK_plan_A,
	   SUM(plan_B_price_after_discount)AS total_price_plan_B,
	   SUM(plan_B_discount_in_Shekel) AS total_discount_plan_B,
	   DENSE_RANK() OVER(ORDER BY  SUM(plan_B_discount_in_Shekel) DESC) AS DRANK_plan_B,
	   SUM(plan_C_price_after_discount) AS total_price_plan_C,
	   SUM(plan_C_discount_in_Shekel) AS total_discount_plan_C,
	   DENSE_RANK() OVER(ORDER BY  SUM(plan_C_discount_in_Shekel) DESC) AS DRANK_plan_C

FROM discount_cte
GROUP BY month
