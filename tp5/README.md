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
A foreign key constraint specifies that the values in a column (or a group of columns) must match the values appearing in some row of another table. We say this maintains the referential integrity between two related tables.

```SQL
CREATE TABLE products (
    product_no integer PRIMARY KEY,
    name text,
    price numeric
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    shipping_address text,
    ...
);

CREATE TABLE order_items (
    product_no integer REFERENCES products,
    order_id integer REFERENCES orders,
    quantity integer,
    PRIMARY KEY (product_no, order_id)
);
```
A foreign key can also constrain and reference a group of columns. As usual, it then needs to be written in table constraint form. (Of course, the number and type of the constrained columns need to match the number and type of the referenced columns).

```SQL
CREATE TABLE t1 (
  a integer PRIMARY KEY,
  b integer,
  c integer,
  FOREIGN KEY (b, c) REFERENCES other_table (c1, c2)
);
```
self-referential foreign key

```SQL
CREATE TABLE tree (
    node_id integer PRIMARY KEY,
    parent_id integer REFERENCES tree,
    name text,
    ...
);
```

[Constraints](https://www.postgresql.org/docs/16/ddl-constraints.html#DDL-CONSTRAINTS-FK)

<h4>Acciones referenciales: DELETE/UPDATE</h4>

Rechazo de la operación

* **NO ACTION**: prevents deletion/update of a referenced row.
* **RESTRICT**: if any referencing rows still exist when the constraint is checked, an error is raised; this is the default behavior if you do not specify anything.

> The essential difference between these two choices is that NO ACTION allows the check to be deferred until later in the transaction whereas RESTRICT does not.

Acepta op y realiza acciones reparadoras

* **CASCADE**: when a referenced row is deleted/updated, row(s) referencing it should be automatically deleted/updated as well.
* **SET NULL**: These cause the referencing column(s) in the referencing row(s) to be set to nulls or their default values
* **SET DEFAULT**: coloca el valor por defecto en la FK a aquellos registros que referencian a dicha clave primaria.

> [!TIP]
> When the referencing table represents something that is a component of what is represented by the referenced table and cannot exist independently, then CASCADE could be appropriate.

> [!TIP]
> If the two tables represent independent objects, then RESTRICT or NO ACTION is more appropriate.

> [!TIP]
> The actions SET NULL or SET DEFAULT can be appropriate if a foreign-key relationship represents optional information.

```SQL
CREATE TABLE tenants (
    tenant_id integer PRIMARY KEY
);

CREATE TABLE users (
    tenant_id integer REFERENCES tenants ON DELETE CASCADE,
    user_id integer NOT NULL,
    PRIMARY KEY (tenant_id, user_id)
);

CREATE TABLE posts (
    tenant_id integer REFERENCES tenants ON DELETE CASCADE,
    post_id integer NOT NULL,
    author_id integer,
    PRIMARY KEY (tenant_id, post_id),
    FOREIGN KEY (tenant_id, author_id) REFERENCES users ON DELETE SET NULL (author_id)
);
```

<h4>Tipos de matching</h4>

* **Datos válidos en todas las columnas:** Si todas las columnas que forman la clave externa tienen valores no nulos, el DBMS buscará una fila correspondiente en la tabla referenciada.
* **NULL en al menos una columna:** cuando al menos una columna de la clave externa es NULL, se considera que no hay un "match" entre las filas de las tablas relacionadas, lo que permite la operación sin violar la integridad referencial de la base de datos.
* **Todos los valores NULL:** Si todas las columnas de la clave externa son NULL, también se permitirá la operación por la misma razón mencionada anteriormente.

<table>
    <thead>
        <tr>
            <th>Casos</th>
            <th>Match Simple</th>
            <th>Match Full</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>Datos válidos en todas las columnas</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>NULL en al menos una columna</th>
            <th>:heavy_check_mark:</th>
            <th>:x:</th>
        </tr>
        <tr>
            <th>Todos los valores NULL</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
    </tbody>
</table>

> [!CAUTION]
> MATCH PARTIAL is not yet implemented.

```SQL
CREATE TABLE NombreTabla ( ...
    [ [CONSTRAINT FK_nom] FOREIGN KEY (lista_columnasFK)
    REFERENCES nombreTablaRef [(lista_columnasRef)]
    [ MATCH {FULL | PARTIAL | SIMPLE}]
    [ON UPDATE AccionRef]
    [ON DELETE AccionRef] ] ...
);
```
[Crate-Table(PostgreSQL16)](https://www.postgresql.org/docs/16/sql-createtable.html)