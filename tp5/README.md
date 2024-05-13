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
* **SET DEFAULT**: coloca un valor por defecto a aquellos registros que referencian a dicha clave primaria.

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

<h4>Otras RI en SQL</h4>

1. **CHECK**

It allows you to specify that the value in a certain column must satisfy a Boolean (truth-value) expression. Expressions evaluating to TRUE or UNKNOWN succeed.

Pueden plantearse distintos tipos de condiciones:

* **Comparación simple:** operadores (=,<,>,<=,>=,<>) Ej:Sueldo > 0
* **Rango:** [NOT] BETWEEN (incluye extremos) Ej: nota BETWEEN 0 AND 10
* **Pertenencia:** [NOT] IN Ej: Area IN (‘Académica’, ‘Posgrado’, ‘Extensión’)
* **Semejanza de Patrones:** [NOT] LIKE % (para 0 o más caracteres) Ej: LIKE ‘s%’ - (para un carácter simple) Ej: LIKE ‘s_’

> [!IMPORTANT]
> Currently, CHECK expressions cannot contain subqueries nor refer to variables other than VALUE.

<table>
    <thead>
        <tr>
            <th></th>
            <th>CHECK de tupla</th>
            <th>CHECK de tabla</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Una fila específica viola una condición</td>
            <td>Solo esa operación de inserción o actualización es rechazada, y las demás filas que cumplen con la condición se insertan o actualizan sin problemas.</td>
            <td>Se rechaza la operación completa de inserción o actualización, y ninguna fila se modifica en la tabla.</td>
        </tr>
        <tr>
            <td>Ámbito de la restricción</td>
            <td>Tupla</td>
            <td>Tabla</td>
        </tr>
        <tr>
            <td>Ejemplo</td>
            <td><pre lang="sql">
ALTER TABLE AREA
    ADD CONSTRAINT ck_control_area
    CHECK ( ( (tipo_area = ‘BC’) 
    AND (id_area BETWEEN (3 AND 7) ) 
    OR
    tipo_area <> ‘BC’) );
            </pre></td>
            <td><pre lang="sql">
ALTER TABLE Empleado
    ADD CONSTRAINT ck_area_max
    CHECK ( NOT EXISTS (SELECT 1
                        FROM Empleado
                        GROUP BY tipo_area, id_area
                        HAVING count(*) > 30));
            </pre></td>
        </tr>
    </tbody>
</table>

> [!CAUTION]
> La gran mayoría de los DBMS comerciales no soportan los check de tabla!

2. **Dominio**

Domains are useful for abstracting common constraints on fields into a single location for maintenance. For example, several tables might contain email address columns, all requiring the same CHECK constraint to verify the address syntax. Define a domain rather than setting up each table's constraint individually.

    * Casos particulares: NOT NULL, DEFAULT, PRIMARY KEY, UNIQUE.
    * Ámbito de la restricción: atributo.

```SQL
CREATE DOMAIN NomDominio
AS TipoDato [ DEFAULT ValorDefecto ]
[CONSTRAINT NomRestriccion] CHECK (condición);
```

> [!NOTE]
> When a domain has multiple CHECK constraints, they will be tested in alphabetical order by name.

3. **ASSERTIONS (RI globales)**

Una "assertion" puede aplicarse a un conjunto arbitrario de atributos o incluso a múltiples tablas. Su activación ocurre cuando se realizan operaciones de actualización en las tablas involucradas en la definición de la "assertion". Si la afirmación resulta ser falsa, el programa puede generar una advertencia, error o realizar alguna acción definida por el programador para manejar la situación.

```SQL
CREATE ASSERTION salario_valido
    CHECK ( NOT EXISTS ( SELECT 1 FROM Empleado E, Empleado G, Area A
    WHERE E.sueldo > G.sueldo
    AND E.AreaT = A.IdArea
    AND G.IdE = A.gerente ) );
```

> [!IMPORTANT]
> SQL no proporciona un mecanismo para expresar la condición «para todo X, P(X)»
> (P=predicado) → se debe utilizar su equivalente «no existe X tal que no P(X)»
> **Ejemplo:** Supongamos que tenemos una tabla llamada "empleados", y queremos asegurarnos de que ningún empleado tenga un salario inferior a \$2000 (es decir, que "todos los empleados tienen un salario superior a \$2000"). Podríamos expresar esto usando la afirmación "no existe un empleado cuyo salario sea inferior a \$2000".

```SQL
CREATE ASSERTION salario_minimo
CHECK (NOT EXISTS(
    SELECT 1 FROM empleados
    WHERE salario < 2000
));
```

> [!CAUTION]
> Los DBMS comerciales no soportan ASSERTIONS!