# DBT Tutorial with a basic example
In this tutorial we will show how to run a dbt data pipeline.  To achieve this we will learn how to bring the [Titanic Datatset](https://www.genome.gov/)
into a DuckDB database. 

## Overview

In a simple data pipeline, data is ingested from a source system into our target system. For this basic example, we will take a csv file with the Titanic Dataset saved in a [GitHub repository](https://github.com/datasciencedojo/datasets/blob/master/titanic.csv) (this our source), read it using DuckDB's `read_csv` function, apply some data transformations as specified in our dbt files, 
and then save the result into a Parquet file that can be easily read by DuckDB (our target system).

DuckDB is a Data Base Management System (DBMS) oriented to serve analytic tasks (this is known as OLAP systems). DuckDB was created in 2019 by  Mark Raasveldt and Hannes Mühleisen at the Centrum Wiskunde & Informatica (CWI) in the Netherlands. DuckDB is designed to be simple to use, which is the main reason why we use it for this tutorial. You can find [here](https://duckdb.org/why_duckdb) more information about DuckDB features.

Data build tool (dbt) is a framework and command like tool invented in 2016 that allows having version control in data transformations specified in SQL and in Python.

## Required installation

### Install DuckDB

DuckDB is  installed by running one of following two commands ini the command line:

```bash
# Windows
winget install DuckDB.cli
```

```bash
# Mac
brew install duckdb
```

One can test if installation worked by running the following:
```bash
duckdb
```
If things got installed correctly, then you should see 
```bash
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
D 
```
In order to exit DuckDB  one can type `.quit` + ENTER and that should bring you back to the terminal.

### Install dbt

Assuming that your command line is situated in your project's folder, let us first start by creating a pip environment for this tutorial. 

```bash
python -m venv venv 
```

To activate this virtual environment, we run  
```bash
source venv/bin/activate
```

Once the virtual environment is activated, run 

```bash
python -m pip install dbt-duckdb
```
To check that dbt got installed correctly, run `dbt --version ` and if no errors are shown then you are good to go.

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
  - name: titanic_src # reference name for schema keeping csv table
    meta: 
      external_location: 'from read_csv("https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv")'
    tables:
      - name: titanic_tbl # reference name for the csv table 
```

The external location parameter indicates the duckdb command that will be used to read the data from source. One can indeed test this command by first opening duckdb

```bash
duckdb
```
and then run
```sql
from read_csv("https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv") 
select *
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
a new file `titanic_2_cols_trans.sql` within  the `models\titanic` folder
