<h1>TRIGGERS (disparadores)</h1>

* Posibilitan definir y forzar reglas de integridad, pero NO son una restricción de integridad. Siendo una herramienta útil para escribir assertions, restricciones complejas, acciones específicas de reparación, etc.
* Permiten especificar acciones automáticas que debe realizar el DMS cuando ocurran ciertos eventos y condiciones. 

```SQL
CREATE TRIGGER nombre 
{BEFORE | AFTER} {evento [OR ... ]} ON tabla      -- Evento
[ FOR [EACH] { ROW | STATEMENT }]                 -- Granularidad
[ WHEN (condición) ]                              -- Condición
EXECUTE PROCEDURE función_específica();           -- Acción
```

> [!IMPORTANT]
> * Un trigger definido para forzar una RI no verifica su cumplimiento para los datos ya almacenados en la BD (una RI declarativa verifica la carga existente en la BD).
> * Los triggers deberian usarse sólo cuando una RI no puede ser expresada mediante una cláusula declarativa.

<h4>Evento</h4>
Operaciones que generán cambios sobre la DB y que activan un trigger

* **INSERT**: no se especifican columnas ya que la operación se aplica a toda la fila que se está insertando.
* **UPDATE**: se pueden especificar columnas para limitar el trigger a ejecutarse solo cuando las mismas se actualicen.
* **DELETE**: no se especifican columnas ya que la operación elimina toda la fila.

<h4>Tiempo de activación del trigger</h4>

* **BEFORE**: se ejecuta antes de que la operación se aplique a la base de datos. Casos de uso:
    * Validar datos antes de que se inserten o actualicen.
    * Modificar los valores de los datos antes de que se realice la operación.
    * Prevenir una operación mediante el lanzamiento de una excepción o error.

* **AFTER**: se ejecuta después de que la operación se ha completado y los cambios se han aplicado. Usos comunes:
    * Registrar auditorías o logs de las operaciones realizadas.
    * Realizar acciones dependientes de que la operación haya sido exitosa.
    * Actualizar o sincronizar datos en otras tablas en respuesta a la operación completada.

<h4>Granularidad</h4>
Nivel en el que se activa el trigger

* **FOR EACH ROW**: se ejecuta una vez por cada fila afectada.
* **FOR EACH STATEMENT**: se ejecuta una sola vez cuando se realiza una operación en una tabla, sin importar cuántas filas sean afectadas por esa operación.

> [!NOTE]
> Por defecto --> FOR EACH STATEMENT.

<h4>Condición</h4>
Condición por la que una RI es incumplida

```SQL
CREATE TRIGGER sueldo_no_se_reduce
    BEFORE UPDATE OF sueldo ON empledo
    FOR EACH ROW
    WHEN (old.sueldo > new.sueldo)
    EXECUTE PROCEDURE function_error();
```

<h4>Acción</h4>
Consiste en un conjunto de sentencias SQL delimitadas en un bloque BEGIN ... END.

* Pueden incluir sentencias de control.
* Puede referirse a valores anteriores y nuevos (OLD y NEW).
* No pueden incluir sentencias DDL (CREATE, ALTER, DROP). 

La acción del trigger es un procedimiento atómico, lo que quiere decir que si cualquier sentencia del cuerpo del trigger falla, la acción completa del trigger se deshace.

> [!CAUTION]
> <h4>Ejecución de triggers anidados</h4>
> Cuando un trigger BEFORE se ejecuta y dentro de él se incluye una operación de modificación de datos (INSERT, UPDATE, DELETE), esta operación puede a su vez activar otros triggers BEFORE.
>
>
> Las acciones de estos triggers anidados van quedando "pendientes" porque todas deben completarse antes de que se realice la operación inicial que las activó.
>
> Esto puede complicar mucho el seguimiento de las operaciones y causar efectos inesperados o ciclos infinitos si no se manejan correctamente.
>
> Ej: Si la activación de un trigger T1 dispara otro trigger T2: se suspende la ejecución de T1, se ejecuta el trigger anidado T2 y luego se retoma la ejecución de T1.

<p align="center">
  <img src="../img/triggers_en_cascada.jpg" alt="Activación de triggers en cascada" height="200px">
</p>

<h3>Variables especiales que podemos tener dentro de una función</h3>

* **NEW (RECORD)**: almacena la nueva fila para las operaciones INSERT/UPDATE en triggers a nivel ROW.
* **OLD (RECORD)**: almacena la antigua fila para las operaciones UPDATE/DELETE en triggers a nivel ROW.

> [!CAUTION]
> Las dos variables anteriores fucionan a nivel ROW, **en triggers a nivel STATEMENT es NULL**.

