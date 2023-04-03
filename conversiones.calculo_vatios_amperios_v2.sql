CREATE OR REPLACE PROCEDURE conversiones.calculo_vatios_amperios_v2(
	cantidad integer,
	id_producto integer,
    v_usuario character varying,
    id_carga integer,
	voltaje integer,
	v_tipo_tuberia character varying,
	v_conductor character varying,
	v_longitud integer)
    LANGUAGE 'plpgsql'

AS $BODY$

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
$BODY$;