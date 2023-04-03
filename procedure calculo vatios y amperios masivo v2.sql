CREATE OR REPLACE PROCEDURE conversiones.ejecucion_masiva_calculo_vatios_amperios_v2(
	cantidad_de_cada_producto_separado_por_coma text,
	id_producto_de_cada_producto_separado_por_coma text,
    usuario character varying,
	id_carga integer,
    voltaje_de_cada_producto_separado_por_coma text,
	v_tipo_tuberia_de_cada_producto_separado_por_coma text,
	v_conductor_de_cada_producto_separado_por_coma text,
	v_longitud_de_cada_producto_separado_por_coma text)
    LANGUAGE 'plpgsql'


AS $BODY$

DECLARE

	b	   record;

BEGIN
/* Borramos la table donde se almacena cantidad y productos*/
  execute ('Delete from conversiones.tabcampos');
  
---insert a select separador de cantidades y productos
	insert into conversiones.tabcampos  (cantidad, id_producto, voltaje, tipo_tuberia, conductor, longitud) 
	select CAST(regexp_split_to_table(cantidad_de_cada_producto_separado_por_coma, E',') AS integer), 
	(CAST(regexp_split_to_table(id_producto_de_cada_producto_separado_por_coma, E',') AS integer)),
    (CAST(regexp_split_to_table(voltaje_de_cada_producto_separado_por_coma, E',') AS integer)),
    (regexp_split_to_table(v_tipo_tuberia_de_cada_producto_separado_por_coma, E',')),
    (regexp_split_to_table(v_conductor_de_cada_producto_separado_por_coma, E',')),	
    (CAST(regexp_split_to_table(v_longitud_de_cada_producto_separado_por_coma, E',') AS integer));

	
	--for para recorrer las cantidades y productos
		for b in  
		--select separador de ids
		select * from conversiones.tabcampos order by 1 asc loop
			--ejecucion de la funcion de calculo por cada cantidad y id	 
			Call conversiones.calculo_vatios_amperios_v2(
				CAST(b.cantidad as integer),
				CAST(b.id_producto as integer),
				CAST(usuario AS varchar), 
				CAST(id_carga as integer),
			    CAST(b.voltaje as integer),
			    CAST(b.tipo_tuberia as varchar),
			    CAST(b.conductor as varchar),	 
				CAST(b.longitud as integer));
		end loop;
		

END;
$BODY$;
