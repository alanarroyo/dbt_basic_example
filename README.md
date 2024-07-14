# DBT Tutorial with a Basic example
In this tutorial we will show how to run a dbt data pipeline.  To achieve this we will learn how to bring the [Titanic Datatset](https://www.genome.gov/)
into a DuckDB database. 

## Overview

In a simple data pipeline, data is ingested from a source system into our target system. For this basic example, we will take a csv file with the Titanic Dataset saved in a [GitHub repository](https://github.com/datasciencedojo/datasets/blob/master/titanic.csv) (this our source), read it using DuckDB's `read_csv` function, apply some data transformations and save the result into a Parquet file that can be easily read by DuckDB (our target system).

DuckDB is a Data Base Management System (DBMS) oriented to serve analytic tasks (this is known as OLAP systems). DuckDB was created in 2019 by  Mark Raasveldt and Hannes Mühleisen at the Centrum Wiskunde & Informatica (CWI) in the Netherlands. DuckDB is designed to be simple to use, which is the main reason why we use it for this tutorial. You can find [here](https://duckdb.org/why_duckdb) more information about DuckDB features.

## Required installation

### Install DuckDB

DuckDB will be installed on the command line. For this one can run either of the following two commands:

```
# Windows
winget install DuckDB.cli
```

```
# Mac
brew install duckdb
```

One can test if installation worked by running the following:
```
duckdb
```
If things went ok, then you should see 
```
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
D 
```
in order to exit DuckDB  one can type `.quit` + ENTER and that should bring you back to the terminal.
