set verify off
set serveroutput on
DECLARE


BEGIN

    /* INSERT INTO "Pago" (FK_ID_PEDIDO, FECHA_PAGO, MEDIO_PAGO) VALUES (4, '15-03-2022', 'T');
    INSERT INTO "Pago" (FK_ID_PEDIDO, FECHA_PAGO, MEDIO_PAGO) VALUES (6, '16-03-2022', 'T'); */

    PK_NATAME.PR_PAGAR_CARRITO(4, 1234567890);
    PK_NATAME.PR_PAGAR_CARRITO(6, 1234567891);

    PK_NATAME.CALIFICAR_REPRESENTANTE(4,3,'Demora en la entrega');
    PK_NATAME.CALIFICAR_REPRESENTANTE(6,5,'Buen Servicio');

    -- Dentro de PR_FINAL_PERIODO se ejecutan los siguientes procedimientos:
        -- PR_BUSCAR_PERIODO_ACTIVO
        -- CALCULAR_PROMEDIO_CALIFICACION
        -- CALCULAR_COMISION_PERIODICA
    PK_NATAME.PR_FINAL_PERIODO;

END;
/