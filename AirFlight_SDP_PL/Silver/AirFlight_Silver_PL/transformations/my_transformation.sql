create or replace materialized view airflight_Silver
(
    constraint valid_passenger expect(passengers between 0 and seat_capacity) on violation drop row,
    constraint valid_fare expect(avg_fare>0)
)
as
With Cleaned as (
    select flight_id,
    flight_number,
    seat_capacity,
    avg_fare,
    coalesce(initcap(trim(airline)),'unknown')as airline,
    initcap(trim(origin_city)) as origin_city,
    coalesce(delay_minutes,timestampdiff(minute,scheduled_departure,actual_departure)) as delay_minutes,
    coalesce(ticket_revenue,passengers*avg_fare)as ticket_revenue,
    initcap(trim(destination_city))as destination_city,
    coalesce(initcap(trim(delay_reason)),'Unknown') as delay_reason,
    passengers
from airflight_bronze
)
select *,
case
    when delay_minutes<=15 then 'On Time'
    when delay_minutes<=60 then 'Minor Delay'
    else 'Major Delay' End as delay_category
from cleaned;

CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected AS
SELECT *,
  CASE WHEN passengers > seat_capacity THEN 'Passengers more than seats'
       ELSE 'Average fare is negative' END AS reject_reason
FROM airflight_bronze
WHERE passengers > seat_capacity OR passengers < 0 OR avg_fare < 0;
