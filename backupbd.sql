PGDMP     !                    {            databasekoncet #   14.6 (Ubuntu 14.6-0ubuntu0.22.04.1) #   14.6 (Ubuntu 14.6-0ubuntu0.22.04.1) y    ~           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16385    databasekoncet    DATABASE     c   CREATE DATABASE databasekoncet WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'es_CO.UTF-8';
    DROP DATABASE databasekoncet;
                automatizacion    false                        2615    16420    conversiones    SCHEMA        CREATE SCHEMA conversiones;
    DROP SCHEMA conversiones;
                automatizacion    false            �           0    0    SCHEMA conversiones    ACL     �   GRANT ALL ON SCHEMA conversiones TO pg_read_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA conversiones TO pg_write_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA conversiones TO postgres WITH GRANT OPTION;
                   automatizacion    false    5                        2615    16386    parametricas    SCHEMA        CREATE SCHEMA parametricas;
    DROP SCHEMA parametricas;
                automatizacion    false            �           0    0    SCHEMA parametricas    ACL     �   GRANT ALL ON SCHEMA parametricas TO pg_read_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA parametricas TO pg_write_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA parametricas TO postgres WITH GRANT OPTION;
                   automatizacion    false    4                        2615    16393 	   productos    SCHEMA        CREATE SCHEMA productos;
    DROP SCHEMA productos;
                automatizacion    false            �           0    0    SCHEMA productos    ACL     �   GRANT ALL ON SCHEMA productos TO pg_read_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA productos TO pg_write_all_data WITH GRANT OPTION;
GRANT ALL ON SCHEMA productos TO postgres WITH GRANT OPTION;
                   automatizacion    false    7            �            1255    16533 H   calculo_vatios_amperios_v1(integer, integer, character varying, integer) 	   PROCEDURE        CREATE PROCEDURE conversiones.calculo_vatios_amperios_v1(IN cantidad integer, IN id_producto integer, IN v_usuario character varying, IN id_carga integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
	d	   record;

BEGIN
/* insertamos lo actual conversiones.tabla1 en una tabla de log*/
  execute ('insert into conversiones.tabla1hist (descripcion, und, cantidad, va, potencia, voltaje, corriente, usuario_ejec_original, usuario_borrado, fecha_eje_original, fecha_borrado) 
		      select descripcion, und, cantidad, va, potencia, voltaje, corriente, usuario,'''|| v_usuario ||''', fecha, cast(substring(current_timestamp::text,1,19)as timestamp) 
		      from conversiones.tabla1
		      where idconv != '''|| id_carga ||'''');
/* Borramos la table donde se almacena cantidad y productos*/
  execute ('Delete from conversiones.tabla1 where idconv != '''|| id_carga ||'''');

	FOR d in
  
		  select p.descripcion,
			     p.unmed ,
			     f.va 
			from productos.productos p, 
				 parametricas.fichatec_watts f
			where p.id=f.id		
			and	  p.id in (id_producto) LOOP

	insert into conversiones.tabla1 Values(CAST(id_carga as integer), d.descripcion, d.unmed, cantidad, d.va, (cantidad*d.va), 120, ((cantidad*d.va)/120),v_usuario, cast(substring(current_timestamp::text,1,19)as timestamp));

	END LOOP;


END;
$$;
 �   DROP PROCEDURE conversiones.calculo_vatios_amperios_v1(IN cantidad integer, IN id_producto integer, IN v_usuario character varying, IN id_carga integer);
       conversiones          automatizacion    false    5            �            1255    16593 �   calculo_vatios_amperios_v2(integer, integer, character varying, integer, integer, character varying, character varying, integer) 	   PROCEDURE     J  CREATE PROCEDURE conversiones.calculo_vatios_amperios_v2(IN cantidad integer, IN id_producto integer, IN v_usuario character varying, IN id_carga integer, IN voltaje integer, IN v_tipo_tuberia character varying, IN v_conductor character varying, IN v_longitud integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
	d	   record;
	v_potencia   numeric; 
	v_calibre character varying;
	v_corriente real;
	factor_proteccion  float :=1.25;
	v_proteccion float;
	v_conduit float;
	v_porcent_regula real;
	redondeo real;
	v_intensidad_nominal character varying;
	v_mensaje  character varying;
	

BEGIN
/* insertamos lo actual conversiones.tabla1 en una tabla de log*/
  execute ('insert into conversiones.tabla1hist 
  (idconv_historico
	,descripcion
	, und
	, cantidad
	, va
	, potencia
	, voltaje
	, corriente
	, proteccion 
	, breaker 
	, fase 
	,neutro
	, tierra 
	, conduit 
	, conductor 
	, porcentaje_regula	   
	, longitud
	, usuario_ejec_original
	, usuario_borrado
	, fecha_eje_original
	, fecha_borrado) 
		      select 
				idconv
				,descripcion
				, und, cantidad
				, va, potencia
				, voltaje
				, corriente
				, proteccion 
				, breaker 
				, fase 
				, neutro
				, tierra 
				, conduit 
				, conductor 
		        , porcentaje_regula
				, longitud
				, usuario
				,'''|| v_usuario ||'''
				, fecha
				, cast(substring(current_timestamp::text,1,19)as timestamp)
		      from conversiones.tabla1
		      where idconv != '''|| id_carga ||'''');
/* Borramos la table donde se almacena cantidad y productos*/
  execute ('Delete from conversiones.tabla1 where idconv != '''|| id_carga ||'''');

	FOR d in
 		  select p.descripcion,
			     p.unmed ,
			     f.va 
			from productos.productos p, 
				 parametricas.fichatec_watts f
			where p.id=f.id		
			and	  p.id in (id_producto) LOOP
			
	--Calculos
	v_potencia  :=(cantidad*d.va);	
	v_corriente :=((cantidad*d.va)/120);
	v_proteccion :=(((cantidad*d.va)/120)*factor_proteccion);
	
	--logica BREAKER
	if v_proteccion > (Select max(intensidad_nominal) from  parametricas.unipolares_230_400v) then
	 v_intensidad_nominal:='Out'||ceiling(v_proteccion);
	 else 
		if voltaje = 120  then  
		--Asignacion breaker mas cercanos por encima
		select intensidad_nominal 
			into v_intensidad_nominal
		 from  parametricas.unipolares_230_400v 
		where intensidad_nominal >= ceiling(v_proteccion)
		limit 1;
    
--	if voltaje = 208 then
--	 v_mensaje:='BIPOLAR O TRIPOLAR';
--	else
	
--	 v_mensaje:='el voltaje no es correcto';
	 	end if;
	end if;	
	
 --logica de calibre cable	
 
	  select calibre_awg 
			into v_calibre
		from parametricas.calibres_de_cables
		where twg60º >= ceiling(v_proteccion)
		and calibre_awg <>'14'--por regulacion no puede ser calibre 14
		limit 1;

--logica calculo de % de regulacion


	
	Select 
		case 
		when v_tipo_tuberia='PVC' then conduit_pvc
		when v_tipo_tuberia='IA'  then conduit_ia
		when v_tipo_tuberia='AC'  then conduit_de_acero
		else '999999'
		end
		into v_conduit
		from  parametricas.regulacion_de_conductores 
		where tipo='Z eficaz para alambres de Cobre descubiertos a FP =0.85'
		and calibre_awg_o_kcmil=v_calibre ;
	
	v_porcent_regula :=((((v_conduit*(v_longitud*0.001000))*(v_potencia/voltaje)))/voltaje)*100;--%

  
	insert into conversiones.tabla1 Values
	(CAST(id_carga as integer)
	, d.descripcion
	, d.unmed
	, cantidad
	, d.va --watts
	, v_potencia--potencia
	, voltaje --voltaje
	, v_corriente --corriente
	, factor_proteccion
	, v_proteccion --proteccion
	, case 
	 	when v_intensidad_nominal like '%Out%' then v_intensidad_nominal
	    else '1X'||v_intensidad_nominal||'A' --breaker
	  end
	, v_calibre--fase
	, v_calibre--neutro
	, v_calibre--tierra
	, v_tipo_tuberia--conduit
	, v_conductor --conducor
	, v_porcent_regula --%de regulacion
	, v_longitud --longitud
	, v_usuario --usuario
	, cast(substring(current_timestamp::text,1,19)as timestamp));--fech y hora;

	END LOOP;


END;
$$;
   DROP PROCEDURE conversiones.calculo_vatios_amperios_v2(IN cantidad integer, IN id_producto integer, IN v_usuario character varying, IN id_carga integer, IN voltaje integer, IN v_tipo_tuberia character varying, IN v_conductor character varying, IN v_longitud integer);
       conversiones          automatizacion    false    5            �            1255    16465 G   ejecucion_masiva_calculo_vatios_amperios(text, text, character varying)    FUNCTION       CREATE FUNCTION conversiones.ejecucion_masiva_calculo_vatios_amperios(cantidad_de_cada_producto_separado_por_coma text, id_producto_de_cada_producto_separado_por_coma text, usuario character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

DECLARE
    texto  varchar := null;
	resultado integer;
	resultado1 integer;
	conteo integer;
	i	   record;
	b	   record;

BEGIN

	--for para recorrer y separar las cantidades
	for i in --1.. numero_peticiones loop
		--select separador de cantidades
		select CAST(regexp_split_to_table(cantidad_de_cada_producto_separado_por_coma, E',') AS integer) as resultado  loop
			--for para recorrer y separar los id  productos
			for b in  --1.. numero_peticiones loop
				--select separador de ids
				select  CAST(regexp_split_to_table(id_producto_de_cada_producto_separado_por_coma, E',') AS integer)as resultado1 loop
		     end loop;
		--ejecucion de la funcion de calculo por cada cantidad y id	 
	select conversiones.calculo_vatios_amperios(CAST(b.resultado1 as integer),CAST(b.resultado1 as integer),CAST(usuario as character varying));	 
	end loop;	

/*
	select into conteo count(*) from conversiones.tabla1;

		if conteo >0 then
			texto := 'OK';
		else
			texto := 'NO_OK';
		end if;
*/

	RETURN b.resultado1;

END;
$$;
 �   DROP FUNCTION conversiones.ejecucion_masiva_calculo_vatios_amperios(cantidad_de_cada_producto_separado_por_coma text, id_producto_de_cada_producto_separado_por_coma text, usuario character varying);
       conversiones          automatizacion    false    5            �            1255    16454 P   ejecucion_masiva_calculo_vatios_amperios(integer, text, text, character varying)    FUNCTION     $  CREATE FUNCTION conversiones.ejecucion_masiva_calculo_vatios_amperios(numero_peticiones integer, cantidad_de_cada_producto_separado_por_coma text, id_producto_de_cada_producto_separado_por_coma text, usuario character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

DECLARE
    texto  varchar := null;
	resultado integer;
	resultado1 integer;
	conteo integer;
	i	   record;
	b	   record;

BEGIN

for i in 1.. numero_peticiones loop
--separador de cantidades
select 
CAST(regexp_split_to_table(cantidad_de_cada_producto_separado_por_coma, E',') AS integer) as resultado;

	for b in  1.. numero_peticiones loop
	--separador de ids
	select  CAST(regexp_split_to_table(id_producto_de_cada_producto_separado_por_coma, E',') AS integer)as resultado1;
     end loop;
--ejecucion de la funcion	 
select conversiones.calculo_vatios_amperios(i.resultado,b.resultado1,usuario);	 
end loop;	


	select into conteo count(*) from conversiones.tabla1;

		if conteo >0 then
			texto := 'OK';
		else
			texto := 'NO_OK';
		end if;


	RETURN texto;

END;
$$;
 �   DROP FUNCTION conversiones.ejecucion_masiva_calculo_vatios_amperios(numero_peticiones integer, cantidad_de_cada_producto_separado_por_coma text, id_producto_de_cada_producto_separado_por_coma text, usuario character varying);
       conversiones          automatizacion    false    5            �            1255    16534 S   ejecucion_masiva_calculo_vatios_amperios_v1(text, text, character varying, integer) 	   PROCEDURE     h  CREATE PROCEDURE conversiones.ejecucion_masiva_calculo_vatios_amperios_v1(IN cantidad_de_cada_producto_separado_por_coma text, IN id_producto_de_cada_producto_separado_por_coma text, IN usuario character varying, IN id_carga integer)
    LANGUAGE plpgsql
    AS $$

DECLARE

	b	   record;

BEGIN
/* Borramos la table donde se almacena cantidad y productos*/
  execute ('Delete from conversiones.tabcampos');
  
---insert a select separador de cantidades y productos
	insert into conversiones.tabcampos  (cantidad, id_producto) 
	select CAST(regexp_split_to_table(cantidad_de_cada_producto_separado_por_coma, E',') AS integer), 
	(CAST(regexp_split_to_table(id_producto_de_cada_producto_separado_por_coma, E',') AS integer));


	--for para recorrer las cantidades y productos
		for b in  
		--select separador de ids
		select * from conversiones.tabcampos order by 1 asc loop
			--ejecucion de la funcion de calculo por cada cantidad y id	 
			Call conversiones.calculo_vatios_amperios_v1(CAST(b.cantidad as integer),CAST(b.id_producto as integer),CAST(usuario AS varchar), CAST(id_carga as integer));	 
		end loop;
		

END;
$$;
 �   DROP PROCEDURE conversiones.ejecucion_masiva_calculo_vatios_amperios_v1(IN cantidad_de_cada_producto_separado_por_coma text, IN id_producto_de_cada_producto_separado_por_coma text, IN usuario character varying, IN id_carga integer);
       conversiones          automatizacion    false    5            �            1255    16785 k   ejecucion_masiva_calculo_vatios_amperios_v2(text, text, character varying, integer, text, text, text, text) 	   PROCEDURE     �  CREATE PROCEDURE conversiones.ejecucion_masiva_calculo_vatios_amperios_v2(IN cantidad_de_cada_producto_separado_por_coma text, IN id_producto_de_cada_producto_separado_por_coma text, IN usuario character varying, IN id_carga integer, IN voltaje_de_cada_producto_separado_por_coma text, IN v_tipo_tuberia_de_cada_producto_separado_por_coma text, IN v_conductor_de_cada_producto_separado_por_coma text, IN v_longitud_de_cada_producto_separado_por_coma text)
    LANGUAGE plpgsql
    AS $$

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
$$;
 �  DROP PROCEDURE conversiones.ejecucion_masiva_calculo_vatios_amperios_v2(IN cantidad_de_cada_producto_separado_por_coma text, IN id_producto_de_cada_producto_separado_por_coma text, IN usuario character varying, IN id_carga integer, IN voltaje_de_cada_producto_separado_por_coma text, IN v_tipo_tuberia_de_cada_producto_separado_por_coma text, IN v_conductor_de_cada_producto_separado_por_coma text, IN v_longitud_de_cada_producto_separado_por_coma text);
       conversiones          automatizacion    false    5            �            1259    16779 	   tabcampos    TABLE     �   CREATE TABLE conversiones.tabcampos (
    id_tabla smallint NOT NULL,
    cantidad numeric,
    id_producto numeric,
    voltaje numeric,
    tipo_tuberia character varying(4),
    conductor character varying(3),
    longitud numeric
);
 #   DROP TABLE conversiones.tabcampos;
       conversiones         heap    automatizacion    false    5            �            1259    16778    tabcampos_id_tabla_seq    SEQUENCE     �   CREATE SEQUENCE conversiones.tabcampos_id_tabla_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE conversiones.tabcampos_id_tabla_seq;
       conversiones          automatizacion    false    219    5            �           0    0    tabcampos_id_tabla_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE conversiones.tabcampos_id_tabla_seq OWNED BY conversiones.tabcampos.id_tabla;
          conversiones          automatizacion    false    218            �            1259    16788    tabla1    TABLE     c  CREATE TABLE conversiones.tabla1 (
    idconv numeric NOT NULL,
    descripcion character varying(50),
    und character varying(3),
    cantidad numeric,
    va numeric,
    potencia numeric,
    voltaje numeric,
    corriente real,
    factor_proteccion real,
    proteccion real,
    breaker character varying(12),
    fase character varying(4),
    neutro character varying(4),
    tierra character varying(4),
    conduit character varying(4),
    conductor character varying(4),
    porcentaje_regula real,
    longitud numeric,
    usuario character varying(50),
    fecha timestamp without time zone
);
     DROP TABLE conversiones.tabla1;
       conversiones         heap    automatizacion    false    5            �           0    0    TABLE tabla1    COMMENT     m   COMMENT ON TABLE conversiones.tabla1 IS 'Esta es una tabla en donde se incluye la primera conversion NNNNN';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.idconv    COMMENT     L   COMMENT ON COLUMN conversiones.tabla1.idconv IS 'identificar del registro';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.descripcion    COMMENT     Q   COMMENT ON COLUMN conversiones.tabla1.descripcion IS 'descripcion del registro';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.und    COMMENT     N   COMMENT ON COLUMN conversiones.tabla1.und IS 'unidad de medida del registro';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.cantidad    COMMENT     K   COMMENT ON COLUMN conversiones.tabla1.cantidad IS 'cantidad de productos';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.va    COMMENT     E   COMMENT ON COLUMN conversiones.tabla1.va IS 'Potencia CTO (Vatios)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.voltaje    COMMENT     F   COMMENT ON COLUMN conversiones.tabla1.voltaje IS 'voltaje (voltios)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.corriente    COMMENT     K   COMMENT ON COLUMN conversiones.tabla1.corriente IS 'corriente (amperios)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.factor_proteccion    COMMENT     v   COMMENT ON COLUMN conversiones.tabla1.factor_proteccion IS 'factor_proteccion (el facor de protccion usado es 125%)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.proteccion    COMMENT     v   COMMENT ON COLUMN conversiones.tabla1.proteccion IS 'proteccion (multipicacion de corriente y factor de proteccion)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.breaker    COMMENT     �   COMMENT ON COLUMN conversiones.tabla1.breaker IS 'breaker (calculo de proxmidad superior de tabla breaker calculo intensidad nominal)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.fase    COMMENT     i   COMMENT ON COLUMN conversiones.tabla1.fase IS 'fase (calibre del cable, porregulacion el minimo es 12)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.neutro    COMMENT     U   COMMENT ON COLUMN conversiones.tabla1.neutro IS 'neutro (la proteccion del clable)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.tierra    COMMENT     J   COMMENT ON COLUMN conversiones.tabla1.tierra IS 'tierra (polo a tierra)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.conduit    COMMENT     N   COMMENT ON COLUMN conversiones.tabla1.conduit IS 'conduit (Tipo de tuberia)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.conductor    COMMENT     P   COMMENT ON COLUMN conversiones.tabla1.conductor IS 'conductor (Tipo de cable)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.porcentaje_regula    COMMENT     \   COMMENT ON COLUMN conversiones.tabla1.porcentaje_regula IS 'conductor (porcentaje_regula)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.longitud    COMMENT     S   COMMENT ON COLUMN conversiones.tabla1.longitud IS 'conductor (longitud de cable)';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.usuario    COMMENT     T   COMMENT ON COLUMN conversiones.tabla1.usuario IS 'usuario que ejecuta la consulta';
          conversiones          automatizacion    false    220            �           0    0    COLUMN tabla1.fecha    COMMENT     M   COMMENT ON COLUMN conversiones.tabla1.fecha IS 'fecha y hora de ejecuciòn';
          conversiones          automatizacion    false    220            �            1259    16795 
   tabla1hist    TABLE     �  CREATE TABLE conversiones.tabla1hist (
    idconv smallint NOT NULL,
    idconv_historico numeric,
    descripcion character varying(50),
    und character varying(3),
    cantidad numeric,
    va numeric,
    potencia numeric,
    voltaje numeric,
    corriente real,
    factor_proteccion real,
    proteccion real,
    breaker character varying(12),
    fase character varying(4),
    neutro character varying(4),
    tierra character varying(4),
    conduit character varying(4),
    conductor character varying(4),
    porcentaje_regula real,
    longitud numeric,
    usuario_ejec_original character varying(50),
    usuario_borrado character varying(50),
    fecha_eje_original timestamp without time zone,
    fecha_borrado timestamp without time zone
);
 $   DROP TABLE conversiones.tabla1hist;
       conversiones         heap    automatizacion    false    5            �           0    0    TABLE tabla1hist    COMMENT     r   COMMENT ON TABLE conversiones.tabla1hist IS 'Esta es una tabla en donde se incluye el historico de conversiones';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.idconv    COMMENT     Y   COMMENT ON COLUMN conversiones.tabla1hist.idconv IS 'iidconv (dentificar del registro)';
          conversiones          automatizacion    false    222            �           0    0 "   COLUMN tabla1hist.idconv_historico    COMMENT     v   COMMENT ON COLUMN conversiones.tabla1hist.idconv_historico IS 'idconv_historico (dentificar del registro hitsorico)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.descripcion    COMMENT     b   COMMENT ON COLUMN conversiones.tabla1hist.descripcion IS 'descripcion(descripcion del registro)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.und    COMMENT     X   COMMENT ON COLUMN conversiones.tabla1hist.und IS 'und (unidad de medida del registro)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.cantidad    COMMENT     Y   COMMENT ON COLUMN conversiones.tabla1hist.cantidad IS 'cantidad(cantidad de productos)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.va    COMMENT     L   COMMENT ON COLUMN conversiones.tabla1hist.va IS 'va (Potencia CTO Vatios)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.voltaje    COMMENT     J   COMMENT ON COLUMN conversiones.tabla1hist.voltaje IS 'voltaje (voltios)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.corriente    COMMENT     O   COMMENT ON COLUMN conversiones.tabla1hist.corriente IS 'corriente (amperios)';
          conversiones          automatizacion    false    222            �           0    0 #   COLUMN tabla1hist.factor_proteccion    COMMENT     z   COMMENT ON COLUMN conversiones.tabla1hist.factor_proteccion IS 'factor_proteccion (el facor de protccion usado es 125%)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.proteccion    COMMENT     z   COMMENT ON COLUMN conversiones.tabla1hist.proteccion IS 'proteccion (multipicacion de corriente y factor de proteccion)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.breaker    COMMENT     �   COMMENT ON COLUMN conversiones.tabla1hist.breaker IS 'breaker (calculo de proxmidad superior de tabla breaker calculo intensidad nominal)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.fase    COMMENT     m   COMMENT ON COLUMN conversiones.tabla1hist.fase IS 'fase (calibre del cable, porregulacion el minimo es 12)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.neutro    COMMENT     Y   COMMENT ON COLUMN conversiones.tabla1hist.neutro IS 'neutro (la proteccion del clable)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.tierra    COMMENT     N   COMMENT ON COLUMN conversiones.tabla1hist.tierra IS 'tierra (polo a tierra)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.conduit    COMMENT     R   COMMENT ON COLUMN conversiones.tabla1hist.conduit IS 'conduit (Tipo de tuberia)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.conductor    COMMENT     T   COMMENT ON COLUMN conversiones.tabla1hist.conductor IS 'conductor (Tipo de cable)';
          conversiones          automatizacion    false    222            �           0    0 #   COLUMN tabla1hist.porcentaje_regula    COMMENT     `   COMMENT ON COLUMN conversiones.tabla1hist.porcentaje_regula IS 'conductor (porcentaje_regula)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.longitud    COMMENT     W   COMMENT ON COLUMN conversiones.tabla1hist.longitud IS 'conductor (longitud de cable)';
          conversiones          automatizacion    false    222            �           0    0 '   COLUMN tabla1hist.usuario_ejec_original    COMMENT     �   COMMENT ON COLUMN conversiones.tabla1hist.usuario_ejec_original IS 'usuario_ejec_original(usuario que ejecuto la consulta original)';
          conversiones          automatizacion    false    222            �           0    0 !   COLUMN tabla1hist.usuario_borrado    COMMENT     p   COMMENT ON COLUMN conversiones.tabla1hist.usuario_borrado IS 'usuario_borrado(usuario que ejecuto el borrado)';
          conversiones          automatizacion    false    222            �           0    0 $   COLUMN tabla1hist.fecha_eje_original    COMMENT     {   COMMENT ON COLUMN conversiones.tabla1hist.fecha_eje_original IS 'fecha_eje_original(fecha y hora de ejecuciòn original)';
          conversiones          automatizacion    false    222            �           0    0    COLUMN tabla1hist.fecha_borrado    COMMENT     e   COMMENT ON COLUMN conversiones.tabla1hist.fecha_borrado IS 'fecha_borrado(fecha y hora de borrado)';
          conversiones          automatizacion    false    222            �            1259    16794    tabla1hist_idconv_seq    SEQUENCE     �   CREATE SEQUENCE conversiones.tabla1hist_idconv_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE conversiones.tabla1hist_idconv_seq;
       conversiones          automatizacion    false    222    5            �           0    0    tabla1hist_idconv_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE conversiones.tabla1hist_idconv_seq OWNED BY conversiones.tabla1hist.idconv;
          conversiones          automatizacion    false    221            �            1259    16604    calibres_de_cables    TABLE     �   CREATE TABLE parametricas.calibres_de_cables (
    calibre_awg character varying(3),
    "twg60º" numeric,
    "rhw_thw_yhwn_75º" numeric,
    thhn_xhhw_2_thwn_2 numeric
);
 ,   DROP TABLE parametricas.calibres_de_cables;
       parametricas         heap    automatizacion    false    4            �           0    0    TABLE calibres_de_cables    COMMENT     �   COMMENT ON TABLE parametricas.calibres_de_cables IS 'Esta contiene las asignacion del calibre  del cable segun la temperatura';
          parametricas          automatizacion    false    216            �           0    0 %   COLUMN calibres_de_cables.calibre_awg    COMMENT     V   COMMENT ON COLUMN parametricas.calibres_de_cables.calibre_awg IS 'Calibre del cable';
          parametricas          automatizacion    false    216            �           0    0 #   COLUMN calibres_de_cables."twg60º"    COMMENT     \   COMMENT ON COLUMN parametricas.calibres_de_cables."twg60º" IS 'Nivel de temperatura 60º';
          parametricas          automatizacion    false    216            �           0    0 -   COLUMN calibres_de_cables."rhw_thw_yhwn_75º"    COMMENT     d   COMMENT ON COLUMN parametricas.calibres_de_cables."rhw_thw_yhwn_75º" IS 'Nivel e temperatra 75º';
          parametricas          automatizacion    false    216            �           0    0 ,   COLUMN calibres_de_cables.thhn_xhhw_2_thwn_2    COMMENT     e   COMMENT ON COLUMN parametricas.calibres_de_cables.thhn_xhhw_2_thwn_2 IS 'Nivel de temperatura 90º';
          parametricas          automatizacion    false    216            �            1259    16387    fichatec_watts    TABLE     V   CREATE TABLE parametricas.fichatec_watts (
    id numeric NOT NULL,
    va numeric
);
 (   DROP TABLE parametricas.fichatec_watts;
       parametricas         heap    automatizacion    false    4            �           0    0    TABLE fichatec_watts    COMMENT     }   COMMENT ON TABLE parametricas.fichatec_watts IS 'Esta es una tabla en donde se incluyen los valores watts de los productos';
          parametricas          automatizacion    false    212            �           0    0    COLUMN fichatec_watts.id    COMMENT     U   COMMENT ON COLUMN parametricas.fichatec_watts.id IS 'identificar de producto-watts';
          parametricas          automatizacion    false    212            �           0    0    COLUMN fichatec_watts.va    COMMENT     V   COMMENT ON COLUMN parametricas.fichatec_watts.va IS 'watts relacionados al producto';
          parametricas          automatizacion    false    212            �            1259    16621    regulacion_de_conductores    TABLE     �   CREATE TABLE parametricas.regulacion_de_conductores (
    calibre_awg_o_kcmil character varying(4),
    tipo character varying(60),
    conduit_pvc real,
    conduit_ia real,
    conduit_de_acero real
);
 3   DROP TABLE parametricas.regulacion_de_conductores;
       parametricas         heap    automatizacion    false    4            �           0    0    TABLE regulacion_de_conductores    COMMENT     �   COMMENT ON TABLE parametricas.regulacion_de_conductores IS 'Esta tabla contiene la regulacion_de_conductores por calibre y tipo de resistencia';
          parametricas          automatizacion    false    217            �           0    0 4   COLUMN regulacion_de_conductores.calibre_awg_o_kcmil    COMMENT     e   COMMENT ON COLUMN parametricas.regulacion_de_conductores.calibre_awg_o_kcmil IS 'Calibre del cable';
          parametricas          automatizacion    false    217            �           0    0 %   COLUMN regulacion_de_conductores.tipo    COMMENT     X   COMMENT ON COLUMN parametricas.regulacion_de_conductores.tipo IS 'Tipo de resistencia';
          parametricas          automatizacion    false    217            �           0    0 ,   COLUMN regulacion_de_conductores.conduit_pvc    COMMENT     m   COMMENT ON COLUMN parametricas.regulacion_de_conductores.conduit_pvc IS 'Indicador para conductor en pvcº';
          parametricas          automatizacion    false    217            �           0    0 +   COLUMN regulacion_de_conductores.conduit_ia    COMMENT     i   COMMENT ON COLUMN parametricas.regulacion_de_conductores.conduit_ia IS 'Indicador para conductor en ia';
          parametricas          automatizacion    false    217            �           0    0 1   COLUMN regulacion_de_conductores.conduit_de_acero    COMMENT     r   COMMENT ON COLUMN parametricas.regulacion_de_conductores.conduit_de_acero IS 'Indicador para conductor en acero';
          parametricas          automatizacion    false    217            �            1259    16583    unipolares_230_400v    TABLE     �   CREATE TABLE parametricas.unipolares_230_400v (
    emb numeric,
    curvac character varying(8),
    intensidad_nominal numeric,
    modulo17_5mm numeric
);
 -   DROP TABLE parametricas.unipolares_230_400v;
       parametricas         heap    automatizacion    false    4            �           0    0    TABLE unipolares_230_400v    COMMENT     �   COMMENT ON TABLE parametricas.unipolares_230_400v IS 'Esta contiene las asignacion de la intensidad nomina asignad al breaker';
          parametricas          automatizacion    false    214            �           0    0    COLUMN unipolares_230_400v.emb    COMMENT     R   COMMENT ON COLUMN parametricas.unipolares_230_400v.emb IS 'Pendiente definicion';
          parametricas          automatizacion    false    214            �           0    0 !   COLUMN unipolares_230_400v.curvac    COMMENT     U   COMMENT ON COLUMN parametricas.unipolares_230_400v.curvac IS 'Pendiente definicion';
          parametricas          automatizacion    false    214            �           0    0 -   COLUMN unipolares_230_400v.intensidad_nominal    COMMENT     d   COMMENT ON COLUMN parametricas.unipolares_230_400v.intensidad_nominal IS 'intensidad de corriente';
          parametricas          automatizacion    false    214            �           0    0 '   COLUMN unipolares_230_400v.modulo17_5mm    COMMENT     X   COMMENT ON COLUMN parametricas.unipolares_230_400v.modulo17_5mm IS 'Cantidad de hilos';
          parametricas          automatizacion    false    214            �            1259    16588    unipolares_neutro_230v    TABLE     �   CREATE TABLE parametricas.unipolares_neutro_230v (
    emb numeric,
    curvac character varying(8),
    intensidad_nominal numeric,
    modulo17_5mm numeric
);
 0   DROP TABLE parametricas.unipolares_neutro_230v;
       parametricas         heap    automatizacion    false    4            �           0    0    TABLE unipolares_neutro_230v    COMMENT     �   COMMENT ON TABLE parametricas.unipolares_neutro_230v IS 'Esta contiene las asignacion de la intensidad nomina asignad al breaker';
          parametricas          automatizacion    false    215            �           0    0 !   COLUMN unipolares_neutro_230v.emb    COMMENT     U   COMMENT ON COLUMN parametricas.unipolares_neutro_230v.emb IS 'Pendiente definicion';
          parametricas          automatizacion    false    215            �           0    0 $   COLUMN unipolares_neutro_230v.curvac    COMMENT     X   COMMENT ON COLUMN parametricas.unipolares_neutro_230v.curvac IS 'Pendiente definicion';
          parametricas          automatizacion    false    215            �           0    0 0   COLUMN unipolares_neutro_230v.intensidad_nominal    COMMENT     g   COMMENT ON COLUMN parametricas.unipolares_neutro_230v.intensidad_nominal IS 'intensidad de corriente';
          parametricas          automatizacion    false    215            �           0    0 *   COLUMN unipolares_neutro_230v.modulo17_5mm    COMMENT     [   COMMENT ON COLUMN parametricas.unipolares_neutro_230v.modulo17_5mm IS 'Cantidad de hilos';
          parametricas          automatizacion    false    215            �            1259    16405 	   productos    TABLE     �   CREATE TABLE productos.productos (
    id numeric NOT NULL,
    descripcion character varying(50),
    unmed character varying(3)
);
     DROP TABLE productos.productos;
    	   productos         heap    automatizacion    false    7            �           0    0    TABLE productos    COMMENT     �   COMMENT ON TABLE productos.productos IS 'Esta es una tabla en donde se incluyen los productos, su descripcion y unidad de medida';
       	   productos          automatizacion    false    213            �           0    0    COLUMN productos.id    COMMENT     G   COMMENT ON COLUMN productos.productos.id IS 'identificar de producto';
       	   productos          automatizacion    false    213            �           0    0    COLUMN productos.descripcion    COMMENT     P   COMMENT ON COLUMN productos.productos.descripcion IS 'descripcion de producto';
       	   productos          automatizacion    false    213            �           0    0    COLUMN productos.unmed    COMMENT     P   COMMENT ON COLUMN productos.productos.unmed IS 'unidad de medida del producto';
       	   productos          automatizacion    false    213            �           2604    16782    tabcampos id_tabla    DEFAULT     �   ALTER TABLE ONLY conversiones.tabcampos ALTER COLUMN id_tabla SET DEFAULT nextval('conversiones.tabcampos_id_tabla_seq'::regclass);
 G   ALTER TABLE conversiones.tabcampos ALTER COLUMN id_tabla DROP DEFAULT;
       conversiones          automatizacion    false    219    218    219            �           2604    16798    tabla1hist idconv    DEFAULT     �   ALTER TABLE ONLY conversiones.tabla1hist ALTER COLUMN idconv SET DEFAULT nextval('conversiones.tabla1hist_idconv_seq'::regclass);
 F   ALTER TABLE conversiones.tabla1hist ALTER COLUMN idconv DROP DEFAULT;
       conversiones          automatizacion    false    222    221    222            x          0    16779 	   tabcampos 
   TABLE DATA           v   COPY conversiones.tabcampos (id_tabla, cantidad, id_producto, voltaje, tipo_tuberia, conductor, longitud) FROM stdin;
    conversiones          automatizacion    false    219   ��       y          0    16788    tabla1 
   TABLE DATA           �   COPY conversiones.tabla1 (idconv, descripcion, und, cantidad, va, potencia, voltaje, corriente, factor_proteccion, proteccion, breaker, fase, neutro, tierra, conduit, conductor, porcentaje_regula, longitud, usuario, fecha) FROM stdin;
    conversiones          automatizacion    false    220   1�       {          0    16795 
   tabla1hist 
   TABLE DATA           <  COPY conversiones.tabla1hist (idconv, idconv_historico, descripcion, und, cantidad, va, potencia, voltaje, corriente, factor_proteccion, proteccion, breaker, fase, neutro, tierra, conduit, conductor, porcentaje_regula, longitud, usuario_ejec_original, usuario_borrado, fecha_eje_original, fecha_borrado) FROM stdin;
    conversiones          automatizacion    false    222   
�       u          0    16604    calibres_de_cables 
   TABLE DATA           s   COPY parametricas.calibres_de_cables (calibre_awg, "twg60º", "rhw_thw_yhwn_75º", thhn_xhhw_2_thwn_2) FROM stdin;
    parametricas          automatizacion    false    216   P�       q          0    16387    fichatec_watts 
   TABLE DATA           6   COPY parametricas.fichatec_watts (id, va) FROM stdin;
    parametricas          automatizacion    false    212   Ǹ       v          0    16621    regulacion_de_conductores 
   TABLE DATA              COPY parametricas.regulacion_de_conductores (calibre_awg_o_kcmil, tipo, conduit_pvc, conduit_ia, conduit_de_acero) FROM stdin;
    parametricas          automatizacion    false    217   ��       s          0    16583    unipolares_230_400v 
   TABLE DATA           b   COPY parametricas.unipolares_230_400v (emb, curvac, intensidad_nominal, modulo17_5mm) FROM stdin;
    parametricas          automatizacion    false    214   �       t          0    16588    unipolares_neutro_230v 
   TABLE DATA           e   COPY parametricas.unipolares_neutro_230v (emb, curvac, intensidad_nominal, modulo17_5mm) FROM stdin;
    parametricas          automatizacion    false    215   k�       r          0    16405 	   productos 
   TABLE DATA           >   COPY productos.productos (id, descripcion, unmed) FROM stdin;
 	   productos          automatizacion    false    213   ��       �           0    0    tabcampos_id_tabla_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('conversiones.tabcampos_id_tabla_seq', 12, true);
          conversiones          automatizacion    false    218            �           0    0    tabla1hist_idconv_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('conversiones.tabla1hist_idconv_seq', 5, true);
          conversiones          automatizacion    false    221            �           2606    16802    tabla1hist tabla1hist_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY conversiones.tabla1hist
    ADD CONSTRAINT tabla1hist_pkey PRIMARY KEY (idconv);
 J   ALTER TABLE ONLY conversiones.tabla1hist DROP CONSTRAINT tabla1hist_pkey;
       conversiones            automatizacion    false    222            �           2606    16414 "   fichatec_watts fichatec_watts_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY parametricas.fichatec_watts
    ADD CONSTRAINT fichatec_watts_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY parametricas.fichatec_watts DROP CONSTRAINT fichatec_watts_pkey;
       parametricas            automatizacion    false    212            �           2606    16412    productos productos_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY productos.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);
 E   ALTER TABLE ONLY productos.productos DROP CONSTRAINT productos_pkey;
    	   productos            automatizacion    false    213            �           1259    16793 
   idk_idconv    INDEX     E   CREATE INDEX idk_idconv ON conversiones.tabla1 USING btree (idconv);
 $   DROP INDEX conversiones.idk_idconv;
       conversiones            automatizacion    false    220            �           1259    16803    idkh_idconv    INDEX     J   CREATE INDEX idkh_idconv ON conversiones.tabla1hist USING btree (idconv);
 %   DROP INDEX conversiones.idkh_idconv;
       conversiones            automatizacion    false    222            �           1259    16392    idk_id    INDEX     E   CREATE INDEX idk_id ON parametricas.fichatec_watts USING btree (id);
     DROP INDEX parametricas.idk_id;
       parametricas            automatizacion    false    212            �           1259    16410    idk_idproduct    INDEX     D   CREATE INDEX idk_idproduct ON productos.productos USING btree (id);
 $   DROP INDEX productos.idk_idproduct;
    	   productos            automatizacion    false    213            �           2606    16415    fichatec_watts fich_ptoduct_fk    FK CONSTRAINT     �   ALTER TABLE ONLY parametricas.fichatec_watts
    ADD CONSTRAINT fich_ptoduct_fk FOREIGN KEY (id) REFERENCES productos.productos(id);
 N   ALTER TABLE ONLY parametricas.fichatec_watts DROP CONSTRAINT fich_ptoduct_fk;
       parametricas          automatizacion    false    212    213    3296            x   4   x�34��4�442�s�t.�45�24�4�4B4
8�QTr��qqq �>^      y   �   x������@�s����'���ۢGA��A�2[XaU���;mœ��0!��c
�u�����"y#�����K#��g>r���eO¡�;��Rݒ���fЅ��k�����tm�Ss�*	qP�mҠ������K_U����>����I]{J����D�k`�q�|�d[ɮB�6}g�/�x>>��}�(�XH      {   6  x���?O�0��˧茄�?vlgC� �J(J#�D[)4ߟ�cZQe�}�p��~~��wc��~��}w6]��58�T�u�7V�@�L���y{�������hH"S���~�v�����,ר��ǆ볞`��b�!xx���j�D�`ĂS`�U�w�[m�:ax+b���Ȃ�z�Xj�U2A��m��M�;��T0 �/(�C�`�Ka�����E4v�������_R֙ :8A9o8R]���`�<9�!�)(��J_�j��G!{$l�G>�����մB�����X �_3#y�s�X�V���_����      u   g   x�-���0B�aM�iu��C���Br�Gd}b
�O���'F����YXŁ8W�h��)�ҧ�����]�e_A���ٯ9=�.�$W�l�|��7�"��      q      x�3�41�2�4�0�2�4550������ (�D      v     x������6���S�L �!/D)� �� pn���	v�M�>����$�
�ԜC-%}��h{������r~]����ӧuz�~�ަ'��<-_>�����:������sU #�b;��
j�?��
��q�
Z���M�,�h�F+��jC�0�Q7M����ڦA�#N�t��y�jB���#V���ܘG5jxT�Ȩ����>2jo��=`�����?b�M�:?�k�V�V7uZh{z��.����|Y��y:�[�UG�9_�
/n�/����v������6���M�B���	�n �=TA�L�����X��	�p C� M�ЃQ҃I�3B���q��V%f���ia�ׄб �Z�P����O��"�u,HQP^�ۡ�R�a�w��E�s��XP�Tn/�l;|G*�8��CA*qU
R��ǂ�
� Os��q>�dc��7��������z��[��!y5!�q�N9��7��wuZ����uu���	��o�����@s�4�pY��@��5a0�:��'F����ng.ܧo%џC������v�L��,�v��v�W"<����K��np�8��hN�"�bgo�*�]��,^v�a�e���d�Θ�[1�>��]��zǇ�bgW1����`��<�W6����~��������������L��>��>�S��7IDMr҅&���I&-,� ,G� �,U"�s4HK\%�1>�JF�S�:�5;RZ���W���0x<�V��io	��
+�J�O���@�>�f��TH��h~ -�5#��>��9�+�S>+3��L��$����[�K���;����T��I�-�w��J�S�\��7��-�Si�����bbz-�l��n��Q7�,�ݬ7���%�Y q�Te�Nv��t��f�0�@7٬�ݬ�nM6넑E�T���?�F�FO�~�S'�4MvꄑF����	#��&;u�IS�$	�nc�S��D��oX�;��	4��ʔݮN`)�Ң�����'Vy�S.���K<�'.�PT
u�`8���.�x� �� ��B�      s   ?   x�34�4�706�77�4�4�2��M9�ld�4�
sN#T�F�(���F�@HK� q��      t   @   x�3�4�706��0�4�4�2�qM9��f��(��F(��F��|KNc#$���	H}� �h�      r   @   x�3��)�U03�23��K�2���ML�/*�L�+I�s��&g$Ƨ�&�e&'�Ec���� KU�     