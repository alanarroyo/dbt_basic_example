-- #models\titanic\titanic_2_cols_trans.sql

-- First  block starts --
{{ config(
      materialized='external',
      location='output/titanic_2_cols.parquet',
      format='parquet')
}}

-- Second block starts
select PassengerId, Name
from {{ source('titanic_src', 'titanic_tbl') }} 