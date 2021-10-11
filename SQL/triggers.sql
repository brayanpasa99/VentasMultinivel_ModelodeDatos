CREATE OR REPLACE TRIGGER TG_FINAL_PERIODO BEFORE
UPDATE OF
estado_periodo
ON
"Periodo"
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
            AND p.fecha_pedido BETWEEN rc.fecha_inicio AND rc.fecha_fin
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