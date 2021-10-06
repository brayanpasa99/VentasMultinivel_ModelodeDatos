CREATE OR REPLACE PACKAGE PK_NATAME AS

    --Función que totaliza y calcula el IVA del carrito
    FUNCTION TOTALIZAR_CARRITO( id_pedido IN "Pedido".ID_PEDIDO%TYPE,
                                id_region IN "Region".ID_REGION%TYPE) RETURN NUMBER;

END PK_NATAME;