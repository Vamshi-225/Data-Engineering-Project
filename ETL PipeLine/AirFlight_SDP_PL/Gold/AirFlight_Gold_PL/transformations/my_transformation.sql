-- Gold business tables
CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_flights AS
SELECT DATE_TRUNC('MONTH', flight_date) AS flight_month,
       COUNT(*) AS flights,
       SUM(passengers)AS passengers,
       ROUND(SUM(passengers) * 100.0 / SUM(seat_capacity), 1)  AS load_factor_pct,
       SUM(ticket_revenue)AS ticket_revenue,
       SUM(CASE WHEN delay_category <> 'On Time' THEN 1 ELSE 0 END) AS delayed_flights
FROM airflight_silver
GROUP BY DATE_TRUNC('MONTH', flight_date);

/*gold_airline_summary
flights, passengers, ticket_revenue, load_factor_pct, on_time_pct (On Time flights × 100.0 ÷ COUNT(*)), avg_delay_minutes*/
create or refresh materialized view gold_airline_summary
as
select airline,
count(*)as flights,
sum(passengers)as passengers,
sum(ticket_revenue)as ticket_revenue,
round(sum(passengers)*100.0/sum(seat_capacity),1) as load_factor_pct,
round(sum(case when delay_category='On Time' then 1 else 0 end)*100.0/count(*)) as on_time_pct,
avg(case when delay_category='On Time' then 0 else delay_minutes end) as avg_delay_minutes
from airflight_silver
group by airline;

/*gold_route_summary
flights, passengers, ticket_revenue, load_factor_pct*/

create or replace materialized view gold_route_summary
as
select origin_city, 
destination_city,
count(*) as flights,
sum(passengers)as passengers,
sum(ticket_revenue)as ticket_revenue,
sum(passengers)*100/sum(seat_capacity) as load_factor_pct
from airflight_silver
group by origin_city, destination_city;

/*gold_delay_summary
flights, avg_delay_minutes*/

create or replace materialized view gold_delay_summary
as
select delay_category, 
delay_reason,
count(*) as flights,
avg(delay_minutes)as avg_delay_minutes
from airflight_silver
group by delay_category, delay_reason;

 /*Data quality and reconciliation*/
 CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS
SELECT COUNT(*)                                                 AS bronze_rows,
       COUNT(*) - COUNT(DISTINCT flight_id)                     AS duplicate_rows,
       SUM(CASE WHEN passengers > seat_capacity THEN 1 ELSE 0 END) AS overbooked_rows,
       SUM(CASE WHEN airline IS NULL THEN 1 ELSE 0 END)         AS missing_airline_rows,
       -- add negative fare, missing delay, missing revenue, missing reason
       sum(case when avg_fare<0 then 1 else 0 end) as negative_fare,
       sum(case when delay_minutes is null then 1 else 0 end) as missing_delay,
       sum(case when ticket_revenue is null then 1 else 0 end) as missing_revenue,
       sum(case when delay_reason is null then 1 else 0 end) as missing_reason,
       (SELECT COUNT(*) FROM airflight_silver)              AS clean_rows,
       (SELECT COUNT(*) FROM silver_flights_rejected)           AS rejected_rows
FROM airflight_silver;

