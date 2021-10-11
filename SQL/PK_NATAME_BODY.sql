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
                AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
                (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
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
                AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
                (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
                AND pp.estado_periodo = 'A'
                AND pp.id_periodo = rp.fk_id_periodo
                AND p.fecha_pedido BETWEEN pp.fecha_inicio AND pp.fecha_fin
                AND cl.fk_id_pedido = p.id_pedido
            GROUP BY rp.fk_cedula_representante, pp.id_periodo)
            
            WHERE fk_cedula_representante = representante.cedula
            AND fk_id_periodo = id_periodo;

            UPDATE "Representante" SET prom_calificacion = (SELECT AVG(cl.nota)
                FROM "Pedido" p, "RepresentanteCliente" rc, "Calificacion" cl, "Cliente" c
                WHERE rc.fk_id_representante = representante.cedula
                AND c.cedula = rc.fk_id_cliente
                AND p.fk_cedula_cliente = c.cedula
                AND cl.fk_id_pedido = p.id_pedido
                GROUP BY rc.fk_id_representante)
                WHERE cedula = representante.cedula;
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

    PROCEDURE PR_INSERTAR_PRODUCTO(id_region IN "Inventario".fk_id_region%TYPE,
                                    id_producto IN "Inventario".fk_id_producto%TYPE,
                                    id_pedido IN "Pedido".id_pedido%TYPE,
                                    cantidad IN NUMBER
                                    )
    IS
        --Declaracion de variables locales
        cantidad_disp NUMBER(4);
        precio_inv NUMBER(6);
    BEGIN

        SELECT cantidad, precio
        INTO cantidad_disp, precio_inv
        FROM "Inventario"
        WHERE fk_id_region = id_region
        AND fk_id_producto = id_producto;

        IF cantidad_disp >= cantidad THEN

            INSERT INTO "PedidoProducto" (fk_id_pedido, fk_id_producto, cantidad, precio) VALUES (id_pedido, id_producto, cantidad, precio_inv);
            cantidad_disp := cantidad_disp - cantidad;
            UPDATE "Inventario" SET cantidad = cantidad_disp 
            WHERE fk_id_region = id_region
            AND fk_id_producto = id_producto;

        ELSE

            INSERT INTO "PedidoProducto" (fk_id_pedido, fk_id_producto, cantidad, precio) VALUES (id_pedido, id_producto, cantidad_disp, precio_inv);
            cantidad_disp := 0;
            UPDATE "Inventario" SET cantidad = cantidad_disp 
            WHERE fk_id_region = id_region
            AND fk_id_producto = id_producto;

        END IF;
        
    END PR_INSERTAR_PRODUCTO;

    PROCEDURE PR_GENERAR_FACTURA(id_pedido IN "Pedido".id_pedido%TYPE,
                                id_region IN "Region".id_region%TYPE)
    IS

        nombre_cliente VARCHAR(80);
        cedula_cliente NUMBER(10);
        tipo_id_cliente VARCHAR(2);
        nombre_representante VARCHAR(80);
        cedula_representante NUMBER(10);
        tipo_id_representante VARCHAR(2);
        fecha_pedido DATE;
        subtotal NUMBER(11);
        id_pago NUMBER(8);
        medio_pago VARCHAR(2);
        fecha_pago DATE;

        CURSOR C_LISTAR_PRODUCTOS_PEDIDO
        IS
            SELECT pp.fk_id_producto as id_producto, p.nombre as nombre, 
            pp.cantidad as cantidad, pp.precio as precio
            FROM "PedidoProducto" pp, "Producto" p
            WHERE pp.fk_id_pedido = id_pedido
            AND p.id_producto = pp.fk_id_producto;
    --Definición de la variable para almacenar el registro leído
            lc_producto C_LISTAR_PRODUCTOS_PEDIDO %ROWTYPE;


    BEGIN

        DBMS_OUTPUT.PUT_LINE('NATAME');
        DBMS_OUTPUT.PUT_LINE('Factura No. ' || id_pedido);
        
        SELECT p.monto, p.fk_cedula_cliente, c.tipo_identificacion, (c.primer_nombre || c.segundo_nombre || c.primer_apellido || c.segundo_apellido) as nombre,
        r.cedula, r.tipo_identificacion, (r.primer_nombre || r.segundo_nombre || r.primer_apellido || r.segundo_apellido) as nombre_rep, p.fecha_pedido
        INTO subtotal, cedula_cliente, tipo_id_cliente, nombre_cliente, cedula_representante, tipo_id_representante, nombre_representante, fecha_pedido
        FROM "Pedido" p, "Cliente" c, "Representante" r, "RepresentanteCliente" rc
        WHERE p.id_pedido = id_pedido
        AND p.fk_cedula_cliente = c.cedula
        AND c.cedula = rc.fk_id_cliente
        AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
            (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
        AND rc.fk_id_representante = r.cedula;

        SELECT pg.id_pago, pg.medio_pago, pg.fecha_pago
        INTO id_pago, medio_pago, fecha_pago
        FROM "Pago" pg
        WHERE pg.fk_id_pedido = id_pedido;

        DBMS_OUTPUT.PUT_LINE('Fecha Facturacion: ' || SYSDATE);
        DBMS_OUTPUT.PUT_LINE('Fecha Pedido: ' || fecha_pedido);
        DBMS_OUTPUT.PUT_LINE('Nombre del Cliente: ' || nombre_cliente);
        DBMS_OUTPUT.PUT_LINE('Identificacion del Cliente: ' || tipo_id_cliente || '. ' || cedula_cliente);
        DBMS_OUTPUT.PUT_LINE('Nombre del Representante: ' || nombre_representante);
        DBMS_OUTPUT.PUT_LINE('Identificacion del Representante: ' || tipo_id_representante || '. ' || cedula_representante);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
        
        DBMS_OUTPUT.PUT_LINE('|    ID    |           Nombre Producto          | Cantidad | Precio |');
        DBMS_OUTPUT.PUT_LINE('|----------|------------------------------------|----------|--------|');
        FOR lc_producto IN C_LISTAR_PRODUCTOS_PEDIDO LOOP
            DBMS_OUTPUT.PUT_LINE('|' || lc_producto.id_producto || '|' || lc_producto.nombre || '|' || lc_producto.cantidad || '|' || lc_producto.precio || '|');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Subtotal: ' || subtotal);
        DBMS_OUTPUT.PUT_LINE('IVA: ' || subtotal*0.19);
        DBMS_OUTPUT.PUT_LINE('Total: ' || TOTALIZAR_CARRITO(id_pedido, id_region));
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('No. pago: ' || id_pago);
        DBMS_OUTPUT.PUT_LINE('Fecha de pago: ' || fecha_pago);
        DBMS_OUTPUT.PUT_LINE('Medio de pago: ' || medio_pago);

    END PR_GENERAR_FACTURA;

END PK_NATAME;
/