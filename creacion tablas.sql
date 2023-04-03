----crear de tablas productos 
create table productos.productos
(id           numeric ,
 descripcion  varchar(50),
 unmed        varchar(3));

comment on column productos.productos.id is 'identificar de producto'; 
comment on column productos.productos.descripcion is 'descripcion de producto';
comment on column productos.productos.unmed is 'unidad de medida del producto';

ALTER TABLE IF EXISTS productos.productos
    OWNER to automatizacion;	
COMMENT ON TABLE productos.productos
IS 'Esta es una tabla en donde se incluyen los productos, su descripcion y unidad de medida';

CREATE INDEX idk_idproduct ON productos.productos (id);

--llave primaria
ALTER TABLE productos.productos ADD PRIMARY KEY (id);

---insercion

insert into productos.productos Values(1,'Lum 60*60','Und');
insert into productos.productos Values(2,'Tomacorriente','Und');
insert into productos.productos Values(3,'Ducha_electrica','Und');
insert into productos.productos Values(4,'Motor 1 HP','Und');
insert into productos.productos Values(5,'Regulador de voltaje','Und');
insert into productos.productos Values(6,'Lampara Led Circular','Und');





----crear de tablas parametricas 
create table parametricas.fichatec_watts
(id           numeric ,
 va           numeric );
comment on column parametricas.fichatec_watts.id is 'identificar de producto-watts'; 
comment on column parametricas.fichatec_watts.va is 'watts relacionados al producto';
ALTER TABLE IF EXISTS parametricas.fichatec_watts
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.fichatec_watts
IS 'Esta es una tabla en donde se incluyen los valores watts de los productos';

CREATE INDEX idk_id ON parametricas.fichatec_watts (id);

--llave primaria
ALTER TABLE parametricas.fichatec_watts ADD PRIMARY KEY (id);

--foranea
ALTER TABLE parametricas.fichatec_watts 
	ADD CONSTRAINT fich_ptoduct_fk FOREIGN KEY (id) 
	REFERENCES productos.productos (id);

---insercion

insert into parametricas.fichatec_watts  Values(1,45);
insert into parametricas.fichatec_watts  Values(2,180);
insert into parametricas.fichatec_watts  Values(3,5500);
insert into parametricas.fichatec_watts  Values(4,746);
insert into parametricas.fichatec_watts  Values(5,400);
insert into parametricas.fichatec_watts  Values(6,18);


