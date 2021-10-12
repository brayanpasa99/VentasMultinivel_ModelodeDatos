set verify off
set serveroutput on
DECLARE
    --Declaracion de variables locales
    id_pedido NUMBER(8);
    id_region NUMBER(4);
    total NUMBER(11);
BEGIN
    id_pedido := 1;
    id_region := 3;
    total := PK_NATAME.TOTALIZAR_CARRITO(id_pedido, id_region);
    DBMS_OUTPUT.PUT_LINE(total);
END;