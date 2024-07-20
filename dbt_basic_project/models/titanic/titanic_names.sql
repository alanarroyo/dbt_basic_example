{{ config(
      materialized='external',
      location='output/titanic_names.parquet',
      format='parquet')
}}

select 
PassengerId, 
split_part(Name,',', 2) as FirstName,
split_part(Name,',', 2) as LastName,
Name as FullName
from  {{ ref("titanic_2_cols_trans") }} 