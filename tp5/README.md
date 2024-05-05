<h1>Restricciones de Integridad (RI)</h1>
Aseguran que las modificaciones hechas a la base de datos por los usuarios autorizados no provoquen la pérdida de la consistencia de los datos. Ejemplos:

* Los nombres y apellidos de los voluntarios no pueden ser nulos.
* Un voluntario no puede aportar más de 10 horas semanales.
* Un voluntario puede cambiar de tarea o de institución solamente dos veces al año.

<h4>Unique Constraints </h4>
Ensure that the data contained in a column is unique among all the rows in the table.

```SQL
CREATE TABLE [IF NOT EXISTS] products (
    product_no integer,
    name text,
    price numeric,
    [CONSTRAINT UK_nom] UNIQUE (product_no)
);
```

<h4>Not Null Constraints</h4>
A not-null constraint simply specifies that a column must not assume the null value.

```SQL
CREATE TABLE [IF NOT EXISTS] products (
    product_no integer [NOT NULL],
    name text [NOT NULL],
    price numeric
);
```

<h4>Primary Keys</h4>
A primary key constraint indicates that a column, or group of columns, can be used as a unique identifier for rows in the table. This requires that the values be both unique and not null.

```SQL
CREATE TABLE [IF NOT EXISTS] products (
    product_no integer [CONSTRAINT PK_products] PRIMARY KEY,
    name text,
    price numeric
);

ALTER TABLE [IF EXISTS] table
ADD [CONSTRAINT PK_nom] PRIMARY KEY (product_no);
```

Primary keys can span more than one column:

```SQL
CREATE TABLE [IF NOT EXISTS] example (
    a integer,
    b integer,
    c integer,
    [CONSTRAINT PK_example] PRIMARY KEY (a, c)
);
```
[Alter-Table(PostgreSQL16](https://www.postgresql.org/docs/16/sql-altertable.html)

<h4>Foreign Keys</h4>

[Constraints](https://www.postgresql.org/docs/16/ddl-constraints.html#DDL-CONSTRAINTS-FK)

<h4>Acciones referenciales: DELETE/UPDATE</h4>

Rechazo de la operación

* **NO ACTION**: no permite borrar/modificar un registro cuya clave primaria está siendo referenciada.
* **RESTRICT**: misma semántica que NO ACTION, pero se chequea antes de las otras RI.

Acepta op y realiza acciones reparadoras

* **CASCADE**: se propaga el borrado/ la modificación a todos los registros que referencian a dicha clave primaria.
* **SET NULL**: coloca nulos en la FK de aquellos registros que referencian a dicha clave primaria.
* **SET DEFAULT**: coloca el valor por defecto en la FK a aquellos registros que referencian a dicha clave primaria.

<h4>Tipos de matching</h4>

* **MATCH FULL**: will not allow one column of a multicolumn foreign key to be null unless all foreign key columns are null; if they are all null, the row is not required to have a match in the referenced table.

* **MATCH SIMPLE**: allows any of the foreign key columns to be null; if any of them are null, the row is not required to have a match in the referenced table.

* **MATCH PARTIAL**: no implementando. (Todos los que no sean NULL deben hacer referencia a algo que exista)

[Crate-Table(PostgreSQL16)](https://www.postgresql.org/docs/16/sql-createtable.html)

```SQL
CREATE TABLE NombreTabla ( ...
    [ [CONSTRAINT FK_nom] FOREIGN KEY (lista_columnasFK)
    REFERENCES nombreTablaRef [(lista_columnasRef)]
    [ MATCH {FULL | PARTIAL | SIMPLE}]
    [ON UPDATE AccionRef]
    [ON DELETE AccionRef] ] ...
);
```