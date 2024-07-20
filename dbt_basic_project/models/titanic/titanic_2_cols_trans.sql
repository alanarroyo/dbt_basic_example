-- #models\titanic\titanic_2_cols_trans.sql

-- First  block starts --
{{ config(
      materialized='external',
      location='output/titanic_2_cols.parquet',
      format='parquet')
}}

-- Second block starts part is duckDB SQL code indicating the transformations, selecting data from source as indicated in sources.yml
select *
from {{ source('titanic_src', 'titanic_tbl') }} 