* **TG_NAME (TEXT)**: contiene el nombre del trigger actualmente disparado.
* **TG_WHEN (TEXT)**: contiene el string BEFORE o AFTER dependiendo de la definición del trigger.
* **TG_LEVEL (TEXT)**: contiene el string ROW o STATEMENT dependiendo de la definición del trigger.
* **TG_OP (TEXT)**: contiene el string INSERT, UPDATE o DELETE indicando por cuál operación se disparó el trigger.
* **TG_TABLE_NAME (TEXT)**: contiene el nombre de la tabla que disparó el trigger.

<h3>plpgsql</h3>
Es un lenguaje que permite ejecutar sentencias SQL a través de sentencias impoerativas y funciones (Posibilita realizar los controles que las sentencias declarativas de SQL no pueden). Posee estructuras de control (repetitivas y condicionales), permite definir variables, tipos y estructuras de datos, y permite crear funciones que sean invocadas en sentencias SQL normales o ejecutadas luego de un evento disparador (trigger).

**Las funciones escritas en plpgsql aceptan argumentos y pueden devolver distitos tipos de valores:**
* **void** cuando no debería devolver ningún valor. Solo está haciendo un proceso.
* **trigger** para aquellas funciones invocadas por un trigger.
* **boolean, text, etc** retorna solo valores.
* **SET OF schema.table** para retornar varias filas de datos.

**Estructura de una función**

```SQL
    CREATE [OR REPLACE] function nobre_funcion(lista_parametros) RETURNS tipo_retorno AS $$
        DECLARE

        BEGIN
            ...
            RETURN NEW;
        END $$        
        LANGUAGE plpgsql;
-- RETURN NEW indica que la función de trigger debe devolver la fila (registro) que se está procesando actualmente, posiblemente modificada.
```

<details>
<summary><strong>Ejemplo de función que devuelve una tabla</strong></summary><kbd>

```SQL
CREATE FUNCTION voluntarioscadax(x integer) RETURNS TABLE(nro_voluntario numeric, apellido varchar, nombre varchar) AS $$
    DECLARE 
        var_r record;
        i int;
    BEGIN
        i := 0;
        FOR var_r IN (
            SELECT v.nro_voluntario, v.apellido, v.nombre FROM unc_esq_voluntario.voluntario v) 
        LOOP
            IF (i % x = 0) THEN
                nro_voluntario := var_r.nro_voluntario;
                apellido := var_r.apellido;
                nombre := var_r.nombre;
                i := 0;
                RETURN NEXT;
            END IF;
            i := i + 1;
        END LOOP;
    END $$ 
LANGUAGE ‘plpgsql’

-- RETURN NEXT añade una fila a la salida de la función. En este caso, la fila contiene los valores de nro_voluntario, apellido y nombre.
```

```SQL
SELECT * FROM voluntarioscadax(3);
```

</kbd></details>

**Asignación**

* identifier := expression;

> [!NOTE]
> Si el tipo de dato resultante de la expresión no coincide con el tipo de dato de las variables, el interprete de plpgsql realiza el cast implícitamente.

**Declaración de variables**

```SQL
CREATE FUNCTION ejemplo(integer, integer) ...
    DECLARE
        num1            ALIAS FOR $1;           -- Primer parámetro
        num2            ALIAS FOR $2;           -- Segundo parámetro
        constante       CONSTANT integer := 100;
        resultado       INTEGER;
        resultado_text  TEXT DEFAULT 'Texto por defecto'
        tipo_reg        voluntario%rowtype;     -- Variable de tipo registro
        tipo_col        voluntario.nombre%type; -- Variable de tipo columna
```

**SELECT INTO**
Permite almacenar un registro completo (fila) en una variable.

```SQL
SELECT * INTO myrec FROM EMP
WHERE nombre_emp = mi_nombre;
```
> [!NOTE]
> Si la selección devuelve múltiples filas, solo la primer fila será almacenada en la variable (todas las demás se descartan).

**Estructuas de control**

```SQL
IF boolean-expression THEN
    sentencias;
[ ELSIF boolean-expression THEN
    sentencias;]
[ ELSIF boolean-expression THEN
    sentencias ...;]
[ ELSE
    sentencias ;]
END IF;
```

```SQL
WHILE expresión LOOP
    Sentencias;
END LOOP;
```

```SQL
FOR nombre IN [ REVERSE ] expresión .. expresión LOOP
	Sentecias;
END LOOP;

/* Crea un ciclo que itera sobre un rango de valores enteros.  La variable nombre es definida automáticamente como 
de tipo integer y existe sólo dentro del ciclo. Las dos expresiones determinan el intervalo de iteración y son evaluadas 
al entrar.  Por defecto el intervalo comienza en 1, excepto cuando se especifica REVERSE que es -1.*/
```