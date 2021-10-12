CREATE or REPLACE PACKAGE BODY PK_NATAME AS
/*-----------------------------------------------------------------------------------
  Proyecto   : Tienda de productos naturales NaTaMe - Grupo 6 BD II
  Descripcion: Paquete que contiene los procedimientos y funciones descritos en
               el Taller de Seguridad - Pt. 2 y procedimientos y funciones adicionales
  Autores:     Arley Esteban Quintero - 20171020022
               Mateo Yate Gonzalez - 20171020087
               Brayan A. Paredes - 20171020106
               Kevin A. Borda - 20171020088
--------------------------------------------------------------------------------------*/

    /*------------------------------------------------------------------------------
     (1) Funcion totalizar el carrito, incluyendo el cálculo del IVA
     Parametros de Entrada: id_pedido       Identificación del pedido a liquidar
                            id_region       Identificación de la región donde se realiza el
     Retorna:               El total del pedido con el IVA incluido
   */ 
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

    /*------------------------------------------------------------------------------
     (4) Procedimiento que Implementa la funcionalidad que permite al cliente calificar a su representante de ventas
     Parametros de Entrada: id_pedido       Identificación del pedido a liquidar
                            nota            Calificacion de 0 a 5 del cliente al representante
                            observacion     Anotacion dada por el cliente referente al desempeño del representante
     Parametros de Salida:  Ninguno.
   */
    PROCEDURE CALIFICAR_REPRESENTANTE(id_pedido IN "Pedido".ID_PEDIDO%TYPE,
                                      nota      IN NUMBER, observacion IN VARCHAR)
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

    /*------------------------------------------------------------------------------
     (5.1) Procedimiento para Calcular el promedio de las calificaciones periódicas de cada representante
     Parametros de Entrada: Ninguno.
     Parametros de Salida:  Ninguno.
   */    
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

    /*------------------------------------------------------------------------------
     (5.2) Procedimiento para Calcular el promedio de las calificaciones periódicas de cada representante de una región particular
     Parametros de Entrada: id_region       Identificación de la región de los representantes cuyos promedios
                                            de calificación se desean calcular.
     Parametros de Salida:  Ninguno.
     Particularidad:        El procedimiento se realiza empleando polimorfismo con (5.1) para contemplar el caso en el 
                            que se desee calcular únicamente el promedio de calificaciones de representantes de una región.
   */    
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

    /*------------------------------------------------------------------------------
     (7.1) Procedimiento para calcular al final de cada periodo la comisión de los represenantes de ventas. 
     (Se ejecuta en el trigger TG_FINAL_PERIODO).
     Parametros de Entrada: Ninguno.
     Parametros de Salida:  Ninguno.
   */   
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
    
    /*------------------------------------------------------------------------------
     (7.2) Procedimiento para calcular al final de cada periodo la comisión de los represenantes de ventas
     asociados a una región en particular (Se ejecuta en el trigger TG_FINAL_PERIODO).
     Parametros de Entrada: id_region           Identificación de la región de los representantes a los cuales
                                                se les desea calcular la comisión en el periodo actual.
     Parametros de Salida:  Ninguno.
     Particularidad:        Emplea polimorfismo por si se desea calcular la comisión de todos los representantes
                            o únicamente los representantes de una región en particular.
   */       
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

    /*------------------------------------------------------------------------------
     * Procedimiento para buscar el periodo que se encuentra actualmente en vigencia (Empleado por otros procedimientos)
     Parametros de Entrada: Ninguno.
     Parametros de Salida:  fecha_inicio    Fecha de inicio del periodo actual.
                            fecha_fin       Fecha final del periodo actual. (Los periodos duran 3 meses).
                            id_periodo      Identifación del periodo actual.
   */    
    PROCEDURE PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio OUT DATE, 
                                        fecha_fin   OUT DATE, 
                                        id_periodo  OUT NUMBER)
    IS
    BEGIN
        SELECT p.id_periodo as id_p, p.fecha_inicio as fecha_i, p.fecha_fin as fecha_f
        INTO id_periodo, fecha_inicio, fecha_fin
        FROM "Periodo" p
        WHERE p.estado_periodo = 'A';
    END PR_BUSCAR_PERIODO_ACTIVO;

    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes de la empresa. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: Ninguno.
     Retorna:               Cursor con los representantes de la empresa.
   */ 
    FUNCTION LISTAR_REPRESENTANTES
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales    
        TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES;
    BEGIN
        OPEN lc_listar_representantes FOR SELECT cedula as cedula
        FROM "Representante";
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES;
    
    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes de la empresa asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_region       Identificación de la región de los representantes que se
                                            desean listar.
     Retorna:               Cursor con los representantes de la empresa asociados a una región particular.
   */     
    FUNCTION LISTAR_REPRESENTANTES(id_region IN "Region".id_region%TYPE)
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales
        TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES;
    BEGIN
        OPEN lc_listar_representantes FOR SELECT cedula as cedula
        FROM "Representante" WHERE fk_id_region = id_region;
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES;
    
    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes ordenados de toda la empresa. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: Ninguno.
     Retorna:               Cursor con los representantes de toda la empresa ordenados.
   */ 
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales    
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
        TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES;
        TYPE representante_record IS RECORD(
            cedula NUMBER
        );
        representante representante_record;
        lc_listar SYS_REFCURSOR;
        id_grado_rep NUMBER(1);
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        OPEN lc_listar_representantes FOR SELECT r.cedula, (r.primer_nombre || r.segundo_nombre 
        || r.primer_apellido || r.segundo_apellido) as nombre, rp.valor_recaudado, rp.prom_calificacion,
        g.nombre_grado, rp.grado 
        FROM "Representante" r, "RepresentantePeriodo" rp, "Grado" g WHERE rp.fk_cedula_representante = r.cedula
        AND rp.fk_id_periodo = id_periodo
        AND g.id_grado = r.fk_id_grado
        ORDER BY rp.valor_recaudado, rp.prom_calificacion DESC;
        lc_listar := LISTAR_REPRESENTANTES;
        LOOP
            FETCH lc_listar INTO representante;
            EXIT WHEN lc_listar%NOTFOUND;
            SELECT id_grado
            INTO id_grado_rep
            FROM "Grado" g, "RepresentantePeriodo" rp, "Representante" r
            WHERE rp.fk_cedula_representante = r.cedula
            AND r.cedula = representante.cedula
            AND rp.fk_id_periodo = id_periodo
            AND rp.grado = g.nombre_grado;

            UPDATE "Representante" SET fk_id_grado = id_grado_rep
            WHERE cedula = representante.cedula;
        END LOOP;
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES_ORDENADOS;
    
    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes ordenados de la empresa asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_region       Identificación de la región de los representantes que se
                                            desean listar.
     Retorna:               Cursor con los representantes de la empresa asociados a una región particular ordenados.
   */     
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS(id_region IN "Region".id_region%TYPE)
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales    
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
            
        TYPE C_LISTAR_REPRESENTANTES IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES;
        TYPE representante_record IS RECORD(
            cedula NUMBER
        );
        representante representante_record;
        lc_listar SYS_REFCURSOR;
        id_grado_rep NUMBER(1);
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        OPEN lc_listar_representantes FOR SELECT r.cedula, (r.primer_nombre || r.segundo_nombre 
        || r.primer_apellido || r.segundo_apellido) as nombre, rp.valor_recaudado, rp.prom_calificacion,
        g.nombre_grado, rp.grado 
        FROM "Representante" r, "RepresentantePeriodo" rp, "Grado" g WHERE rp.fk_cedula_representante = r.cedula
        AND rp.fk_id_periodo = id_periodo
        AND g.id_grado = r.fk_id_grado
        AND r.fk_id_region = id_region
        ORDER BY rp.valor_recaudado, rp.prom_calificacion DESC;
        lc_listar := LISTAR_REPRESENTANTES(id_region);
        LOOP
            FETCH lc_listar INTO representante;
            EXIT WHEN lc_listar%NOTFOUND;
            SELECT id_grado
            INTO id_grado_rep
            FROM "Grado" g, "RepresentantePeriodo" rp, "Representante" r
            WHERE rp.fk_cedula_representante = r.cedula
            AND r.cedula = representante.cedula
            AND rp.fk_id_periodo = id_periodo
            AND rp.grado = g.nombre_grado;

            UPDATE "Representante" SET fk_id_grado = id_grado_rep
            WHERE cedula = representante.cedula
            and fk_id_region = id_region;
        END LOOP;
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES_ORDENADOS;
    
    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes a cargo de un representante particular en toda la 
     empresa (Usado en PR_REPORTE_REPRESENTANTE).
     Parametros de Entrada: id_representante    Identificación del representante cuyos representantes a cargo
                                                se desean filtrar.
     Retorna:               Cursor con los representantes que estan a cargo de un representante en particular 
   */    
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE)
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales    
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
        TYPE C_LISTAR_REPRESENTANTES_A_CARGO IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES_A_CARGO;
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        OPEN lc_listar_representantes FOR SELECT r.cedula, rp.valor_recaudado
        FROM "Representante" r, "RepresentantePeriodo" rp WHERE r.fk_id_rep_padre = id_representante
        AND rp.fk_cedula_representante = r.cedula
        AND rp.fk_id_periodo = id_periodo;
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES_A_CARGO;
    
    /*------------------------------------------------------------------------------
     * Funcion para listar los representantes a cargo de un representante particular en la 
     empresa asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_representante    Identificación del representante cuyos representantes a cargo
                                                se desean filtrar.
                            id_region           Identificación de la región de los representantes que se
                                                desean listar.
     Retorna:               Cursor con los representantes que estan a cargo de un representante en particular
                            teniendo en cuenta la región del representante. 
   */    
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE,
                                            id_region       IN "Region".id_region%TYPE)
    RETURN SYS_REFCURSOR
    IS
        --Declaración de variables locales    
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
        TYPE C_LISTAR_REPRESENTANTES_A_CARGO IS REF CURSOR;
        lc_listar_representantes C_LISTAR_REPRESENTANTES_A_CARGO;
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        OPEN lc_listar_representantes FOR SELECT r.cedula, rp.valor_recaudado
        FROM "Representante" r, "RepresentantePeriodo" rp WHERE r.fk_id_rep_padre = id_representante
        AND rp.fk_cedula_representante = r.cedula
        AND rp.fk_id_periodo = id_periodo AND r.fk_id_region = id_region;
        RETURN lc_listar_representantes;
    END LISTAR_REPRESENTANTES_A_CARGO;

    /*------------------------------------------------------------------------------
     * Funcion para listar los grados que se encuentran almacenados previamente en la tabla de Grados. 
     (Usado en CALCULAR_COMISION_PERIODICA).
     empresa o de los representantes asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: Ninguno.
     Retorna:               Cursor con los grados almacenados en la BD.
   */ 
    FUNCTION LISTAR_GRADOS
    RETURN SYS_REFCURSOR
    IS
        -- Declaración de variables locales    
        TYPE C_LISTAR_GRADOS IS REF CURSOR;
        lc_listar_grados C_LISTAR_GRADOS;
    BEGIN
        OPEN lc_listar_grados FOR SELECT id_grado, nombre_grado, porcentaje_comision, calificacion_minima, venta_minima
        FROM "Grado";
        RETURN lc_listar_grados;
    END LISTAR_GRADOS;

    /*------------------------------------------------------------------------------
     * Procedimiento para Insertar productos a un pedido en particular.
     Parametros de Entrada: id_region       Identificación de la región del producto a añadir.
                            id_producto     Identificación del producto a añadir.
                            id_pedido       Identificación del pedido al cual se añadirá el producto.
                            cantidad        Cantidad de unidades del producto que se añadirán al pedido.
     Parametros de Salida:  Ninguno.
   */
    PROCEDURE PR_INSERTAR_PRODUCTO(id_region    IN "Inventario".fk_id_region%TYPE,
                                    id_producto IN "Inventario".fk_id_producto%TYPE,
                                    id_pedido   IN "Pedido".id_pedido%TYPE,
                                    cantidad    IN NUMBER
                                    )
    IS
        --Declaracion de variables locales
        cantidad_disp NUMBER(4);
        precio_inv NUMBER(6);
        cantidad_aux NUMBER(4);
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

    /*------------------------------------------------------------------------------
     (3) Funcion para Generar la factura de venta mediante un archivo PL/SQL y retornarla a la app para mostrarla.
     Parametros de Entrada: id_pedido       Identificación del pedido al cual se le desea realizar facturación.
                            id_region       Identificacion de la región para el llamado de la func. TOTALIZAR_CARRITO
     Retorna:               Cadena de texto de tipo VARCHAR que contiene la factura para ser ilustrada en la App.
   */ 
    FUNCTION PR_GENERAR_FACTURA(id_pedido IN "Pedido".id_pedido%TYPE,
                                id_region IN "Region".id_region%TYPE) RETURN VARCHAR
    IS
        -- Declaración de variables locales
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
        salida VARCHAR(3900);
        CURSOR C_LISTAR_PRODUCTOS_PEDIDO
        IS
            SELECT pp.fk_id_producto as id_producto, p.nombre as nombre, 
            pp.cantidad as cantidad, pp.precio as precio
            FROM "PedidoProducto" pp, "Producto" p
            WHERE pp.fk_id_pedido = id_pedido
            AND p.id_producto = pp.fk_id_producto;
            lc_producto C_LISTAR_PRODUCTOS_PEDIDO %ROWTYPE;
    BEGIN
        salida := 'NATAME\n';
        salida := salida + 'Factura No. ' || id_pedido || '\n';
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
        salida := salida + 'Fecha Facturacion: ' || SYSDATE || '\n';
        salida := salida + 'Fecha Pedido: ' || fecha_pedido || '\n';
        salida := salida + 'Nombre del Cliente: ' || nombre_cliente || '\n';
        salida := salida + 'Identificacion del Cliente: ' || tipo_id_cliente || '. ' || cedula_cliente || '\n';
        salida := salida + 'Nombre del Representante: ' || nombre_representante || '\n';
        salida := salida + 'Identificacion del Representante: ' || tipo_id_representante || '. ' || cedula_representante || '\n';
        salida := salida + '---------------------------------------------------------------------' || '\n';
        salida := salida + '|    ID    |           Nombre Producto          | Cantidad | Precio |' || '\n';
        salida := salida + '|----------|------------------------------------|----------|--------|' || '\n';
        FOR lc_producto IN C_LISTAR_PRODUCTOS_PEDIDO LOOP
            salida := salida + '|' || lc_producto.id_producto || '|' || lc_producto.nombre || '|' || lc_producto.cantidad || '|' || lc_producto.precio || '|' || '\n';
        END LOOP;
        salida := salida + '---------------------------------------------------------------------' || '\n';
        salida := salida + 'Subtotal: ' || subtotal || '\n';
        salida := salida + 'IVA: ' || subtotal*0.19 || '\n';
        salida := salida + 'Total: ' || TOTALIZAR_CARRITO(id_pedido, id_region) || '\n';
        salida := salida + '---------------------------------------------------------------------' || '\n';
        salida := salida + 'No. pago: ' || id_pago || '\n';
        salida := salida + 'Fecha de pago: ' || fecha_pago || '\n';
        salida := salida + 'Medio de pago: ' || medio_pago || '\n';
        RETURN salida;
    END PR_GENERAR_FACTURA;

    /*------------------------------------------------------------------------------
     (6.1) Función para calificar periódicamente a los representantes de ventas y generar un resumen con los datos
     corresppndientes al total de ventas de cada representante, representante a cargo y acumulado de ventas de cada
     uno; promedio de calificación, categoría anterior y categoría asignada.
     Parametros de Entrada: Ninguno.
     Retorna:               El resumen en formato VARCHAR de cada uno de los representantes con los
                            parámetros descritos en el alcance del taller para ser impreso o ilustrado
                            en la aplicación.
     Particularidad:        Se emplea una función en vez de un procedimiento puesto que se requiere
                            realizar un retorno a la aplicación para ilustrar el resumen.
   */     
    FUNCTION PR_REPORTE_REPRESENTANTE RETURN VARCHAR
    IS
        -- Declaración de variables locales
        lc_listar_representantes SYS_REFCURSOR;
        lc_listar_representantes_a_cargo SYS_REFCURSOR;
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
        nombre_representante VARCHAR(80);
        cedula_representante NUMBER(10);
        total_venta_periodo NUMBER(11);
        calificacion_periodo NUMBER(2,1);
        cedula_representante_h NUMBER(10);
        total_venta_periodo_h NUMBER(11);
        calificacion_periodo_h NUMBER(2,1);
        salida VARCHAR(3900);
        TYPE representante_record IS RECORD(
            cedula NUMBER,
            nombre VARCHAR(80),
            total_venta NUMBER,
            prom_calificacion NUMBER,
            grado_antiguo VARCHAR(10),
            grado_actual VARCHAR(10)
        );
        TYPE representante_h_record IS RECORD(
            cedula NUMBER,
            total_venta NUMBER
        );
        representante representante_record;
        representante_h representante_h_record;
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        lc_listar_representantes := LISTAR_REPRESENTANTES_ORDENADOS;
        salida := 'NATAME' || '\n';
        salida := salida + 'REPORTE PERIODICO DE REPRESENTANTES DE VENTAS' || '\n';
        LOOP
            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;
            salida := salida + 'Cedula: ' || representante.cedula || '\n';
            salida := salida + 'Nombre del representante: ' || representante.nombre || '\n';
            salida := salida + 'Valor Recaudado en el periodo: ' || representante.total_venta || '\n';
            salida := salida + 'Promedio de calificaciones en el periodo: ' || representante.prom_calificacion || '\n';
            salida := salida + 'Grado anterior del representante: ' || representante.grado_antiguo || '\n';
            salida := salida + 'Grado actual del representante: ' || representante.grado_actual || '\n';
            salida := salida + 'Representantes a su cargo: ' || '\n';
            lc_listar_representantes_a_cargo := LISTAR_REPRESENTANTES_A_CARGO(representante.cedula);
            LOOP
                FETCH lc_listar_representantes_a_cargo INTO representante_h;
                EXIT WHEN lc_listar_representantes_a_cargo%NOTFOUND;
                salida := salida + 'Cedula: ' || representante_h.cedula || '. Valor Recaudado en el periodo: ' || representante_h.total_venta || '\n';
            END LOOP;
        END LOOP;
        return salida;
    END PR_REPORTE_REPRESENTANTE;

    /*------------------------------------------------------------------------------
     (6.2) Función para calificar periódicamente a los representantes de ventas y generar un resumen con los datos
     corresppndientes al total de ventas de cada representante, representante a cargo y acumulado de ventas de cada
     uno; promedio de calificación, categoría anterior y categoría asignada.
     Parametros de Entrada: id_region       Identificación de la región de los representantes cuyos reportes
                                            y calificaciones periódicas se desean generar.
     Retorna:               El resumen en formato VARCHAR de cada uno de los representantes con los
                            parámetros descritos en el alcance del taller para ser impreso o ilustrado
                            en la aplicación.
     Particularidad:        La función tiene un comportamiento polimorfico por el tratamiento 
                            de la región de los representantes.
                            Se emplea una función en vez de un procedimiento puesto que se requiere
                            realizar un retorno a la aplicación para ilustrar el resumen.
   */     
    FUNCTION PR_REPORTE_REPRESENTANTE(id_region IN "Region".id_region%TYPE) RETURN VARCHAR
    IS
        -- Declaración de variables locales
        lc_listar_representantes SYS_REFCURSOR;
        lc_listar_representantes_a_cargo SYS_REFCURSOR;
        id_periodo NUMBER(8);
        fecha_inicio DATE;
        fecha_fin DATE;
        nombre_representante VARCHAR(80);
        cedula_representante NUMBER(10);
        total_venta_periodo NUMBER(11);
        calificacion_periodo NUMBER(2,1);
        cedula_representante_h NUMBER(10);
        total_venta_periodo_h NUMBER(11);
        calificacion_periodo_h NUMBER(2,1);
        salida VARCHAR(3900);
        TYPE representante_record IS RECORD(
            cedula NUMBER,
            nombre VARCHAR(80),
            total_venta NUMBER,
            prom_calificacion NUMBER,
            grado_antiguo VARCHAR(10),
            grado_actual VARCHAR(10)
        );
        TYPE representante_h_record IS RECORD(
            cedula NUMBER,
            total_venta NUMBER
        );
        representante representante_record;
        representante_h representante_h_record;
    BEGIN
        PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
        lc_listar_representantes := LISTAR_REPRESENTANTES_ORDENADOS(id_region);
        salida := 'NATAME' || '\n';
        salida := salida + 'REPORTE PERIODICO DE REPRESENTANTES DE VENTAS' || '\n';
        LOOP
            FETCH lc_listar_representantes INTO representante;
            EXIT WHEN lc_listar_representantes%NOTFOUND;
            salida := salida + 'Cedula: ' || representante.cedula || '\n';
            salida := salida + 'Nombre del representante: ' || representante.nombre || '\n';
            salida := salida + 'Valor Recaudado en el periodo: ' || representante.total_venta || '\n';
            salida := salida + 'Promedio de calificaciones en el periodo: ' || representante.prom_calificacion || '\n';
            salida := salida + 'Grado anterior del representante: ' || representante.grado_antiguo || '\n';
            salida := salida + 'Grado actual del representante: ' || representante.grado_actual || '\n';
            salida := salida + 'Representantes a su cargo: ' || '\n';
            lc_listar_representantes_a_cargo := LISTAR_REPRESENTANTES_A_CARGO(representante.cedula, id_region);
            LOOP
                FETCH lc_listar_representantes_a_cargo INTO representante_h;
                EXIT WHEN lc_listar_representantes_a_cargo%NOTFOUND;
                salida := salida + 'Cedula: ' || representante_h.cedula || '. Valor Recaudado en el periodo: ' || representante_h.total_venta || '\n';
            END LOOP;
        END LOOP;
        RETURN salida;
    END PR_REPORTE_REPRESENTANTE;

    /*------------------------------------------------------------------------------
     * Procedimiento para Realizar el cambio de representante a un cliente.
     Parametros de Entrada: id_cliente          Identificación del cliente al cual se le desea realizar el cambio.
                            id_representante    Identificación del nuevo representante asociado a un cliente.
     Parametros de Salida:  Ninguno.
   */
    PROCEDURE PR_CAMBIAR_REPRESENTANTE(id_cliente           IN "Cliente".cedula%TYPE,
                                        id_representante    IN "Representante".cedula%TYPE)
    IS
    BEGIN
        UPDATE "RepresentanteCliente" SET fecha_fin = TO_CHAR(SYSDATE, 'DD-MM-YYYY')
        WHERE fk_id_cliente = id_cliente AND fecha_fin IS NULL;

        INSERT INTO "RepresentanteCliente" (FK_ID_REPRESENTANTE, FK_ID_CLIENTE, FECHA_INICIO, FECHA_FIN)
        VALUES (id_representante, id_cliente, TO_CHAR((SYSDATE+1), 'DD-MM-YYYY'), NULL);
    END PR_CAMBIAR_REPRESENTANTE;
END PK_NATAME;
/