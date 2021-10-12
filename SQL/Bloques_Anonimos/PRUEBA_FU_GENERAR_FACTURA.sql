set verify off
set serveroutput on
DECLARE

    salida_factura VARCHAR(3900);

BEGIN

    --Dentro de la función FU_GENERAR_FACTURA se ejecuta TOTALIZAR_CARRITO
    salida_factura := FU_GENERAR_FACTURA(4, 3);
    DBMS_OUTPUT.PUT_LINE(salida_factura);

END;
/