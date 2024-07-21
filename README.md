# DBT Tutorial with a basic example
The goal of this tutorial is to learn  how to use dbt (data build tool) to design and run a  basic data  transformation pipeline.  We will extract and transform two columns from the [Titanic Datatset](https://www.kaggle.com/c/titanic/data)
into a DuckDB database. 

## Overview

In simple data pipelines, data is ingested from a source system into our target system. In this tutorial, our source system is the Titanic Dataset saved as a csv in a [github repository](https://github.com/datasciencedojo/datasets/blob/master/titanic.csv), while our target system is a DuckDB database.


DuckDB is an OLAP
Data Base Management System (DBMS) created in 2019 by  Mark Raasveldt and Hannes Mühleisen. Although dbt can work with different kinds of DBMSs and data warehouses on the cloud, we chose DuckDB as it simple and runs locally on any desktop computer. 



Data build tool (dbt) is a framework and command line tool created in 2016 by RJMetrics, enabling the design,  automation, and version control of data transformations. The way dbt works is by using Jinja templating language to allow us building more expressive, and hence less repetitive,  SQL/Python data transformations code. Dbt also allows referencing between different *models* (tables), making data transformations to be modular and cleaner.




## Required installation

### Install DuckDB

DuckDB can be  installed by running one of the two following commands in the terminal:

```bash
# Windows
winget install DuckDB.cli
```

```bash
# Mac
brew install duckdb
```

To open DuckDb, run `duckdb` command. You will see a screen similar to the one below. 
```bash
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
D 
```
Type `.quit` + ENTER  to exit DuckDB.

### Install dbt

Go to your project's folder. Then create a new pip environment as follows. 

```bash
python -m venv venv 
```

Activate this environment by running the next command.
```bash
source venv/bin/activate
```

Once it is activated, run the following to install DuckDB.

```bash
python -m pip install dbt-duckdb
```
Run `dbt --version ` and the are no errors, then you are good to go.

## Running dbt for the first time
Run

```bash
dbt init
```
You will be first be asked to enter a new for your project. Type `dbt_basic_project`.
Then you will be asked which databes would yo like to use. There will be a list of options. Type the number corresponding to DuckDB. 

Once dbt init command runs, it will create a folder called `dbt_basic_project`. The structure of this folder should look like the one shown below:

```bash
.
├── README.md
├── analyses
├── dbt_project.yml
├── macros
├── models
│   └── example
│       ├── my_first_dbt_model.sql
│       ├── my_second_dbt_model.sql
│       └── schema.yml
├── seeds
├── snapshots
└── tests

```

The subfolder `models` will contain our data transformation instructions. Let us replace the `example` folder with an empty folder that will hold our data transfomations on the Titanic Dataset.

```bash
mv models/example models/titanic
rm models/titanic/*.sql
```
 This will be the only folder that we will care about in this tutorial.

In the root folder of the dbt project, create a file called `profiles.yml` and include the following content:

```yaml
# profiles.yaml

dbt_basic_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: '/tmp/titanic.db' #temporary intermediate location used by duckdb
      schema: 'titanic_apps'
```
In general, this `profiles.yml` file includes the necessary information to connect to the target database system. More information about this file can be found [here](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles).

Finally, we will create a new file `sources.yml` within the `models\titanic` folder that will indicate the location of the source data.

```yaml
version: 2 # indicates dbt version

sources: 
  - name: titanic_src
    meta:
      # next line includes duckdb statement to read data
      external_location: '(select * from read_csv("https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv") )'
      formatter: oldstyle
    tables:
      - name: titanic_tbl
```

The external location parameter indicates the duckdb command that will be used to read the data from source. One can indeed test this command by first opening duckdb

```bash
duckdb
```
and then run
```sql
select * from 
read_csv("https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv") 
limit 5;
```

This will show the first  5 records of the Titanic Dataset:
```bash
┌─────────────┬──────────┬────────┬──────────────────────┬─────────┬───┬──────────────────┬─────────┬─────────┬──────────┐
│ PassengerId │ Survived │ Pclass │         Name         │   Sex   │ … │      Ticket      │  Fare   │  Cabin  │ Embarked │
│    int64    │  int64   │ int64  │       varchar        │ varchar │   │     varchar      │ double  │ varchar │ varchar  │
├─────────────┼──────────┼────────┼──────────────────────┼─────────┼───┼──────────────────┼─────────┼─────────┼──────────┤
│           1 │        0 │      3 │ Braund, Mr. Owen H…  │ male    │ … │ A/5 21171        │    7.25 │         │ S        │
│           2 │        1 │      1 │ Cumings, Mrs. John…  │ female  │ … │ PC 17599         │ 71.2833 │ C85     │ C        │
│           3 │        1 │      3 │ Heikkinen, Miss. L…  │ female  │ … │ STON/O2. 3101282 │   7.925 │         │ S        │
│           4 │        1 │      1 │ Futrelle, Mrs. Jac…  │ female  │ … │ 113803           │    53.1 │ C123    │ S        │
│           5 │        0 │      3 │ Allen, Mr. William…  │ male    │ … │ 373450           │    8.05 │         │ S        │
├─────────────┴──────────┴────────┴──────────────────────┴─────────┴───┴──────────────────┴─────────┴─────────┴──────────┤
│ 5 rows                                                                                            12 columns (9 shown) │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Then exit DuckDB by running `.quit`.

## Running our first transformation

Our first transformation will be simply to retain only two columns, `Passenger Id` and `Name`, from our `titanic_source` table and saving this into a table called `titanic_2_cols`. This is done, first by creating  
a new file `titanic_2_cols_trans.sql` within  the `models\titanic` folder:

```sql
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
-- Second block starts
select *
from {{ source('titanic_src', 'titanic_tbl') }} 
```
In the first block of the code above is a special function called by dbt that tells where and how to save the data after the transfomation is applied. The next block is a pure SQL select statement. The selection table is a reference to a source (schema + table) as listed in the `sources.yml` file.

After saving this file, run the following command (assuming that your are located any any subfolder within the project's folder):

```bash
run dbt
```
If things go well,  you will see a message that the process has been completed successfully.

To double check that dbt executed our first transformation model successfully, open the resulting `dev.duckdb` file obtained after the execution by simply changing the location of the terminal to this file location and by running

```bash
duckdb dev.duckdb
```
This will open the DuckDB database where the result of our models will be saved as tables. Run 
```sql
SELECT * from titanic_2_cols_trans
 ```
to verify that the result of your model is available in the database

## Transformation referring to a previous model
In the previous section we saw how to specifify in dbt a transformation starting from an external source. In this section we will see how to do the same but departing from a table that we built in the previous section

We start by creating a new file  `models\titanic\titanic_names.sql` with the following content:
```sql
--# titanic_names.sql
{{ config(
      materialized='external',
      location='output/c.parquet',
      format='parquet')
}}

select 
PassengerId, 
split_part(Name,',', 2) as FirstName,
split_part(Name,',', 2) as LastName,
Name as FullName
from {{ ref("titanic_2_cols_trans") }} 
```
Note how in the last like we use dbt's `ref` function, instead of  `source`, to refer to a alread built mode. Also in the `SELECT` statetments we make use of DuckDB built-in string fuctions to define some of our transformations. 

To materialize this model, we simply execute again `run dbt`. Then a new table `titanic_names` will  be added to our database.

##  Schema and data tests
Although dbt can be seen as a framework to automate data transformation, it should also be seen as a great tool for documenting the lineage of your data, and also it can facilitate the use of automated tests to ensure the quality of your data.  In this section we will learn how to use some of these functionalities.

To do this, we open  `models\titanic\schema.yml` file and replace its content with the following: 

```yaml
# schema.yml
version: 2

models:
  - name: titanic_2_cols_trans
    description: "Only PassengerId and Name columns from Titanic Dataset"
    columns:
      - name: PassengerId
        description: "Primary key for this table"
        data_tests:
          - unique
          - not_null
      - name: Name
        description: "Passenger's full name"
        data_tests:
          - not_null
          
  - name: titanic_names
    description: "Table with passenger names parsed"
    columns:
      - name: PassengerId
        description: "Primary key for this table"
        data_tests: 
          - unique
          - not_null
      - name: FirstName
        description: "Passenger's first name"
        data_tests:
          - not_null
      - name: LastName
        description: "Passenger's last name"
        data_tests:
          - not_null
      - name: FullName
        description: "Passenger's full name"
        data_tests:
          - not_null
```

This file can be used to document the following:
- table and column names;
- descriptions of our data assets; and
- data completeness and quality tests that are appropriate for each column.

We can ask dbt to run the data tests prescribed in `schema.yml` by simply running the following:

```bash
dbt test
```
If all went smoothly, you should log a summary of the tests performed and their results as follows:
```bash
07:10:58  1 of 8 START test not_null_titanic_2_cols_trans_Name ........................... [RUN]
07:10:58  1 of 8 PASS not_null_titanic_2_cols_trans_Name ................................. [PASS in 0.14s]
07:10:58  2 of 8 START test not_null_titanic_2_cols_trans_PassengerId .................... [RUN]
07:10:58  2 of 8 PASS not_null_titanic_2_cols_trans_PassengerId .......................... [PASS in 0.05s]
07:10:58  3 of 8 START test not_null_titanic_names_FirstName ............................. [RUN]
07:10:58  3 of 8 PASS not_null_titanic_names_FirstName ................................... [PASS in 0.06s]
07:10:58  4 of 8 START test not_null_titanic_names_FullName .............................. [RUN]
07:10:59  4 of 8 PASS not_null_titanic_names_FullName .................................... [PASS in 0.23s]
07:10:59  5 of 8 START test not_null_titanic_names_LastName .............................. [RUN]
07:10:59  5 of 8 PASS not_null_titanic_names_LastName .................................... [PASS in 0.10s]
07:10:59  6 of 8 START test not_null_titanic_names_PassengerId ........................... [RUN]
07:10:59  6 of 8 PASS not_null_titanic_names_PassengerId ................................. [PASS in 0.06s]
07:10:59  7 of 8 START test unique_titanic_2_cols_trans_PassengerId ...................... [RUN]
07:10:59  7 of 8 PASS unique_titanic_2_cols_trans_PassengerId ............................ [PASS in 0.07s]
07:10:59  8 of 8 START test unique_titanic_names_PassengerId ............................. [RUN]
07:10:59  8 of 8 PASS unique_titanic_names_PassengerId ................................... [PASS in 0.06s]
07:10:59  
07:10:59  Finished running 8 data tests in 0 hours 0 minutes and 1.14 seconds (1.14s).
```

Tests on specific tables can be performed on specific models by adding the `--select` parameter as shown below:
```bash
dbt test --select "titanic_names"
```

## Concluding remarks

In this tutorial we learned how to build a mock DuckDB database from the Titanic Dataset by using basic functionalities of dbt. The dbt framework brings the power of automation and version control in the context of data transformations. 