CREATE TABLE IF NOT EXISTS conversiones.tabla1
(
    idconv numeric NOT NULL,
    descripcion character varying(50) COLLATE pg_catalog."default",
    und character varying(3) COLLATE pg_catalog."default",
    cantidad numeric,
    va numeric,
    potencia numeric,
    voltaje numeric,
    corriente real,
	factor_proteccion real,
	proteccion real,
	breaker  character varying(12),
	fase character varying(4),
	neutro character varying(4),
	tierra character varying(4),
	conduit character varying(4),
	conductor character varying(4),
	porcentaje_regula  real,
	longitud numeric,
    usuario character varying(50) COLLATE pg_catalog."default",
    fecha timestamp without time zone
   -- CONSTRAINT tabla1_pkey PRIMARY KEY (idconv)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS conversiones.tabla1
    OWNER to automatizacion;

COMMENT ON TABLE conversiones.tabla1
    IS 'Esta es una tabla en donde se incluye la primera conversion NNNNN';

COMMENT ON COLUMN conversiones.tabla1.idconv
    IS 'identificar del registro';

COMMENT ON COLUMN conversiones.tabla1.descripcion
    IS 'descripcion del registro';

COMMENT ON COLUMN conversiones.tabla1.und
    IS 'unidad de medida del registro';

COMMENT ON COLUMN conversiones.tabla1.cantidad
    IS 'cantidad de productos';

COMMENT ON COLUMN conversiones.tabla1.va
    IS 'Potencia CTO (Vatios)';

COMMENT ON COLUMN conversiones.tabla1.voltaje
    IS 'voltaje (voltios)';

COMMENT ON COLUMN conversiones.tabla1.corriente
    IS 'corriente (amperios)';
	
COMMENT ON COLUMN conversiones.tabla1.factor_proteccion
    IS 'factor_proteccion (el facor de protccion usado es 125%)';

COMMENT ON COLUMN conversiones.tabla1.proteccion
    IS 'proteccion (multipicacion de corriente y factor de proteccion)';

COMMENT ON COLUMN conversiones.tabla1.breaker
    IS 'breaker (calculo de proxmidad superior de tabla breaker calculo intensidad nominal)';
	
COMMENT ON COLUMN conversiones.tabla1.fase
    IS 'fase (calibre del cable, porregulacion el minimo es 12)';

COMMENT ON COLUMN conversiones.tabla1.neutro
    IS 'neutro (la proteccion del clable)';

COMMENT ON COLUMN conversiones.tabla1.tierra
    IS 'tierra (polo a tierra)';

COMMENT ON COLUMN conversiones.tabla1.conduit
    IS 'conduit (Tipo de tuberia)';

COMMENT ON COLUMN conversiones.tabla1.conductor
    IS 'conductor (Tipo de cable)';

COMMENT ON COLUMN conversiones.tabla1.porcentaje_regula
    IS 'conductor (porcentaje_regula)';
	
COMMENT ON COLUMN conversiones.tabla1.longitud
    IS 'conductor (longitud de cable)';	

COMMENT ON COLUMN conversiones.tabla1.usuario
    IS 'usuario que ejecuta la consulta';

COMMENT ON COLUMN conversiones.tabla1.fecha
    IS 'fecha y hora de ejecuciòn';
-- Index: idk_idconv

-- DROP INDEX IF EXISTS conversiones.idk_idconv;

CREATE INDEX IF NOT EXISTS idk_idconv
    ON conversiones.tabla1 USING btree
    (idconv ASC NULLS LAST)
    TABLESPACE pg_default;


---


CREATE TABLE IF NOT EXISTS conversiones.tabla1hist
(
    idconv smallserial NOT NULL,
	idconv_historico numeric,
    descripcion character varying(50) COLLATE pg_catalog."default",
    und character varying(3) COLLATE pg_catalog."default",
    cantidad numeric,
    va numeric,
    potencia numeric,
    voltaje numeric,
    corriente real,
	factor_proteccion real,
	proteccion real,
	breaker  character varying(12),
	fase character varying(4),
	neutro character varying(4),
	tierra character varying(4),
	conduit character varying(4),
	conductor character varying(4),
	porcentaje_regula  real,
	longitud numeric,
    usuario_ejec_original character varying(50) COLLATE pg_catalog."default",
	usuario_borrado character varying(50) COLLATE pg_catalog."default",
    fecha_eje_original timestamp without time zone,
    fecha_borrado timestamp without time zone,
    CONSTRAINT tabla1hist_pkey PRIMARY KEY (idconv)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS conversiones.tabla1hist
    OWNER to automatizacion;

COMMENT ON TABLE conversiones.tabla1hist
    IS 'Esta es una tabla en donde se incluye el historico de conversiones';

COMMENT ON COLUMN conversiones.tabla1hist.idconv
    IS 'iidconv (dentificar del registro)';

COMMENT ON COLUMN conversiones.tabla1hist.idconv_historico
    IS 'idconv_historico (dentificar del registro hitsorico)';	

COMMENT ON COLUMN conversiones.tabla1hist.descripcion
    IS 'descripcion(descripcion del registro)';

COMMENT ON COLUMN conversiones.tabla1hist.und
    IS 'und (unidad de medida del registro)';

COMMENT ON COLUMN conversiones.tabla1hist.cantidad
    IS 'cantidad(cantidad de productos)';

COMMENT ON COLUMN conversiones.tabla1hist.va
    IS 'va (Potencia CTO Vatios)';

COMMENT ON COLUMN conversiones.tabla1hist.voltaje
    IS 'voltaje (voltios)';

COMMENT ON COLUMN conversiones.tabla1hist.corriente
    IS 'corriente (amperios)';
	
	
COMMENT ON COLUMN conversiones.tabla1hist.factor_proteccion
    IS 'factor_proteccion (el facor de protccion usado es 125%)';

COMMENT ON COLUMN conversiones.tabla1hist.proteccion
    IS 'proteccion (multipicacion de corriente y factor de proteccion)';

COMMENT ON COLUMN conversiones.tabla1hist.breaker
    IS 'breaker (calculo de proxmidad superior de tabla breaker calculo intensidad nominal)';
	
COMMENT ON COLUMN conversiones.tabla1hist.fase
    IS 'fase (calibre del cable, porregulacion el minimo es 12)';

COMMENT ON COLUMN conversiones.tabla1hist.neutro
    IS 'neutro (la proteccion del clable)';

COMMENT ON COLUMN conversiones.tabla1hist.tierra
    IS 'tierra (polo a tierra)';

COMMENT ON COLUMN conversiones.tabla1hist.conduit
    IS 'conduit (Tipo de tuberia)';

COMMENT ON COLUMN conversiones.tabla1hist.conductor
    IS 'conductor (Tipo de cable)';


COMMENT ON COLUMN conversiones.tabla1hist.porcentaje_regula
    IS 'conductor (porcentaje_regula)';	
	
COMMENT ON COLUMN conversiones.tabla1hist.longitud
    IS 'conductor (longitud de cable)';	
	
COMMENT ON COLUMN conversiones.tabla1hist.usuario_ejec_original
    IS 'usuario_ejec_original(usuario que ejecuto la consulta original)';

COMMENT ON COLUMN conversiones.tabla1hist.usuario_borrado
    IS 'usuario_borrado(usuario que ejecuto el borrado)';

COMMENT ON COLUMN conversiones.tabla1hist.fecha_eje_original
    IS 'fecha_eje_original(fecha y hora de ejecuciòn original)';

COMMENT ON COLUMN conversiones.tabla1hist.fecha_borrado
    IS 'fecha_borrado(fecha y hora de borrado)';
-- Index: idk_idconv

-- DROP INDEX IF EXISTS conversiones.idkh_idconv;

CREATE INDEX IF NOT EXISTS idkh_idconv
    ON conversiones.tabla1hist USING btree
    (idconv ASC NULLS LAST)
    TABLESPACE pg_default;



	


--

CREATE TABLE IF NOT EXISTS conversiones.tabcampos
(
    id_tabla smallserial,-- NOT NULL,
    cantidad numeric,
    id_producto numeric,
	 voltaje numeric,
	 tipo_tuberia character varying(4), 
	 conductor character varying(3), 
	 longitud numeric);


----crear de tablas parametricas monopolares

create table parametricas.monopolares
(empaque        numeric ,
 referencia     character varying(8),
 polos			numeric,
 Intensidad_nominal  numeric);
 
comment on column parametricas.monopolares.empaque is 'Empaque asignado al breaker'; 
comment on column parametricas.monopolares.referencia is 'codigo de referencia asignado';
comment on column parametricas.monopolares.polos  is 'cabtidad de hilos';
comment on column parametricas.monopolares.Intensidad_nominal  is 'Corriente nominal';
ALTER TABLE IF EXISTS parametricas.monopolares
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.monopolares
IS 'Esta contiene las asignacion de la intensidad nomina asignad al breaker conforme con los requisitos de norma UL 489';



---insercion

insert into parametricas.monopolares  Values (12,'DSE-1015',1,15);
insert into parametricas.monopolares  Values (12,'DSE-1020',1,20);
insert into parametricas.monopolares  Values (12,'DSE-1030',1,30);
insert into parametricas.monopolares  Values (12,'DSE-1040',1,40);
insert into parametricas.monopolares  Values (12,'DSE-1050',1,50);
insert into parametricas.monopolares  Values (12,'DSE-1060',1,60);
insert into parametricas.monopolares  Values (12,'DSE-1070',1,70);
insert into parametricas.monopolares  Values (12,'DSE-1090',1,90);
insert into parametricas.monopolares  Values (12,'DSE-1100',1,100);





----crear de tablas parametricas bipolares

--create table parametricas.Unipolares_neutro_230v
create table parametricas.bipolares
(empaque        numeric ,
 referencia     character varying(8),
 polos			numeric,
 Intensidad_nominal  numeric);
 
comment on column parametricas.bipolares.empaque is 'Empaque asignado al breaker'; 
comment on column parametricas.bipolares.referencia is 'codigo de referencia asignado';
comment on column parametricas.bipolares.polos  is 'cantidad de hilos';
comment on column parametricas.bipolares.Intensidad_nominal  is 'Corriente nominal';
ALTER TABLE IF EXISTS parametricas.bipolares
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.bipolares
IS 'Esta contiene las asignacion de la intensidad nomina asignad al breaker conforme con los requisitos de norma UL 489';


---insercion

insert into parametricas.bipolares  Values (3,'DSE-2015',1,15);
insert into parametricas.bipolares  Values (3,'DSE-2020',1,20);
insert into parametricas.bipolares  Values (3,'DSE-2030',1,30);
insert into parametricas.bipolares  Values (3,'DSE-2040',1,40);
insert into parametricas.bipolares  Values (3,'DSE-2050',1,50);
insert into parametricas.bipolares  Values (3,'DSE-2060',1,60);
insert into parametricas.bipolares  Values (3,'DSE-2070',1,70);
insert into parametricas.bipolares  Values (3,'DSE-2090',1,90);
insert into parametricas.bipolares  Values (3,'DSE-2100',1,100);





----crear de tablas CALIBRE DE CABLES ELECTRICOS

create table parametricas.calibres_de_cables
(calibre_awg           character varying(3),
 twg60º                  numeric,
 rhw_thw_yhwn_75º  numeric,
 thhn_xhhw_2_thwn_2    numeric );
 
comment on column parametricas.calibres_de_cables.calibre_awg is 'Calibre del cable'; 
comment on column parametricas.calibres_de_cables.twg60º is 'Nivel de temperatura 60º';
comment on column parametricas.calibres_de_cables.rhw_thw_yhwn_75º  is 'Nivel e temperatra 75º';
comment on column parametricas.calibres_de_cables.thhn_xhhw_2_thwn_2  is 'Nivel de temperatura 90º';

ALTER TABLE IF EXISTS parametricas.calibres_de_cables
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.calibres_de_cables
IS 'Esta contiene las asignacion del calibre  del cable segun la temperatura';


---insercion

insert into parametricas.calibres_de_cables  Values ('14',15,15,15);
insert into parametricas.calibres_de_cables  Values ('12',20,20,20);
insert into parametricas.calibres_de_cables  Values ('10',30,30,30);
insert into parametricas.calibres_de_cables  Values ('8',40,50,55);
insert into parametricas.calibres_de_cables  Values ('6',55,65,75);
insert into parametricas.calibres_de_cables  Values ('4',70,85,95);
insert into parametricas.calibres_de_cables  Values ('3',85,100,115);
insert into parametricas.calibres_de_cables  Values  ('2',95,115,130);
insert into parametricas.calibres_de_cables  Values ('1',110,130,145);
insert into parametricas.calibres_de_cables  Values ('1/0',125,150,170);
insert into parametricas.calibres_de_cables  Values  ('2/0',145,175,195);
insert into parametricas.calibres_de_cables  Values  ('3/0',165,200,225);
insert into parametricas.calibres_de_cables  Values ('4/0',195,230,260);



----crear de tablas regulacion_de_conductores

-- regulacion_de_conductores_XL (Reactance) de todos los alambres

create table parametricas.XL_regulacion_de_conductores
(calibre_awg_o_kcmil           character varying(4),
 conduit_pvc  real,
 conduit_ia    real,
conduit_de_acero real );
comment on column parametricas.XL_regulacion_de_conductores.calibre_awg_o_kcmil is 'Calibre del cable'; 
comment on column parametricas.XL_regulacion_de_conductores.conduit_pvc  is 'Indicador para conductor en pvcº';
comment on column parametricas.XL_regulacion_de_conductores.conduit_ia  is 'Indicador para conductor en ia';
comment on column parametricas.XL_regulacion_de_conductores.conduit_de_acero  is 'Indicador para conductor en acero';

ALTER TABLE IF EXISTS parametricas.XL_regulacion_de_conductores
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.XL_regulacion_de_conductores
IS 'Esta tabla contiene la regulacion_de_conductores por calibre y tipo de resistencia XL (Reactance) de todos los alambres';

--insercion 
insert into parametricas.XL_regulacion_de_conductores  Values ('14',0.190	,0.190	,0.240);
insert into parametricas.XL_regulacion_de_conductores  Values ('12',0.177	,0.177	,0.223);
insert into parametricas.XL_regulacion_de_conductores  Values ('10',0.164	,0.164	,0.207);
insert into parametricas.XL_regulacion_de_conductores  Values ('8' ,0.171	,0.171	,0.213);
insert into parametricas.XL_regulacion_de_conductores  Values ('6' ,0.167	,0.167	,0.210);
insert into parametricas.XL_regulacion_de_conductores  Values ('4' ,0.157	,0.157	,0.197);
insert into parametricas.XL_regulacion_de_conductores  Values ('3' ,0.154	,0.154	,0.194);
insert into parametricas.XL_regulacion_de_conductores  Values ('2' ,0.148	,0.148	,0.187);
insert into parametricas.XL_regulacion_de_conductores  Values ('1' ,0.151	,0.151	,0.187);
insert into parametricas.XL_regulacion_de_conductores  Values ('1/0',0.144	,0.144	,0.180);
insert into parametricas.XL_regulacion_de_conductores  Values ('2/0',0.141	,0.141	,0.177);
insert into parametricas.XL_regulacion_de_conductores  Values ('3/0',0.138	,0.138	,0.171);
insert into parametricas.XL_regulacion_de_conductores  Values ('4/0',0.135	,0.135	,0.167);
insert into parametricas.XL_regulacion_de_conductores  Values ('250',0.135	,0.135	,0.171);
insert into parametricas.XL_regulacion_de_conductores  Values ('300',0.135	,0.135	,0.167);
insert into parametricas.XL_regulacion_de_conductores  Values ('350',0.131	,0.131	,0.164);
insert into parametricas.XL_regulacion_de_conductores  Values ('400',0.131	,0.131	,0.161);
insert into parametricas.XL_regulacion_de_conductores  Values ('500',0.128	,0.128	,0.157);
insert into parametricas.XL_regulacion_de_conductores  Values ('600',0.129	,0.129	,0.157);
insert into parametricas.XL_regulacion_de_conductores  Values ('750',0.125	,0.125	,0.157);
insert into parametricas.XL_regulacion_de_conductores  Values ('1000',0.121	,0.121	,0.151);




-- Resistencia en c,a, alambres de cobre descubiertos

create table parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores
(calibre_awg_o_kcmil           character varying(4),
 conduit_pvc  real,
 conduit_ia    real,
conduit_de_acero real );
comment on column parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores.calibre_awg_o_kcmil is 'Calibre del cable'; 
comment on column parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores.conduit_pvc  is 'Indicador para conductor en pvcº';
comment on column parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores.conduit_ia  is 'Indicador para conductor en ia';
comment on column parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores.conduit_de_acero  is 'Indicador para conductor en acero';

ALTER TABLE IF EXISTS parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores
IS 'Esta tabla contiene la regulacion_de_conductores por calibre y tipo de resistencia Resistencia en c,a, alambres de cobre descubiertos';

--insercion 
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('14',	10.17	,	10.17	,	10.17	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('12',	6.56	,	6.56	,	6.56	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('10',	3.94	,	3.94	,	3.94	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('8',	2.56	,	2.56	,	2.56	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('6',	1.61	,	1.61	,	1.61	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('4',	1.02	,	1.02	,	1.02	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('3',	0.82	,	0.82	,	0.82	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('2',	0.623	,	0.656	,	0.656	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('1',	0.525	,	0.525	,	0.525	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('1/0',	0.394	,	0.427	,	0.394	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('2/0',	0.328	,	0.328	,	0.328	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('3/0',	0.253	,	0.269	,	0.259	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('4/0',	0.203	,	0.219	,	0.207	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('250',	0.171	,	0.187	,	0.177	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('300',	0.144	,	0.161	,	0.148	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('350',	0.125	,	0.141	,	0.128	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('400',	0.108	,	0.125	,	0.115	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('500',	0.089	,	0.105	,	0.095	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('600',	0.075	,	0.092	,	0.082	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('750',	0.062	,	0.079	,	0.069	);
insert into parametricas.resistencia_c_a_cubiertos_regulacion_de_conductores  Values ('1000',	0.049	,	0.062	,	0.059	);


-- Resistencia en c,a, alambres de aluminio

create table parametricas.resistencia_c_a_aluminio_regulacion_de_conductores
(calibre_awg_o_kcmil           character varying(4),
 conduit_pvc  real,
 conduit_ia    real,
conduit_de_acero real );
comment on column parametricas.resistencia_c_a_aluminio_regulacion_de_conductores.calibre_awg_o_kcmil is 'Calibre del cable'; 
comment on column parametricas.resistencia_c_a_aluminio_regulacion_de_conductores.conduit_pvc  is 'Indicador para conductor en pvcº';
comment on column parametricas.resistencia_c_a_aluminio_regulacion_de_conductores.conduit_ia  is 'Indicador para conductor en ia';
comment on column parametricas.resistencia_c_a_aluminio_regulacion_de_conductores.conduit_de_acero  is 'Indicador para conductor en acero';

ALTER TABLE IF EXISTS parametricas.resistencia_c_a_aluminio_regulacion_de_conductores
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.resistencia_c_a_aluminio_regulacion_de_conductores
IS 'Esta tabla contiene la regulacion_de_conductores por calibre y tipo de resistencia  Resistencia en c,a, alambres de aluminio';

--insercion 


insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('14',	null	,null		,null		);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('12',	10.49	,	10.49	,	10.49	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('10',	6.56	,	6.56	,	6.56	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('8',	4.27	,	4.27	,	4.27	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('6',	2.66	,	2.66	,	2.66	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('4',	1.67	,	1.67	,	1.67	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('3',	1.31	,	1.35	,	1.31	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('2',	1.05	,	1.05	,	1.05	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('1',	0.82	,	0.853	,	0.82	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('1/0',	0.656	,	0.689	,	0.656	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('2/0',	0.525	,	0.525	,	0.525	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('3/0',	0.427	,	0.427	,	0.427	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('4/0',	0.328	,	0.361	,	0.328	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('250',	0.279	,	0.295	,	0.282	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('300',	0.233	,	0.249	,	0.236	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('350',	0.2	,	0.217	,	0.206	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('400',	0.177	,	0.194	,	0.18	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('500',	0.141	,	0.157	,	0.148	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('600',	0.118	,	0.135	,	0.125	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('750',	0.095	,	0.112	,	0.102	);
insert into parametricas.resistencia_c_a_aluminio_regulacion_de_conductores  Values ('1000',	0.075	,	0.089	,	0.082	);




/*

create table parametricas.regulacion_de_conductores
(calibre_awg_o_kcmil           character varying(4),
 tipo                  character varying(60),
 conduit_pvc  real,
 conduit_ia    real,
conduit_de_acero real );
 
comment on column parametricas.regulacion_de_conductores.calibre_awg_o_kcmil is 'Calibre del cable'; 
comment on column parametricas.regulacion_de_conductores.tipo is 'Tipo de resistencia';
comment on column parametricas.regulacion_de_conductores.conduit_pvc  is 'Indicador para conductor en pvcº';
comment on column parametricas.regulacion_de_conductores.conduit_ia  is 'Indicador para conductor en ia';
comment on column parametricas.regulacion_de_conductores.conduit_de_acero  is 'Indicador para conductor en acero';

ALTER TABLE IF EXISTS parametricas.regulacion_de_conductores
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.regulacion_de_conductores
IS 'Esta tabla contiene la regulacion_de_conductores por calibre y tipo de resistencia';

---insercion



insert into parametricas.regulacion_de_conductores  Values (	'14','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	8.86	,	8.86	,	8.86	);
insert into parametricas.regulacion_de_conductores  Values (	'12','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	5.58	,	5.58	,	5.58	);
insert into parametricas.regulacion_de_conductores  Values (	'10','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	3.61	,	3.61	,	3.61	);
insert into parametricas.regulacion_de_conductores  Values (	'8','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	2.26	,	2.26	,	2.29	);
insert into parametricas.regulacion_de_conductores  Values (	'6','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	1.44	,	1.48	,	1.48	);
insert into parametricas.regulacion_de_conductores  Values (	'4','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.951	,	0.951	,	0.984	);
insert into parametricas.regulacion_de_conductores  Values (	'3','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.755	,	0.787	,	0.787	);
insert into parametricas.regulacion_de_conductores  Values (	'2','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.623	,	0.623	,	0.656	);
insert into parametricas.regulacion_de_conductores  Values (	'1','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.525	,	0.525	,	0.525	);
insert into parametricas.regulacion_de_conductores  Values (	'1/0','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.427	,	0.427	,	0.427	);
insert into parametricas.regulacion_de_conductores  Values (	'2/0','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.361	,	0.361	,	0.361	);
insert into parametricas.regulacion_de_conductores  Values (	'3/0','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.289	,	0.302	,	0.308	);
insert into parametricas.regulacion_de_conductores  Values (	'4/0','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.243	,	0.256	,	0.262	);
insert into parametricas.regulacion_de_conductores  Values (	'250','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.217	,	0.23	,	0.24	);
insert into parametricas.regulacion_de_conductores  Values (	'300','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.194	,	0.207	,	0.213	);
insert into parametricas.regulacion_de_conductores  Values (	'350','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.174	,	0.19	,	0.197	);
insert into parametricas.regulacion_de_conductores  Values (	'400','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.161	,	0.174	,	0.184	);
insert into parametricas.regulacion_de_conductores  Values (	'500','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.141	,	0.157	,	0.164	);
insert into parametricas.regulacion_de_conductores  Values (	'600','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.131	,	0.144	,	0.154	);
insert into parametricas.regulacion_de_conductores  Values (	'750','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.118	,	0.131	,	0.141	);
insert into parametricas.regulacion_de_conductores  Values (	'1000','Z eficaz para alambres de Cobre descubiertos a FP =0.85',	0.105	,	0.118	,	0.131	);
insert into parametricas.regulacion_de_conductores  Values (	'14','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',null		,null		,null		);
insert into parametricas.regulacion_de_conductores  Values (	'12','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	9.19	,	9.19	,	9.19	);
insert into parametricas.regulacion_de_conductores  Values (	'10','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	5.91	,	5.91	,	5.91	);
insert into parametricas.regulacion_de_conductores  Values (	'8','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	3.61	,	3.61	,	3.61	);
insert into parametricas.regulacion_de_conductores  Values (	'6','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	2.33	,	2.33	,	2.33	);
insert into parametricas.regulacion_de_conductores  Values (	'4','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	1.51	,	1.51	,	1.51	);
insert into parametricas.regulacion_de_conductores  Values (	'3','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	1.21	,	1.21	,	1.21	);
insert into parametricas.regulacion_de_conductores  Values (	'2','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.98	,	0.98	,	0.98	);
insert into parametricas.regulacion_de_conductores  Values (	'1','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.79	,	0.79	,	0.82	);
insert into parametricas.regulacion_de_conductores  Values (	'1/0','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.62	,	0.66	,	0.66	);
insert into parametricas.regulacion_de_conductores  Values (	'2/0','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.52	,	0.52	,	0.52	);
insert into parametricas.regulacion_de_conductores  Values (	'3/0','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.43	,	0.43	,	0.46	);
insert into parametricas.regulacion_de_conductores  Values (	'4/0','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.36	,	0.36	,	0.36	);
insert into parametricas.regulacion_de_conductores  Values (	'250','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.308	,	0.322	,	0.328	);
insert into parametricas.regulacion_de_conductores  Values (	'300','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.269	,	0.282	,	0.289	);
insert into parametricas.regulacion_de_conductores  Values (	'350','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.239	,	0.253	,	0.262	);
insert into parametricas.regulacion_de_conductores  Values (	'400','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.217	,	0.233	,	0.24	);
insert into parametricas.regulacion_de_conductores  Values (	'500','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.187	,	0.2	,	0.21	);
insert into parametricas.regulacion_de_conductores  Values (	'600','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.167	,	0.18	,	0.19	);
insert into parametricas.regulacion_de_conductores  Values (	'750','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.148	,	0.161	,	0.171	);
insert into parametricas.regulacion_de_conductores  Values (	'1000','Z eficaz para alambres de Aluminio descubiertos a FP =0.85',	0.128	,	0.138	,	0.151	);

*/

-----Cantidad total de circuitos del tablero

--TABLERO CON PUERTA Y CHAPA PLASTICA, CERRADURA, LLAVE Y ESPACIO PARA TOTALIZADOR DRX
--tablero trifasico RETIE certificado por CIDET

create table parametricas.tablero_distribucion_electrica1
(empaque           numeric,
 referencia         character varying(12),
 num_circuito  numeric );
 
comment on column parametricas.tablero_distribucion_electrica1.empaque is 'codigo del empaque'; 
comment on column parametricas.tablero_distribucion_electrica1.referencia is 'Codigo de referencia asignado';
comment on column parametricas.tablero_distribucion_electrica1.num_circuito  is 'numero de circuitos del tablero';


ALTER TABLE IF EXISTS parametricas.tablero_distribucion_electrica1
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.tablero_distribucion_electrica1
IS 'TABLERO CON PUERTA Y CHAPA PLASTICA, CERRADURA, LLAVE Y ESPACIO PARA TOTALIZADOR DRX, tablero trifasico RETIE certificado por CIDET';


--insercion

insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-12MBO',12);
insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-18MBO',18);
insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-24MBO',24);
insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-30MBO',30);
insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-36MBO',36);
insert into parametricas.tablero_distribucion_electrica1  Values (1,'TWC-42MBO',42);


--tabla para definir la longitud del tablero_distribucion_electrica1


create table parametricas.longitud_tablero
(longitud           numeric);
 
comment on column parametricas.longitud_tablero.logitud is 'longitud del circuito'; 



ALTER TABLE IF EXISTS parametricas.longitud_tablero
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.longitud_tablero
IS 'tabla para definir la logitud del tablero';



---tabla de puesta a tierra

create table parametricas.tabla_tierra
(proteccion           numeric,
 mm_cobre         real,
 kcmil_cobre  character varying(4),
 mm_alum         real,
 kcmil_alum  character varying(4)  );
 
comment on column  parametricas.tabla_tierra.proteccion is 'corriente nominal o ajuste maximo del disositivo aut de proteccion'; 
comment on column parametricas.tabla_tierra.mm_cobre is 'mm de alambre de cobre';
comment on column parametricas.tabla_tierra.kcmil_cobre  is 'calibre en cobre';
comment on column parametricas.tabla_tierra.mm_alum is 'mm de alambre de aluminio';
comment on column parametricas.tabla_tierra.kcmil_alum   is 'calibre en aluminio';

ALTER TABLE IF EXISTS parametricas.tabla_tierra
    OWNER to automatizacion;	
COMMENT ON TABLE parametricas.tabla_tierra
IS 'calibre minimo de conductores de puesta a tierra de equipos para puesta a tierra de canalizacion y equipos';


--insercion

insert into parametricas.tabla_tierra  Values (15,2.08,'14', 3.30,'12');
insert into parametricas.tabla_tierra  Values (20,3.30,'12', 5.25,'10');
insert into parametricas.tabla_tierra  Values (30,5.25,'10', 8.36,'8');
insert into parametricas.tabla_tierra  Values (40,5.25,'10', 8.36,'8');
insert into parametricas.tabla_tierra  Values (60,5.25,'10', 8.36,'8');
insert into parametricas.tabla_tierra  Values (100,8.36,'8', 13.29,'6');
insert into parametricas.tabla_tierra  Values (200,13.29,'6', 21.14,'4');
insert into parametricas.tabla_tierra  Values (300,21.14,'4', 33.62,'2');
insert into parametricas.tabla_tierra  Values (400,26.66,'3', 42.20,'1');
insert into parametricas.tabla_tierra  Values (500,33.62,'2', 53.50,'1/0');
insert into parametricas.tabla_tierra  Values (600,42.20,'1', 67.44,'2/0');
insert into parametricas.tabla_tierra  Values (800,53.50,'1/0', 85.02,'3/0');
insert into parametricas.tabla_tierra  Values (1000,67.44,'2/0', 107.21,'4/0');
insert into parametricas.tabla_tierra  Values (1200,85.02,'3/0', 126.67,'250');
insert into parametricas.tabla_tierra  Values (1600,107.21,'4/0', 177.34,'350');
insert into parametricas.tabla_tierra  Values (2000,126.67,'250', 202.68,'400');
insert into parametricas.tabla_tierra  Values (2500,177.34,'350', 304.02,'600');
insert into parametricas.tabla_tierra  Values (3000,202.68,'400', 304.02,'600');
insert into parametricas.tabla_tierra  Values (4000,253.25,'500', 405.36,'800');
insert into parametricas.tabla_tierra  Values (5000,354.69,'700', 608.04,'1200');
insert into parametricas.tabla_tierra  Values (6000,405.36,'800', 608.04,'1200');