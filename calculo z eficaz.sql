CREATE OR REPLACE FUNCTION conversiones.z_eficas_cobre_o_aluminio(
	v_calibre character,
	v_tipo_tuberia character,
	v_factor_proteccion double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

DECLARE
 v_conduit_xl real;
 v_conduit_r real;
 v_conduit_ia real;
 v_zeficaz real;

BEGIN
	--logica de calculo z eficaz  cobre o aluminio
 
	--calculo xl
	Select 
		case 
			when upper(v_tipo_tuberia)='PVC' then conduit_pvc
			when upper(v_tipo_tuberia)='IA'  then conduit_ia
			when upper(v_tipo_tuberia)='AC'  then conduit_de_acero
            else 0
		end        
	into v_conduit_xl
	from parametricas.XL_regulacion_de_conductores
	where calibre_awg_o_kcmil=v_calibre;
	
	
	--Resistencia en c.a. alambres de cobre descubiertos
	
	Select case 
		when upper(v_tipo_tuberia)='PVC' then conduit_pvc
		when upper(v_tipo_tuberia)='IA'  then conduit_ia
		when upper(v_tipo_tuberia)='AC'  then conduit_de_acero
        else 0
	end     
	into v_conduit_r	
	from parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores
	where calibre_awg_o_kcmil=v_calibre;
	

   -- Resistencia en c,a, alambres de aluminio

	
	Select case 
		when upper(v_tipo_tuberia)='PVC' then conduit_pvc
		when upper(v_tipo_tuberia)='IA'  then conduit_ia
		when upper(v_tipo_tuberia)='AC'  then conduit_de_acero
        else 0
	end     
	into  v_conduit_ia	
	from parametricas.resistencia_c_a_aluminio_regulacion_de_conductores
	where calibre_awg_o_kcmil=v_calibre;

   --logica de calculo z eficaz  cobre 
   v_zeficaz :=(v_conduit_r*v_factor_proteccion)+v_conduit_xl*(sin(acos(v_factor_proteccion)));


return v_zeficaz;

END
$BODY$;