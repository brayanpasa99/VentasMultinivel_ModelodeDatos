set verify off
set serveroutput on
DECLARE

    salida_reporte VARCHAR(3900);

BEGIN

    salida_reporte := PK_NATAME.FU_REPORTE_REPRESENTANTE(3);

END;
/