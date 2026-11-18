#  Airline Flight Operations Analytics Platform
Air Flight Operations – Databricks Lakeflow SDP Pipeline
Project Overview
This project implements an end-to-end data engineering pipeline for airline flight operations using Databricks SQL and Lakeflow Spark Declarative Pipelines (SDP). It follows the Medallion Architecture to ingest raw flight data, clean and validate it, and create business-ready summary tables.

The pipeline is organized into three layers:

Bronze: Ingests raw flight CSV files from a Unity Catalog Volume.
Silver: Cleans and standardizes flight records, derives delay categories, and identifies rejected records.
Gold: Produces aggregated datasets for monthly performance, airline performance, route performance, delay analysis, and data quality monitoring.
# Architecture
CSV files
   | 
   v
Unity Catalog Volume
   |
   v
   
BRONZE – AirFlight_Bronze

   |  Raw records + source file path + ingestion timestamp
   
   v
   
SILVER – airflight_Silver

   |  Standardization, null handling, derived fields,
   
   |  data quality expectations
   
   |
   
   +----> silver_flights_rejected
   
   |
   
   v
   
GOLD – Business and quality summaries

        ├── gold_monthly_flights
        
        ├── gold_airline_summary
        
        ├── gold_route_summary
        
        ├── gold_delay_summary
        
        └── gold_data_quality
  
# Repository Structure

AirFlight_SDP_PL/
│

├── transformations/

│   └── my_transformation.py

│

├── Bronze/

│   └── AirFlight_Bronze_PL/

│       └── transformations/

│           └── my_transformation.sql

│

├── Silver/

│   └── AirFlight_Silver_PL/

│       └── transformations/

│           └── my_transformation.sql

│
├── Gold/

│   └── AirFlight_Gold_PL/

│       └── transformations/

│           └── my_transformation.sql

│
└── manifest.mf
Pipeline Layers
1. Bronze Layer – Data Ingestion
Target: AirFlight_Bronze

The Bronze layer reads CSV files from the Unity Catalog Volume using read_files in streaming mode.

# Key operations:

Reads incoming CSV files with headers.
Uses streaming ingestion.
Captures the source file path using _metadata.file_path.
Adds an ingestion timestamp using current_timestamp().
The source configured in the SQL file is:

/Volumes/airline_flight_operations_catalog/default/airflight_volume
# 2. Silver Layer – Data Cleaning and Validation
Target: airflight_Silver

The Silver layer transforms Bronze records into standardized flight data.

# Key transformations:

Trims whitespace and standardizes airline and city names using TRIM and INITCAP.

Replaces missing airline and delay-reason values with default labels.

Calculates missing delay minutes using the difference between actual and scheduled departure timestamps.

Calculates missing ticket revenue using passengers multiplied by average fare.

**Derives a delay_category:**
On Time: delay is 15 minutes or less.

Minor Delay: delay is greater than 15 and up to 60 minutes.

Major Delay: delay is greater than 60 minutes.

Defines data quality expectations for passenger capacity and average fare.

The project also creates silver_flights_rejected to identify records that meet the rejection conditions in its SQL query, including invalid passenger counts and negative average fares.

# 3. Gold Layer – Business Aggregations
The Gold layer creates materialized views for reporting and analysis.

Table / View	Purpose

gold_monthly_flights	Monthly flight count, passengers, load factor, ticket revenue, and delayed flights.

gold_airline_summary	Airline-level flights, passengers, revenue, load factor, on-time percentage, and average delay.

gold_route_summary	Origin-to-destination route performance, passenger count, revenue, and load factor.

gold_delay_summary	Flight counts and average delay grouped by delay category and reason.

gold_data_quality	Quality metrics, clean-row count, and rejected-row count.

# Data Quality Checks
The project includes checks and metrics for:

**Passenger count exceeding seat capacity.**
Duplicate flight IDs.

Missing airline values.

Negative average fares.

Missing delay minutes.

Missing ticket revenue.

Missing delay reasons.

Clean and rejected record counts.

The Silver layer defines expectations for passenger capacity and positive average fare. The Gold gold_data_quality view aggregates quality metrics for monitoring.

# Technologies Used
Databricks,
Lakeflow Spark Declarative Pipelines (SDP),
Databricks SQL,
Unity Catalog,
Streaming Tables,
Materialized Views,
Medallion Architecture,
SQL.

# Setup and Execution
Prerequisites

Access to a Databricks workspace.

Permission to create or manage the required pipeline objects.

A Unity Catalog catalog and schema.

Flight operations CSV files uploaded to the configured Volume.

Access to the source Volume path used in the Bronze SQL transformation.

Steps

Upload the flight CSV files to the configured Unity Catalog Volume:

/Volumes/airline_flight_operations_catalog/default/airflight_volume
Import or add the project SQL transformation files to the corresponding Bronze, Silver, and Gold pipeline definitions in Databricks.

Confirm that the catalog, schema, Volume path, and source column names match your environment and input data.

Configure the pipeline dependencies so that the Bronze ingestion runs before Silver transformations, and Silver runs before Gold aggregations.

Validate the SQL transformations and run the pipeline.

Query the Gold views to analyze flight operations and data quality.

Note: The repository contains transformation files and a manifest. Workspace permissions, source data, catalog objects, and pipeline configuration may need to be set up separately before execution.

# Example Gold-Layer Queries

**-- Monthly flight performance**

SELECT *
FROM gold_monthly_flights
ORDER BY flight_month;

**-- Airline performance**

SELECT *
FROM gold_airline_summary
ORDER BY flights DESC;

**-- Top routes by passenger volume**

SELECT *
FROM gold_route_summary
ORDER BY passengers DESC;

**-- Delay analysis**
SELECT *
FROM gold_delay_summary
ORDER BY flights DESC;

**-- Data quality overview**
SELECT *
FROM gold_data_quality;
# Business Outcomes
**This pipeline helps analyze:**

Monthly airline operational performance.

Airline-wise passenger and revenue contribution.

Popular routes based on passenger volume.

Flight delays and their reported reasons.

Passenger capacity utilization.

Data quality issues and rejected records.

# Future Enhancements
Add incremental data quality monitoring and alerting.

Add more validation rules for nulls, negative values, and invalid timestamps.

Add pipeline monitoring and failure notifications.

Connect Gold views to Databricks AI/BI Dashboards.

Add more business metrics, such as cancellation rate and route-wise on-time performance, when the required source fields are available.

Author

Kuchani Vamshi

This README documents the transformations present in the supplied project archive. Update the source Volume path, catalog/schema names, and setup steps if your Databricks workspace uses different configurations.




