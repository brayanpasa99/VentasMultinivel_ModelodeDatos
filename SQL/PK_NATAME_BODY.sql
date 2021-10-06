CREATE or REPLACE PACKAGE BODY PK_NATAME AS

    FUNCTION TOTALIZAR_CARRITO( id_pedido IN "Pedido".ID_PEDIDO%TYPE,
                                id_region IN "Region".ID_REGION%TYPE)
    IS
        --Declaración de variables locales
        CURSOR C_LISTAR_PRODUCTOS
        IS
            SELECT pp.cantidad, i.precio
            FROM "PedidoProducto" pp, "Producto" p, "Inventario" i
            WHERE pp.FK_ID_PEDIDO = id_pedido AND
            pp.FK_ID_PRODUCTO = p.id_producto AND
            p.id_producto = i.FK_ID_PRODUCTO AND
            i.FK_ID_REGION = id_region;
            --Definición de la variable para almacenar el registro leído
        lc_producto_carrito C_LISTAR_PRODUCTOS %ROWTYPE;
    BEGIN
        
        RETURN NUMBER;

    END TOTALIZAR_CARRITO;

END PK_NATAME;