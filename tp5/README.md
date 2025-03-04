# Contenido
* [Restricciones de Integridad (RI)](#restricciones-de-integridad-ri)
    * [Restricciones de Integridad Básicas](#restricciones-de-integridad-básicas)
        * [UNIQUE](#unique)
        * [NOT NULL](#not)
        * [PRIMARY KEY](#primary-key)
        * [FOREIGN KEY](#foreign-key)
            * [Acciones Referenciales :arrow_right: DELETE/UPDATE](#foreign-key-acciones-referenciales-arrow_right-deleteupdate)
            * [Tipos de Matching](#tipos-de-matching)
    * [Otras Restricciones de Integridad en SQL](#otras-restricciones-de-integridad-en-sql)
        * [DOMAIN o CHECK de atributo](#domain-o-check-de-atributo)
        * [CHECK DE REGISTRO](#check-de-registro)
        * [CHECK DE TABLA](#check-de-tabla)
        * [ASSERTION](#assertion)

# Restricciones de Integridad (RI)

Reglas definidas en la BD para garantizar que cualquier modificación realizada por los usuarios no provoquen la pérdida de la consistencia de los datos.

¿Cómo funciona?

1. **DBA (DataBase Administrator): especifica las RI sobre los datos.**
    * Código en las aplicaciones que acceden a los datos.
    * restricciones (reglas o chequeos).
2. **SGBD: evita actualizaciones en los datos que no cumplan las RI.**
    * Rechazando la operación (insert, delete, update).
    * Realizando acciones reparadoras extras.

## Restricciones de Integridad Básicas

### UNIQUE

Specifies that a group of one or more columns of a table can contain only unique values

```SQL
CREATE TABLE [IF NOT EXISTS] products (
    product_no integer,
    name text,
    price numeric,
    [CONSTRAINT UK_nom] UNIQUE (product_no)
);
``` 
```SQL
ALTER TABLE products 
ADD CONSTRAINT UK_nom UNIQUE (product_no);
```

### NOT NULL

The column is not allowed to contain null values.

```SQL
CREATE TABLE [IF NOT EXISTS] products (
    product_no integer [NOT NULL],
    name text [NOT NULL],
    price numeric
);
```
```SQL
ALTER TABLE products 
ALTER COLUMN product_no SET NOT NULL;

ALTER TABLE products 
ALTER COLUMN name SET NOT NULL;
```

> [!NOTE]
> Si la tabla products ya contiene valores NULL en las columnas product_no o name, el comando ALTER COLUMN ... SET NOT NULL fallará.
> Pasos para solucionarlo: 
> 1. Reemplazar los valores NULL con valores por defecto.
> 2. Luego, aplicar la restricción NOT NULL.
> ```SQL
> -- Reemplazar NULLs en product_no (suponiendo que 0 no es un valor válido en uso)
> UPDATE products SET product_no = 0 WHERE product_no IS NULL;
> 
> -- Reemplazar NULLs en name (suponiendo que 'Desconocido' es un valor válido)
> UPDATE products SET name = 'Desconocido' WHERE name IS NULL;
> 
> -- Ahora sí podemos aplicar la restricción NOT NULL
> ALTER TABLE products 
> ALTER COLUMN product_no SET NOT NULL;
> 
> ALTER TABLE products 
> ALTER COLUMN name SET NOT NULL;
> ```

### PRIMARY KEY

It indicates that a column, or group of columns, can be used as a unique identifier for rows in the table. This requires that the values be both unique and not null.

```SQL
CREATE TABLE [IF NOT EXISTS] example (
    a integer,
    b integer,
    c integer,
    [CONSTRAINT PK_example] PRIMARY KEY (a, c)
);
```
```SQL
ALTER TABLE [IF EXISTS] table
ADD [CONSTRAINT PK_nom] PRIMARY KEY (a, b);
```
> [!IMPORTANT]
> No se puede agregar una clave primaria a una tabla que ya tiene otra clave primaria.
> 
> **Posible solución**: eliminar la clave existente, luego cambiar la pk.
> ```SQL
> ALTER TABLE example 
> DROP CONSTRAINT PK_example;
> 
> ALTER TABLE example
> ADD CONSTRAINT PK_nom PRIMARY KEY (a, b);
> ```

### FOREIGN KEY

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

A foreign key can also constrain and reference a group of columns.

```SQL
CREATE TABLE t1 (
    a integer PRIMARY KEY,
    b integer,
    c integer,
    FOREIGN KEY (b, c) REFERENCES other_table (c1, c2)
);
```

Self-referential foreign key

```SQL
CREATE TABLE tree (
    node_id integer PRIMARY KEY,
    parent_id integer REFERENCES tree,
    name text,
    ...
);
```

Acciones Referenciales :arrow_right: DELETE/UPDATE

¿Qué sucede cuando se intenta eliminar/modificar un registro de la tabla A que está siendo referenciada en la tabla B por la FK?

**Opción 1: Rechazo de la operación**
* **NO ACTION**: prevents deletion/update of a referenced row.
* **RESTRICT (DEFAULT)**: if any referencing rows still exist when the constraint is checked, an error is raised; this is the default behavior if you do not specify anything.

> The essential difference between these two choices is that NO ACTION allows the check to be deferred until later in the transaction whereas RESTRICT does not.

**Opción 2: Acepta la operación y realiza acciones reparadoras**
* **CASCADE**: when a referenced row is deleted/updated, row(s) referencing it should be automatically deleted/updated as well.
* **SET NULL**: these cause the referencing column(s) in the referencing row(s) to be set to nulls.
* **SET DEFAULT**: coloca un valor por defecto a aquellos registros que referencian a dicha clave primaria.

```SQL
CREATE TABLE tenants (
    tenant_id integer PRIMARY KEY
);

CREATE TABLE users (
    PRIMARY KEY (tenant_id, user_id)
    user_id integer NOT NULL,
    tenant_id integer REFERENCES tenants,
    ON DELETE CASCADE
);

CREATE TABLE posts (
    PRIMARY KEY (tenant_id, post_id),
    post_id integer NOT NULL,
    author_id integer,
    tenant_id integer REFERENCES tenants 
    ON DELETE CASCADE,
    FOREIGN KEY (tenant_id, author_id) REFERENCES users 
    ON DELETE SET NULL (author_id)
);
```

#### Tipos de Matching

Los tipos de matching afectan cuando las FK se definen sobre varios atributos, y pueden contener valores nulos.

La integridad referencial se satisface si para cada registro en la tabla referenciante se verifica lo siguiente:

1. **Ninguno de los valores de las columnas de la FK es NULL y existe un registro en la tabla referenciada cuyos valores de la clave coinciden con los de tales columnas.**

2. o
* **MATCH SIMPLE** (DEFAULT): allows any of the foreign key columns to be null; if any of them are null, the row is not required to have a match in the referenced table.
* **MATCH FULL**: will not allow one column of a multicolumn foreign key to be null unless all foreign key columns are null; if they are all null, the row is not required to have a match in the referenced table.
* **MATCH PARTIAL**: is not yet implemented (on PostgreSQL).

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

## Otras Restricciones de Integridad en SQL

### DOMAIN o CHECK de atributo

Permiten definir el conjunto de los valores válidos de un atributo.

* Casos particulares: NOT NULL, DEFAULT, PRIMARY KEY, UNIQUE
* Se pueden especificar las RI del atributo en la sentencia CREATE TABLE o definirlas en un dominio y declarar el atributo perteneciente al dominio.

```SQL
CREATE DOMAIN NomDominio
AS TipoDato [ DEFAULT ValorDefecto ]
[ [CONSTRAINT NomRestriccion] CHECK (condición) ];  -- La condición debe evaluar como V o F
```

Pueden plantearse distinto tipo de condiciones:

* **Comparación simple:** operadores (=,<,>,<=,>=,<>) Ej:Sueldo > 0
* **Rango:** [NOT] BETWEEN (incluye extremos) Ej: nota BETWEEN 0 AND 10
* **Pertenencia:** [NOT] IN Ej: Area IN (‘Académica’, ‘Posgrado’, ‘Extensión’)
* **Semejanza de Patrones:** [NOT] LIKE % (para 0 o más caracteres) Ej: LIKE ‘s%’ - (para un carácter simple) Ej: LIKE ‘s_’

A su vez, las condiciones pueden ser:

* **Negadas:** IS [NOT] NULL
* **Concatenadas:** utilizando AND, OR

**`Ejemplo 1`**

```SQL
-- No se permite edad menor a 18
CREATE TABLE Empleados (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Edad INT CONSTRAINT chk_edad CHECK (Edad >= 18)
);
```
```SQL
-- No se permite edad menor a 18
CREATE DOMAIN EdadValida 
AS INT
CONSTRAINT chk_edad CHECK (VALUE >= 18);
```

**`Ejemplo 2`**

```SQL
-- Las especialidades de los ingenieros pueden ser "inteligencia empresarial" , "tecnologias móviles" , "gestión de TI" o "desarrollo"
CREATE DOMAIN especialidad 
AS varchar(20)
CHECK( VALUE IN (‘inteligencia empresarial’ , ‘tecnologias móviles’ , ‘gestión de TI’, ‘desarrollo’));
```

### CHECK DE REGISTRO

Aplica restricciones que involucran uno o más atributos dentro de una misma fila.

```SQL
CREATE TABLE NombreTabla
[[CONSTRAINT nom_restr] CHECK (condición) ];    -- La condición debe evaluar como V o Desconocida
```
```SQL
ALTER TABLE NombreTabla
ADD [CONSTRAINT nom_restr] CHECK (condición);   -- La condición debe evaluar como V o Desconocida
```

**`Ejemplo 1`**

```SQL
-- El descuento no puede ser mayor que el precio
CREATE TABLE Productos (
    ID INT PRIMARY KEY,
    Precio DECIMAL(10,2),
    Descuento DECIMAL(10,2),
    CHECK (Descuento <= Precio)
);
```
**`Ejemplo 2`**

```SQL
-- Los tipos de areas BC sólo pueden tener id_areas que van del 3 al 7 para el resto no habría controles.
ALTER TABLE AREA
ADD CONSTRAINT ck_control_area
CHECK (( (tipo_area = ‘BC’) AND (id_area BETWEEN (3 AND 7) ) OR tipo_area <> ‘BC’));
```

**`Ejemplo 3`**

```SQL
-- No puede haber más de 30 empleados por área.
ALTER TABLE Empleado
ADD CONSTRAINT ck_area_max
CHECK (NOT EXISTS(
    SELECT 1
    FROM Empleado
    GROUP BY tipo_area, id_area
    HAVING count(*) > 30
));
```

**`Ejemplo 4`**

```SQL
-- Los proyectos sin fecha de finalización asignada no deben superar $100000 de presupuesto.
ALTER TABLE EJ_PROYECTO
ADD CONSTRAINT ck_proyectosenfecha
CHECK ((fecha_fin IS NULL AND presupuesto < 100000) OR (fecha_fin IS NOT NULL));
```

### CHECK DE TABLA

Aplica restricciones que involucran múltiples filas de la misma tabla.

> [!CAUTION]
> En SQL estándar, CHECK no puede referenciar otras filas de la misma tabla, por lo que en la práctica, estas restricciones se implementan mediante TRIGGERS o procedimientos almacenados.

**`Ejemplo 1`**

```SQL
-- En cada proyecto pueden trabajar 10 ingenieros como máximo
ALTER TABLE EJ_TRABAJA
ADD CONSTRAINT ck_cant_ingenieros
CHECK (NOT EXIST (
    SELECT 1
    FROM EJ_TRABAJA
    GROUP BY id_sector, nro_proyecto
    HAVING COUNT(*) > 10
));
```

### ASSERTION

Permiten definir restricciones sobre un número arbitrario de atributos de un número arbitrario de tablas.

> [!CAUTION]
> ASSERTION es un concepto teórico, pero no está implementado en la mayoría de los motores de bases de datos SQL estándar. En su lugar, se suelen usar TRIGGERS o procedimientos almacenados.

```SQL
CREATE ASSERTION NomAssertion CHECK (condición);    -- La condición debe evaluar como V o Desconocida
```

**`Ejemplo 1`**

```SQL
-- El director asignado a un proyecto debe haber trabajado al menos en 5 proyectos.
CREATE ASSERTION CK_PROY_DIRE
    CHECK (NOT EXISTS(
        SELECT P.director, COUNT(*) AS "cantidad proyectos"
        FROM EJ_PROYECTO P 
        JOIN EJ_TRABAJA T ON (P.director = T.id_ingeniero)
        JOIN EJ_PROYECTO PP ON (PP.id_sector = T.id_sector AND PP.nro_proyecto = T.nro_proyecto)
        WHERE PP.fecha_fin IS NOT NULL
        GROUP BY P.director
        HAVING COUNT(*) < 5
    ));
```

> [!IMPORTANT]
> SQL no proporciona un mecanismo para expresar la condición «para todo X, P(X)» (P=predicado) → se debe utilizar su equivalente «no existe X tal que no P(X)»