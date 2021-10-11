CREATE or REPLACE PACKAGE BODY PK_NATAME AS

    FUNCTION TOTALIZAR_CARRITO( id_pedido IN "Pedido".ID_PEDIDO%TYPE,
                                id_region IN "Region".ID_REGION%TYPE) RETURN NUMBER
    IS
        --Declaración de variables locales
        total NUMBER(11) := 0;
    CURSOR C_LISTAR_PRODUCTOS
        IS
            SELECT pp.cantidad as cantidad, i.precio as precio
            FROM "PedidoProducto" pp, "Producto" p, "Inventario" i
            WHERE pp.FK_ID_PEDIDO = id_pedido AND
                pp.FK_ID_PRODUCTO = p.id_producto AND
                p.id_producto = i.FK_ID_PRODUCTO AND
                i.FK_ID_REGION = id_region;
--Definición de la variable para almacenar el registro leído
    lc_producto_carrito C_LISTAR_PRODUCTOS %ROWTYPE;

    BEGIN
        FOR lc_producto_carrito IN C_LISTAR_PRODUCTOS LOOP
            
                total := total + (lc_producto_carrito.cantidad * lc_producto_carrito.precio);
        END LOOP;
        total := total*1.19;
        RETURN total;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR (-20001, 'Pedido y/o region no encontrada');

    END TOTALIZAR_CARRITO;

    PROCEDURE CALIFICAR_REPRESENTANTE(id_pedido IN "Pedido".ID_PEDIDO%TYPE,
                                      nota IN NUMBER, observacion IN VARCHAR)
    IS
    BEGIN
        INSERT INTO "Calificacion"
            (FK_ID_PEDIDO, NOTA, OBSERVACION)
        VALUES
            (id_pedido, nota, observacion);
        EXCEPTION
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20002, 'La calificacion no pudo ser insertada');
    END CALIFICAR_REPRESENTANTE;

    
    PROCEDURE CALCULO_PROMEDIO_CALIFICACION
    IS
        -- Declaración de variables locales
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;

        lc_listar_representantes SYS_REFCURSOR;

        TYPE representante_record IS RECORD(
            cedula NUMBER
        );

        representante representante_record;

    BEGIN

        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);

        lc_listar_representantes := LISTAR_REPRESENTANTES;

        LOOP

            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;

            UPDATE "RepresentantePeriodo"
                            SET prom_calificacion = (
                                SELECT AVG(cl.nota)
            FROM "Pedido" p,
                "Cliente" c,
                "RepresentanteCliente" rc,
                "Periodo" pp,
                "RepresentantePeriodo" rp,
                "Calificacion" cl
            WHERE rp.fk_cedula_representante = representante.cedula
                AND rp.fk_cedula_representante = rc.fk_id_representante
                AND p.fk_cedula_cliente = c.cedula
                AND c.cedula = rc.fk_id_cliente
                AND p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin
                AND pp.estado_periodo = 'A'
                AND pp.id_periodo = rp.fk_id_periodo
                AND p.fecha_pedido BETWEEN pp.fecha_inicio AND pp.fecha_fin
                AND cl.fk_id_pedido = p.id_pedido
            GROUP BY rp.fk_cedula_representante, pp.id_periodo)
            
            WHERE fk_cedula_representante = representante.cedula
            AND fk_id_periodo = id_periodo;
        END LOOP;
    END CALCULO_PROMEDIO_CALIFICACION;
    
    PROCEDURE CALCULO_PROMEDIO_CALIFICACION(id_region IN "Region".id_region%TYPE)
    IS
        -- Declaración de variables locales
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;

        lc_listar_representantes SYS_REFCURSOR;

        TYPE representante_record IS RECORD(
            cedula NUMBER
        );

        representante representante_record;

    BEGIN

        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);

        lc_listar_representantes := LISTAR_REPRESENTANTES(id_region);

        LOOP

            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;

            UPDATE "RepresentantePeriodo"
                            SET prom_calificacion = (
                                SELECT AVG(cl.nota)
            FROM "Pedido" p,
                "Cliente" c,
                "RepresentanteCliente" rc,
                "Periodo" pp,
                "RepresentantePeriodo" rp,
                "Calificacion" cl
            WHERE rp.fk_cedula_representante = representante.cedula
                AND rp.fk_cedula_representante = rc.fk_id_representante
                AND p.fk_cedula_cliente = c.cedula
                AND c.cedula = rc.fk_id_cliente
                AND p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin
                AND pp.estado_periodo = 'A'
                AND pp.id_periodo = rp.fk_id_periodo
                AND p.fecha_pedido BETWEEN pp.fecha_inicio AND pp.fecha_fin
                AND cl.fk_id_pedido = p.id_pedido
            GROUP BY rp.fk_cedula_representante, pp.id_periodo)
            
            WHERE fk_cedula_representante = representante.cedula
            AND fk_id_periodo = id_periodo;
        END LOOP;
    END CALCULO_PROMEDIO_CALIFICACION;

    PROCEDURE CALCULAR_COMISION_PERIODICA
    IS
        -- Declaración de variables locales
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;

        ventas_rep NUMBER(11);
        calificacion_rep NUMBER(2,1);

        lc_listar_representantes SYS_REFCURSOR;
        lc_listar_grados SYS_REFCURSOR;

        TYPE representante_record IS RECORD(
            cedula NUMBER
        );

        TYPE grado_record IS RECORD(
            id NUMBER,
            nombre VARCHAR(10),
            porcentaje NUMBER,
            calificacion NUMBER,
            venta NUMBER
        );

        representante representante_record;
        grados grado_record;

    BEGIN

        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);

        lc_listar_representantes := LISTAR_REPRESENTANTES;
        lc_listar_grados := LISTAR_GRADOS;

        LOOP

            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;

            SELECT valor_recaudado, prom_calificacion
            INTO ventas_rep, calificacion_rep
            FROM "RepresentantePeriodo"
            WHERE fk_cedula_representante = representante.cedula
            AND fk_id_periodo = id_periodo;

            LOOP

                FETCH lc_listar_grados INTO grados;
                EXIT WHEN lc_listar_grados%NOTFOUND;

                --HACE FALTA EL IF
                IF ventas_rep >= grados.venta THEN

                    IF calificacion_rep >= grados.calificacion THEN

                        UPDATE "RepresentantePeriodo" SET grado = grados.nombre, porcentaje = grados.porcentaje 
                        WHERE fk_cedula_representante = representante.cedula
                        AND fk_id_periodo = id_periodo;

                        UPDATE "RepresentantePeriodo" SET comision = ventas_rep * grados.porcentaje
                        WHERE fk_cedula_representante = representante.cedula
                        AND fk_id_periodo = id_periodo;

                    END IF;

                END IF;

            END LOOP;
        END LOOP;

    END CALCULAR_COMISION_PERIODICA;
    
    PROCEDURE CALCULAR_COMISION_PERIODICA(id_region IN "Region".id_region%TYPE)
    IS
        -- Declaración de variables locales
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;

        ventas_rep NUMBER(11);
        calificacion_rep NUMBER(2,1);

        lc_listar_representantes SYS_REFCURSOR;
        lc_listar_grados SYS_REFCURSOR;

        TYPE representante_record IS RECORD(
            cedula NUMBER
        );

        TYPE grado_record IS RECORD(
            id NUMBER,
            nombre VARCHAR(10),
            porcentaje NUMBER,
            calificacion NUMBER,
            venta NUMBER
        );

        representante representante_record;
        grados grado_record;

    BEGIN

        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);

        lc_listar_representantes := LISTAR_REPRESENTANTES(id_region);
        lc_listar_grados := LISTAR_GRADOS;

        LOOP

            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;

            SELECT valor_recaudado, prom_calificacion
            INTO ventas_rep, calificacion_rep
            FROM "RepresentantePeriodo"
            WHERE fk_cedula_representante = representante.cedula
            AND fk_id_periodo = id_periodo;

            LOOP

                FETCH lc_listar_grados INTO grados;
                EXIT WHEN lc_listar_grados%NOTFOUND;

                --HACE FALTA EL IF
                IF ventas_rep >= grados.venta THEN

                    IF calificacion_rep >= grados.calificacion THEN

                        UPDATE "RepresentantePeriodo" SET grado = grados.nombre, porcentaje = grados.porcentaje 
                        WHERE fk_cedula_representante = representante.cedula
                        AND fk_id_periodo = id_periodo;

                        UPDATE "RepresentantePeriodo" SET comision = ventas_rep * grados.porcentaje
                        WHERE fk_cedula_representante = representante.cedula
                        AND fk_id_periodo = id_periodo;

                    END IF;

                END IF;

            END LOOP;
        END LOOP;

    END CALCULAR_COMISION_PERIODICA;

    PROCEDURE PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio OUT DATE, 
                                        fecha_fin OUT DATE, 
                                        id_periodo OUT NUMBER)
    IS
    BEGIN
        SELECT p.id_periodo as id_p, p.fecha_inicio as fecha_i, p.fecha_fin as fecha_f
        INTO id_periodo, fecha_inicio, fecha_fin
        FROM "Periodo" p
        WHERE p.estado_periodo = 'A';
    END PR_BUSCAR_PERIODO_ACTIVO;

    FUNCTION LISTAR_REPRESENTANTES
    RETURN SYS_REFCURSOR
    IS
            
            TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
            lc_listar_representantes C_LISTAR_REPRESENTANTES;

    BEGIN

        OPEN lc_listar_representantes FOR SELECT cedula as cedula
        FROM "Representante";
        RETURN lc_listar_representantes;

    END LISTAR_REPRESENTANTES;
    
    FUNCTION LISTAR_REPRESENTANTES(id_region IN "Region".id_region%TYPE)
    RETURN SYS_REFCURSOR
    IS
            
            TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
            lc_listar_representantes C_LISTAR_REPRESENTANTES;

    BEGIN

        OPEN lc_listar_representantes FOR SELECT cedula as cedula
        FROM "Representante" WHERE fk_id_region = id_region;
        RETURN lc_listar_representantes;

    END LISTAR_REPRESENTANTES;

    FUNCTION LISTAR_GRADOS
    RETURN SYS_REFCURSOR
    IS
            
            TYPE C_LISTAR_GRADOS IS REF CURSOR;
            lc_listar_grados C_LISTAR_GRADOS;

    BEGIN

        OPEN lc_listar_grados FOR SELECT id_grado, nombre_grado, porcentaje_comision, calificacion_minima, venta_minima
        FROM "Grado";
        RETURN lc_listar_grados;

    END LISTAR_GRADOS;

END PK_NATAME;
/