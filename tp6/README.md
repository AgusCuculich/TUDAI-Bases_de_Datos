<h1>TRIGGERS (disparadores)</h1>

Son una herramienta útil para escribir assertions, restricciones complejas, acciones específicas de reparación, etc.

<h3>plpgsql</h3>
Es un lenguaje que permite ejecutar sentencias SQL a través de sentencias impoerativas y funciones (Posibilita realizar los controles que las sentencias declarativas de SQL no pueden). Posee estructuras de control (repetitivas y condicionales), permite definir variables, tipos y estructuras de datos, y <span style="color: BurntOrange">permite crear funciones que sean invocadas en sentencias SQL normales o ejecutadas luego de un evento disparador (trigger).</span>

**Las funciones escritas en plpgsql aceptan argumentos y pueden devolver distitos tipos de valores:**
* **void** cuando no debería devolver ningún valor. Solo está haciendo un proceso.
* **trigger** para aquellas funciones invocadas por un trigger.
* **boolean, text, etc** retorna solo valores.
* **SET OF schema.table** para retornar varias filas de datos.

Ejemplo con funciones que devuelven tabla

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
```

```SQL
SELECT * FROM voluntarioscadax(3);
```

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
sentencias;
[ ELSIF boolean-expression THEN
sentencias ...;]]
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

/* Crea un ciclo que itera sobre un rango de valores enteros.  La variable nombre es definida automáticamente como de tipo integer y existe sólo dentro del ciclo. Las dos expresiones determinan el intervalo de iteración y son evaluadas al entrar.  Por defecto el intervalo comienza en 1, excepto cuando se especifica REVERSE que es -1.*/
```

<h3>Datazos</h3>

<h4>Caso 1:</h4>
```SQL
CREATE TRIGGER tr_comparar_con_fecha_procesamiento
    BEFORE UPDATE OF fecha_img, id_paciente, id_imagen ON IMAGEN_MEDICA
    FOR EACH ROW
    WHEN (old.fecha_img < new.fecha_img)
    EXECUTE PROCEDURE fn_comparar_con_fecha_procesamiento();
```

* Para un INSERT, no puedes especificar columnas específicas porque la operación se aplica a toda la fila que se está insertando. El trigger se ejecuta para cada nueva fila.

* Para un UPDATE, puedes especificar columnas específicas para limitar el trigger a ejecutarse solo cuando esas columnas específicas se actualicen. Esto puede ser útil si solo te interesa hacer algo cuando ciertos campos cambian.

* Para un DELETE, similar a INSERT, no puedes especificar columnas porque la operación se aplica a toda la fila que se está eliminando.

<h4>Caso 2:</h4>

Usa BEFORE cuando:
* Necesitas validar o modificar los datos antes de que se realice la operación.
* Quieres asegurarte de que los datos cumplen ciertas condiciones antes de que se inserten o actualicen.
* Quieres rechazar la operación si los datos no son válidos.

Usa AFTER cuando:
* Necesitas realizar acciones basadas en los cambios confirmados en la base de datos.
* Quieres actualizar otros datos derivados después de que se complete la operación.
* Necesitas auditar o registrar los cambios que ya se han realizado.
* Quieres sincronizar los cambios con otros sistemas o procesos después de que la operación se haya completado.