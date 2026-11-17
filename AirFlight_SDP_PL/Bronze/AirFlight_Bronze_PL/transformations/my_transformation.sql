create or refresh streaming table AirFlight_Bronze
as
select *,
_metadata.file_path  as Source_path,
current_timestamp() as IngestionTime
from 
stream read_files('/Volumes/airline_flight_operations_catalog/default/airflight_volume',format=>'CSV',header=>'true');