CREATE OR REPLACE TRIGGER TG_FINAL_PERIODO 
BEFORE UPDATE OF estado_periodo ON "Periodo"
FOR EACH ROW
DECLARE

    id_periodo NUMBER(8);
    fecha_inicio DATE;
    fecha_fin DATE;
    
    lc_listar_representantes SYS_REFCURSOR;

    TYPE representante_record IS RECORD
(
        cedula NUMBER
    );

    representante representante_record;

BEGIN

    PK_NATAME.PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio, fecha_fin, id_periodo);
    
    lc_listar_representantes := PK_NATAME.LISTAR_REPRESENTANTES;

    LOOP

        FETCH lc_listar_representantes INTO representante;
        EXIT WHEN lc_listar_representantes%NOTFOUND;

        UPDATE "RepresentantePeriodo"
                        SET valor_recaudado = (
                            SELECT SUM(p.monto)
        FROM "Pedido" p,
            "Cliente" c,
            "RepresentanteCliente" rc,
            "Periodo" pp,
            "RepresentantePeriodo" rp
        WHERE rp.fk_cedula_representante = representante.cedula
            AND rp.fk_cedula_representante = rc.fk_id_representante
            AND p.fk_cedula_cliente = c.cedula
            AND c.cedula = rc.fk_id_cliente
            AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
            (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
            AND pp.estado_periodo = 'A'
            AND pp.id_periodo = rp.fk_id_periodo
            AND p.fecha_pedido BETWEEN pp.fecha_inicio AND pp.fecha_fin
        GROUP BY rp.fk_cedula_representante, pp.id_periodo
                        )
        WHERE fk_cedula_representante = representante.cedula
        AND fk_id_periodo = id_periodo;
    END LOOP;
END TG_FINAL_PERIODO;
/

CREATE OR REPLACE TRIGGER TG_MONTO_PEDIDO
AFTER INSERT OR UPDATE OR DELETE ON "PedidoProducto"
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        UPDATE "Pedido" SET monto = monto + (:new.cantidad * :new.precio) 
        WHERE id_pedido = :new.fk_id_pedido;
    END IF;

    IF UPDATING THEN
        UPDATE "Pedido" SET monto = monto - (:old.cantidad * :old.precio) + (:new.cantidad * :new.precio) 
        WHERE id_pedido = :new.fk_id_pedido;
    END IF;

    IF DELETING THEN
        UPDATE "Pedido" SET monto = monto - (:old.cantidad * :old.precio) 
        WHERE id_pedido = :new.fk_id_pedido;
    END IF;
        

END TG_PEDIDO_PRODUCTO;

/

CREATE OR REPLACE TRIGGER TG_TOTAL_VENTA_REPRESENTANTE
AFTER INSERT ON "Pago"
FOR EACH ROW
BEGIN

    UPDATE "Representante" SET total_venta = total_venta + 
    (SELECT p.monto 
    FROM "Pedido" p
    WHERE p.id_pedido = :new.fk_id_pedido)
    WHERE cedula = (SELECT rc.fk_id_representante 
    FROM "Pedido" p, "RepresentanteCliente" rc, "Cliente" c
    WHERE p.id_pedido = :new.fk_id_pedido
    AND p.fk_cedula_cliente = rc.fk_id_cliente
    AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
    (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL)));

END TG_TOTAL_VENTA_REPRESENTANTE;
/

CREATE OR REPLACE TRIGGER TG_PROM_CALIFICACION_REPRESENTANTE
AFTER INSERT ON "Calificacion"
FOR EACH ROW
DECLARE

    ced_representante NUMBER(10);

BEGIN

    SELECT rc.fk_id_representante 
    INTO ced_representante
    FROM "Pedido" p, "Cliente" c, "RepresentanteCliente" rc
    WHERE p.id_pedido = :new.fk_id_pedido
    AND p.fk_cedula_cliente = rc.fk_id_cliente
    AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
    (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
    GROUP BY rc.fk_id_representante;

    UPDATE "Representante" SET prom_calificacion = (SELECT AVG(cl.nota)
    FROM "Pedido" p, "RepresentanteCliente" rc, "Calificacion" cl, "Cliente" c
    WHERE cl.fk_id_pedido = p.id_pedido
    AND p.fk_cedula_cliente = rc.fk_id_cliente
    AND ((p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin) OR 
    (p.fecha_pedido >= rc.fecha_inicio AND rc.fecha_fin IS NULL))
    AND rc.fk_id_representante = ced_representante
    GROUP BY rc.fk_id_representante)
    WHERE cedula = ced_representante;

END TG_PROM_CALIFICACION_REPRESENTANTE;
/