CREATE OR REPLACE PACKAGE PK_NATAME AS --Función que totaliza y calcula el IVA del carrito
    
    FUNCTION TOTALIZAR_CARRITO(id_pedido IN "Pedido".ID_PEDIDO % TYPE,
                                id_region IN "Region".ID_REGION % TYPE) RETURN NUMBER;
--Procedimiento que permite a un cliente calificar a su representante
    PROCEDURE CALIFICAR_REPRESENTANTE(
        id_pedido IN "Pedido".ID_PEDIDO % TYPE,
        nota IN NUMBER,
        observacion IN VARCHAR
    );
    -- Procedimiento que calcula el promedio de calificaciones periodicas de cada representante
    --Trigger que rellena las columnas de la tabla RepresentantePeriodo al final de cada periodo
    /* TRIGGER TG_FINAL_PERIODO; */
    PROCEDURE CALCULO_PROMEDIO_CALIFICACION;

    PROCEDURE CALCULO_PROMEDIO_CALIFICACION(id_region IN "Region".id_region%TYPE);
    PROCEDURE PR_BUSCAR_PERIODO_ACTIVO(
        fecha_inicio OUT DATE,
        fecha_fin OUT DATE,
        id_periodo OUT NUMBER
    );
    -- Procedimiento que clasifica periodicamente a los representantes y genera un reporte
    FUNCTION LISTAR_REPRESENTANTES RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES(id_region IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS(id_region IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE,
                                            id_region IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;

    FUNCTION LISTAR_GRADOS RETURN SYS_REFCURSOR;

    PROCEDURE CALCULAR_COMISION_PERIODICA;
    PROCEDURE CALCULAR_COMISION_PERIODICA(id_region IN "Region".id_region%TYPE);

    PROCEDURE PR_INSERTAR_PRODUCTO(id_region IN "Inventario".fk_id_region%TYPE,
                                    id_producto IN "Inventario".fk_id_producto%TYPE,
                                    id_pedido IN "Pedido".id_pedido%TYPE,
                                    cantidad IN NUMBER
                                    );

    FUNCTION PR_GENERAR_FACTURA(id_pedido IN "Pedido".id_pedido%TYPE,
                                id_region IN "Region".id_region%TYPE) RETURN VARCHAR;

    FUNCTION PR_REPORTE_REPRESENTANTE RETURN VARCHAR;
    FUNCTION PR_REPORTE_REPRESENTANTE(id_region IN "Region".id_region%TYPE) RETURN VARCHAR;

    PROCEDURE PR_CAMBIAR_REPRESENTANTE(id_cliente IN "Cliente".cedula%TYPE,
                                        id_representante IN "Representante".cedula%TYPE);

END PK_NATAME;
/