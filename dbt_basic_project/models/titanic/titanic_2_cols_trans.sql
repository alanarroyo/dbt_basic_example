
-- First part tells dbt where and how to save the target data
{{ config(
    materialized='external',
    location='output/titanic_2_cols.parquet',
    format='parquet'
)}}--#1

-- Second part is duckDB SQL code indicating the transformations
select *
from {{ source('titanic_src', 'titanic_tbl') }}