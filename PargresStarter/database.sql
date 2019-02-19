--
-- scc2QL database dump
--

-- Dumped from database version 9.3.5
-- Dumped by pg_dump version 9.3.1
-- Started on 2015-01-05 13:13:17 BRSTf
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--CREATE LANGUAGE plpgsql;

SET search_path = public, pg_catalog;

--
-- TOC entry 214 (class 1255 OID 35743)
-- Name: f_activation(integer, integer, integer, integer, integer, character varying, character varying, integer, text, text, timestamp with time zone, timestamp with time zone, character varying, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_activation(v_taskid integer, v_actid integer, v_machineid integer, v_processor integer, v_exitstatus integer, v_commandline character varying, v_folder character varying, v_subfolder character varying, v_failure_tries integer, v_terr text, v_tout text, v_starttime timestamp with time zone, v_endtime timestamp with time zone, v_status character varying, v_extstarttime timestamp with time zone, v_extendtime timestamp with time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_taskid integer;
begin
    select v_taskid into d_taskid;
 if (coalesce(d_taskid, 0) = 0) then
	select nextval('taskid_seq') into d_taskid;
        insert into eactivation(taskid, actid, machineid, processor, exitstatus, commandline, folder, subfolder, failure_tries, terr, tout, starttime, endtime, status, extractorstarttime, extractorendtime) values(d_taskid, v_actid, v_machineid, v_processor, v_exitstatus, v_commandline, v_folder, v_subfolder, v_failure_tries, v_terr, v_tout, v_starttime, v_endtime, v_status, v_extstarttime, v_extendtime);
else
    update eactivation set actid = v_actid, machineid = v_machineid, processor = v_processor, exitstatus = v_exitstatus, commandline = v_commandline, folder = v_folder, subfolder = v_subfolder, failure_tries = v_failure_tries, terr = v_terr, tout = v_tout, starttime = v_starttime, endtime = v_endtime, status = v_status, extractorstarttime = v_extstarttime, extractorendtime = v_extendtime where taskid = d_taskid;
end if;
 return d_taskid;
end;
$$;


--
-- TOC entry 215 (class 1255 OID 35744)
-- Name: f_activity(integer, integer, character varying, character varying, timestamp with time zone, timestamp with time zone, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_activity(v_actid integer, v_wkfid integer, v_tag character varying, v_status character varying, v_starttime timestamp with time zone, v_endtime timestamp with time zone, v_cactid integer, v_templatedir character varying, v_constrained character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_actid integer;
begin
 select v_actid into d_actid;
 if (coalesce(d_actid, 0) = 0) then
   select nextval('actid_seq') into d_actid;
   insert into eactivity(actid, wkfid, tag, status, starttime, endtime, cactid, templatedir, constrained) values(d_actid, v_wkfid, v_tag, v_status, v_starttime, v_endtime, v_cactid, v_templatedir, v_constrained);
 else 
   update eactivity set status = v_status, starttime = v_starttime, endtime = v_endtime, templatedir = v_templatedir, constrained = v_constrained where actid = d_actid;
 end if;
 return d_actid;
end;
$$;


--
-- TOC entry 216 (class 1255 OID 35745)
-- Name: f_cactivity(integer, integer, character varying, character varying, character varying, character varying, text, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_cactivity(v_actid integer, v_wkfid integer, v_tag character varying, v_atype character varying, v_description character varying, v_activation character varying, v_templatedir text, v_constrained character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_actid integer;
begin
 select v_actid into d_actid;
 if (coalesce(d_actid, 0) = 0) then
   select nextval('actid_seq') into d_actid;
   insert into cactivity(actid, wkfid, tag, atype, description, activation, templatedir, constrained) values(d_actid, v_wkfid, v_tag, v_atype, v_description, v_activation, v_templatedir, v_constrained);
 else 
   update cactivity set atype = v_atype, description = v_description, templatedir = v_templatedir, activation = v_activation, constrained = v_constrained where actid = d_actid;
 end if;
 return d_actid;
end;
$$;


--
-- TOC entry 217 (class 1255 OID 35746)
-- Name: f_cextractor(integer, integer, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_cextractor(v_extid integer, v_wkfid integer, v_name character varying, v_type character varying, v_cartridge character varying, v_search character varying, v_invocation character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_extid integer;
begin
 select v_extid into d_extid;
 if (coalesce(d_extid, 0) = 0) then
   select nextval('extid_seq') into d_extid;
   insert into cextractor(extid, wkfid, name, type, cartridge, search, invocation) 
	   values(d_extid, v_wkfid, v_name, v_type, v_cartridge, v_search, v_invocation);
 else 
   update cextractor set name = v_name, type = v_type, cartridge = v_cartridge, search = v_search, 
	   invocation = v_invocation where extid = d_extid;
 end if;
 return d_extid;
end;
$$;


CREATE FUNCTION f_crelation(v_wkfid integer , v_rtype character varying, v_rname character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_relid integer;
begin
 select nextval('relid_seq') into d_relid;
 insert into crelation(wkfid,relid, rtype, rname) values(v_wkfid,d_relid, v_rtype, v_rname);
 return d_relid;
end;
$$;



--
-- TOC entry 213 (class 1255 OID 35748)
-- Name: f_cworkflow(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_cworkflow(v_wkfid integer, v_tag character varying, v_description character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_wkfid integer;
begin
 select v_wkfid into d_wkfid;
 if (coalesce(d_wkfid, 0) = 0) then
   select nextval('wkfid_seq') into d_wkfid;
   insert into cworkflow(wkfid, tag, description) values(d_wkfid, v_tag, v_description);
 end if;
 return d_wkfid;
end;
$$;


--
-- TOC entry 205 (class 1255 OID 35749)
-- Name: f_del_workflow(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_del_workflow(v_tagexec character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    update eworkflow set tag = 'lixo' where tagexec = v_tagexec;
 return 0;
end;
$$;


--
-- TOC entry 219 (class 1255 OID 35750)
-- Name: f_del_workflows(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_del_workflows(v_tag character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
	delete from efile where exists (
		select * from eactivity a, eworkflow w where a.actid = efile.actid	and a.wkfid = w.wkfid	and w.tag = v_tag	
	);

	delete from eactivation where actid in 
	(
		select a.actid	from eactivity a, eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag
	);

	delete from efield where actid in (	
		select actid from eactivity a, eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag
	);

	delete from erelation where actid in (
		select actid from eactivity a, eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag );

	delete from eactivity where wkfid in (
		select w.wkfid	from eworkflow w where w.tag = v_tag);

	delete from eworkflow where tag = v_tag;
 return 0;
end;
$$;


--
-- TOC entry 212 (class 1255 OID 35742)
-- Name: f_emachine(integer, character varying, character varying, double precision, character varying, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_emachine(v_machineid integer, v_hostname character varying, v_address character varying, v_mflopspersecond double precision, v_type character varying, v_financial_cost double precision) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_machineid integer;
begin
    select v_machineid into d_machineid;
 if (coalesce(d_machineid, 0) = 0) then
select nextval('machineid_seq') into d_machineid;
        insert into emachine(machineid, hostname, address, mflopspersecond, type, financial_cost) values(d_machineid, v_hostname, v_address, v_mflopspersecond, v_type, v_financial_cost);
else
    update emachine set hostname = v_hostname, address = v_address, mflopspersecond = v_mflopspersecond, type = v_type, financial_cost = v_financial_cost where machineid = d_machineid;
end if;
 return d_machineid;
end;
$$;


--
-- TOC entry 220 (class 1255 OID 35751)
-- Name: f_file(integer, integer, integer, character varying, character varying, character varying, character varying, integer, timestamp with time zone, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_file(v_fileid integer, v_actid integer, v_taskid integer, v_ftemplate character varying, v_finstrumented character varying, v_fdir character varying, v_fname character varying, v_fsize integer, v_fdata timestamp with time zone, v_foper character varying, v_fieldname character varying, v_indexed character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_fileid integer;
begin
    select v_fileid into d_fileid;
if (coalesce(d_fileid, 0) = 0) then
select nextval('fileid_seq') into d_fileid;
insert into efile(fileid, actid, taskid, fdir, fname, fsize, fdata, ftemplate, finstrumented, foper, fieldname, indexed) values(d_fileid, v_actid, v_taskid, v_fdir, v_fname, v_fsize, v_fdata, v_ftemplate, v_finstrumented, v_foper, v_fieldname, v_indexed);
else 
update efile set ftemplate = v_ftemplate, finstrumented = v_finstrumented, fdir = v_fdir, fname = v_fname, fsize = v_fsize, fdata = v_fdata, indexed = v_indexed where d_fileid = fileid;
end if;
return d_fileid;
end;
$$;


--
-- TOC entry 221 (class 1255 OID 35752)
-- Name: f_relation(integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_relation(v_relid integer, v_actid integer, v_rtype character varying, v_rname character varying, v_filename character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_relid integer;
begin
 select v_relid into d_relid;
 if (d_relid is null) then
   select nextval('relid_seq') into d_relid;
   insert into erelation(relid, actid, rtype, rname, filename) values(d_relid, v_actid, v_rtype, v_rname, v_filename);
 end if;
 return d_relid;
end;
$$;


--
-- TOC entry 222 (class 1255 OID 35753)
-- Name: f_workflow(integer, character varying, character varying, character varying, character varying, integer, character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION f_workflow(v_wkfid integer, v_tag character varying, v_tagexec character varying, v_expdir character varying, v_wfdir character varying, v_maximumfailures integer, v_userinteraction character varying, v_reliability double precision, v_redundancy character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_wkfid integer;
begin
 select v_wkfid into d_wkfid;
 if (coalesce(d_wkfid, 0) = 0) then
   select nextval('wkfid_seq') into d_wkfid;
   insert into eworkflow(ewkfid, tag, tagexec, expdir, wfdir, maximumfailures, userinteraction, reliability, redundancy) values(d_wkfid, v_tag, v_tagexec, v_expdir, v_wfdir, v_maximumfailures, v_userinteraction, v_reliability, v_redundancy);
 end if;
 return d_wkfid;
end;
$$;


--
-- TOC entry 171 (class 1259 OID 35754)
-- Name: actid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE actid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 173 (class 1259 OID 35758)
-- Name: cactid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cactid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 35760)
-- Name: cactivity; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cactivity (
    actid integer DEFAULT nextval(('cactid_seq'::text)::regclass) NOT NULL,
    wkfid integer NOT NULL,
    tag character varying(50) NOT NULL,
    atype character varying(25) NOT NULL,
    description character varying(250),
    activation text,
    constrained character varying(1),
    templatedir text
);


--
-- TOC entry 175 (class 1259 OID 35767)
-- Name: cextractor; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cextractor (
    extid integer DEFAULT nextval(('cextid_seq'::text)::regclass) NOT NULL,
    wkfid integer NOT NULL,
    name character varying(50) NOT NULL,
    type character varying(25) NOT NULL,
    cartridge character varying(20),
    search character varying(200),
    invocation text
);

CREATE TABLE cjoin (
    relid integer NOT NULL,
    innerextid integer NOT NULL,
    outerextid integer NOT NULL,
	fields character varying(200)
);


--
-- TOC entry 176 (class 1259 OID 35774)
-- Name: cfield; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cfield (
    fname character varying(20) NOT NULL,
    relid integer NOT NULL,
    ftype character varying(10) NOT NULL,
    decimalplaces integer,
    fileoperation character varying(20),
    instrumented character varying(5),
    extid integer
);


--
-- TOC entry 177 (class 1259 OID 35777)
-- Name: coperand; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coperand (
    opid integer DEFAULT nextval(('copid_seq'::text)::regclass) NOT NULL,
    actid integer NOT NULL,
    oname character varying(100),
    numericvalue double precision,
    textvalue character varying(100)
);


--
-- TOC entry 178 (class 1259 OID 35781)
-- Name: copid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE copid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 179 (class 1259 OID 35783)
-- Name: crelation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crelation (
	wkfid integer NOT NULL,
    relid integer DEFAULT nextval(('relid_seq'::text)::regclass) NOT NULL,
    rtype character varying(100),
    rname character varying(20)
);


--
-- TOC entry 180 (class 1259 OID 35787)
-- Name: cwkfid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cwkfid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 181 (class 1259 OID 35789)
-- Name: cworkflow; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cworkflow (
    wkfid integer DEFAULT nextval(('cwkfid_seq'::text)::regclass) NOT NULL,
    tag character varying(200) NOT NULL,
    description character varying(100)
);


--
-- TOC entry 182 (class 1259 OID 35793)
-- Name: eactivation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eactivation (
    taskid integer NOT NULL,
    actid integer NOT NULL,
    machineid integer,
    processor integer,
    exitstatus integer,
    commandline text,
    folder character varying(150),
	subfolder character varying(50),
    failure_tries integer,
    terr text,
    tout text,
    starttime timestamp with time zone,
    endtime timestamp with time zone,
    status character varying(25),
    extractorstarttime timestamp with time zone,
    extractorendtime timestamp with time zone
);


--
-- TOC entry 183 (class 1259 OID 35799)
-- Name: eactivity; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eactivity (
    actid integer DEFAULT nextval(('cwkfid_seq'::text)::regclass) NOT NULL,
    wkfid integer NOT NULL,
    tag character varying(50) NOT NULL,
    status character varying(25),
    starttime timestamp with time zone,
    endtime timestamp with time zone,
    cactid integer,
    templatedir text,
    constrained character(1) DEFAULT 'F'::bpchar
);


--
-- TOC entry 184 (class 1259 OID 35807)
-- Name: efile; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE efile (
    fileid integer DEFAULT nextval(('fileid_seq'::text)::regclass) NOT NULL,
    actid integer NOT NULL,
    taskid integer,
    ftemplate character(1) DEFAULT 'F'::bpchar,
    finstrumented character(1) DEFAULT 'F'::bpchar,
    fdir character varying(500),
    fname character varying(500),
    fsize bigint,
    fdata timestamp with time zone,
    foper character varying(20),
    fieldname character varying(30),
	indexed character(1) DEFAULT 'F'::bpchar
);


--
-- TOC entry 185 (class 1259 OID 35816)
-- Name: emachine; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE emachine (
    machineid integer DEFAULT nextval(('machineid_seq'::text)::regclass) NOT NULL,
    hostname character varying(250) NOT NULL,
    address character varying(250),
    mflopspersecond double precision,
    type character varying(250),
    financial_cost double precision
);


--
-- TOC entry 186 (class 1259 OID 35823)
-- Name: eperfeval; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eperfeval (
    metric text,
    etime real,
    machineid integer,
    processor integer,
    ewkfid integer,
    taskids text,
    description text
);


--
-- TOC entry 187 (class 1259 OID 35829)
-- Name: eworkflow; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eworkflow (
    ewkfid integer DEFAULT nextval(('wkfid_seq'::text)::regclass) NOT NULL,
    tagexec character varying(200) NOT NULL,
    expdir character varying(150),
    wfdir character varying(200),
    tag character varying(200) NOT NULL,
    maximumfailures integer,
    userinteraction character(1) DEFAULT 'F'::bpchar,
    reliability double precision,
    redundancy character(1) DEFAULT 'F'::bpchar
);

CREATE TABLE cmapping (
    cmapid integer DEFAULT nextval(('cmapid_seq'::text)::regclass) NOT NULL,
	crelid integer NOT NULL,
	previousid integer ,
	nextid integer 
);

CREATE FUNCTION f_cmapping(v_relid integer,v_previousid integer, v_nextid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare d_cmapid integer;
begin
select nextval('wkfid_seq') into d_cmapid;
 insert into cmapping(cmapid, crelid,previousid, nextid) values(d_cmapid, v_relid,v_previousid,v_nextid);
 return d_cmapid;
end;
$$;

ALTER FUNCTION public.f_cmapping(v_relid integer,v_previousid integer, v_nextid integer) OWNER TO scc2;


CREATE SEQUENCE cmapid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- TOC entry 172 (class 1259 OID 35756)
-- Name: extid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE extid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 188 (class 1259 OID 35838)
-- Name: fieldid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fieldid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 189 (class 1259 OID 35840)
-- Name: fileid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fileid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 190 (class 1259 OID 35842)
-- Name: machineid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE machineid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 191 (class 1259 OID 35844)
-- Name: relid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE relid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 192 (class 1259 OID 35846)
-- Name: taskid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taskid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 193 (class 1259 OID 35848)
-- Name: wkfid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wkfid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2203 (class 2606 OID 35851)
-- Name: cactivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cactivity
    ADD CONSTRAINT cactivity_pkey PRIMARY KEY (wkfid, actid);


--
-- TOC entry 2207 (class 2606 OID 35853)
-- Name: cextractor_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cextractor
    ADD CONSTRAINT cextractor_pkey PRIMARY KEY (extid, wkfid);
	
ALTER TABLE ONLY cjoin
    ADD CONSTRAINT cjoin_pkey PRIMARY KEY (relid, innerextid, outerextid);


--
-- TOC entry 2210 (class 2606 OID 35855)
-- Name: cfield_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cfield
    ADD CONSTRAINT cfield_pk PRIMARY KEY (relid, fname);

ALTER TABLE cfield CLUSTER ON cfield_pk;


--
-- TOC entry 2213 (class 2606 OID 35857)
-- Name: coperand_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coperand
    ADD CONSTRAINT coperand_pk PRIMARY KEY (actid, opid);


--
-- TOC entry 2215 (class 2606 OID 35859)
-- Name: crelation_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crelation
    ADD CONSTRAINT crelation_pk PRIMARY KEY (wkfid, relid);


--
-- TOC entry 2220 (class 2606 OID 35861)
-- Name: cworkflow_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cworkflow
    ADD CONSTRAINT cworkflow_pk PRIMARY KEY (wkfid);

ALTER TABLE cworkflow CLUSTER ON cworkflow_pk;


--
-- TOC entry 2228 (class 2606 OID 35863)
-- Name: eactivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eactivity
    ADD CONSTRAINT eactivity_pkey PRIMARY KEY (wkfid, actid);

ALTER TABLE eactivity CLUSTER ON eactivity_pkey;


--
-- TOC entry 2233 (class 2606 OID 35865)
-- Name: efile_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY efile
    ADD CONSTRAINT efile_pk PRIMARY KEY (actid, fileid);

ALTER TABLE efile CLUSTER ON efile_pk;


--
-- TOC entry 2235 (class 2606 OID 35867)
-- Name: emachineid_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY emachine
    ADD CONSTRAINT emachineid_pk PRIMARY KEY (machineid);


--
-- TOC entry 2224 (class 2606 OID 35869)
-- Name: etask_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eactivation
    ADD CONSTRAINT etask_pk PRIMARY KEY (actid, taskid);

ALTER TABLE eactivation CLUSTER ON etask_pk;


--
-- TOC entry 2237 (class 2606 OID 35871)
-- Name: eworkflow_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eworkflow
    ADD CONSTRAINT eworkflow_pk PRIMARY KEY (ewkfid);

ALTER TABLE eworkflow CLUSTER ON eworkflow_pk;


--
-- TOC entry 2200 (class 1259 OID 35872)
-- Name: c_activity_wkfid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX c_activity_wkfid ON cactivity USING btree (wkfid);


--
-- TOC entry 2204 (class 1259 OID 35873)
-- Name: c_extractor_actid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX c_extractor_wkfid ON cextractor USING btree (wkfid);

CREATE INDEX c_join_relid ON cjoin USING btree (relid);


--
-- TOC entry 2208 (class 1259 OID 35874)
-- Name: c_field_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX c_field_key ON cfield USING btree (relid, fname);


--
-- TOC entry 2201 (class 1259 OID 35875)
-- Name: cactivity_actid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cactivity_actid ON cactivity USING btree (actid);


--
-- TOC entry 2205 (class 1259 OID 35876)
-- Name: cextractor_extid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cextractor_extid ON cextractor USING btree (extid);

CREATE UNIQUE INDEX cjoin_id ON cjoin USING btree (relid, innerextid, outerextid);


--
-- TOC entry 2211 (class 1259 OID 35877)
-- Name: coperand_opid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX coperand_opid ON coperand USING btree (opid);


--
-- TOC entry 2216 (class 1259 OID 35878)
-- Name: crelation_relid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX crelation_relid ON crelation USING btree (relid);


--
-- TOC entry 2217 (class 1259 OID 35879)
-- Name: cworkflow_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cworkflow_index ON cworkflow USING btree (wkfid);


--
-- TOC entry 2218 (class 1259 OID 35880)
-- Name: cworkflow_index_tag; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cworkflow_index_tag ON cworkflow USING btree (tag);


--
-- TOC entry 2221 (class 1259 OID 35881)
-- Name: e_activation_actid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX e_activation_actid ON eactivation USING btree (actid);


--
-- TOC entry 2225 (class 1259 OID 35882)
-- Name: e_activity_wkfid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX e_activity_wkfid ON eactivity USING btree (wkfid);


--
-- TOC entry 2229 (class 1259 OID 35883)
-- Name: e_file_actid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX e_file_actid ON efile USING btree (actid);


--
-- TOC entry 2230 (class 1259 OID 35884)
-- Name: e_file_taskid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX e_file_taskid ON efile USING btree (taskid);


--
-- TOC entry 2222 (class 1259 OID 35885)
-- Name: eactivation_taskid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX eactivation_taskid ON eactivation USING btree (taskid);


--
-- TOC entry 2226 (class 1259 OID 35886)
-- Name: eactivity_actid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX eactivity_actid ON eactivity USING btree (actid);


--
-- TOC entry 2231 (class 1259 OID 35887)
-- Name: efile_fileid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX efile_fileid ON efile USING btree (fileid);


--
-- TOC entry 2238 (class 2606 OID 35888)
-- Name: cactivity_wkfid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cactivity
    ADD CONSTRAINT cactivity_wkfid_fk FOREIGN KEY (wkfid) REFERENCES cworkflow(wkfid) ON UPDATE CASCADE ON DELETE CASCADE;


-- 
-- Name: cmapping_crelid_fk; Type : FK CONSTRAINT; Schema: public; Owner: scc2
ALTER TABLE ONLY cmapping
	ADD CONSTRAINT cmapping_crelid_fk FOREIGN KEY (crelid) REFERENCES crelation(relid) ON UPDATE CASCADE ON DELETE CASCADE,
	ADD CONSTRAINT cmapping_previousid_fk FOREIGN KEY (previousid) REFERENCES cactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE,
	ADD CONSTRAINT cmapping_next_fk FOREIGN KEY (nextid) REFERENCES cactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT cmapping_pk PRIMARY KEY (cmapid, crelid);

--
-- TOC entry 2239 (class 2606 OID 35893)
-- Name: cextractor_actid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cextractor
    ADD CONSTRAINT cextractor_actid_fk FOREIGN KEY (wkfid) REFERENCES cworkflow(wkfid) ON UPDATE CASCADE ON DELETE CASCADE;
	
ALTER TABLE ONLY cjoin
    ADD CONSTRAINT cjoin_relid_fk FOREIGN KEY (relid) REFERENCES crelation(relid) ON UPDATE CASCADE ON DELETE CASCADE;
	
ALTER TABLE ONLY cjoin
    ADD CONSTRAINT cjoin_innerextid_fk FOREIGN KEY (innerextid) REFERENCES cextractor(extid) ON UPDATE CASCADE ON DELETE CASCADE;	

ALTER TABLE ONLY cjoin
    ADD CONSTRAINT cjoin_outerextid_fk FOREIGN KEY (outerextid) REFERENCES cextractor(extid) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2241 (class 2606 OID 35903)
-- Name: cfield_extid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfield
    ADD CONSTRAINT cfield_extid_fk FOREIGN KEY (extid) REFERENCES cextractor(extid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2240 (class 2606 OID 35898)
-- Name: cfield_realid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfield
    ADD CONSTRAINT cfield_realid_fk FOREIGN KEY (relid) REFERENCES crelation(relid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2242 (class 2606 OID 35908)
-- Name: coperand_actid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY coperand
    ADD CONSTRAINT coperand_actid_fk FOREIGN KEY (actid) REFERENCES cactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE;



--
-- TOC entry 2247 (class 2606 OID 35923)
-- Name: eactibity_cactid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eactivity
    ADD CONSTRAINT eactibity_cactid_fk FOREIGN KEY (cactid) REFERENCES cactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2246 (class 2606 OID 35953)
-- Name: eactivation_machineid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eactivation
    ADD CONSTRAINT eactivation_machineid_fk FOREIGN KEY (machineid) REFERENCES emachine(machineid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2248 (class 2606 OID 35928)
-- Name: eactivity_wkfid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eactivity
    ADD CONSTRAINT eactivity_wkfid_fk FOREIGN KEY (wkfid) REFERENCES eworkflow(ewkfid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2249 (class 2606 OID 35933)
-- Name: efile_actid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY efile
    ADD CONSTRAINT efile_actid_fk FOREIGN KEY (actid) REFERENCES eactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2250 (class 2606 OID 35938)
-- Name: efile_taskid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY efile
    ADD CONSTRAINT efile_taskid_fk FOREIGN KEY (taskid) REFERENCES eactivation(taskid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2245 (class 2606 OID 35943)
-- Name: etask_actid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eactivation
    ADD CONSTRAINT etask_actid_fk FOREIGN KEY (actid) REFERENCES eactivity(actid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2251 (class 2606 OID 35948)
-- Name: eworkflow_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eworkflow
    ADD CONSTRAINT eworkflow_fk FOREIGN KEY (tag) REFERENCES cworkflow(tag) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2364 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM scc2;
GRANT ALL ON SCHEMA public TO scc2;
GRANT ALL ON SCHEMA public TO scc2;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 2365 (class 0 OID 0)
-- Dependencies: 174
-- Name: cactivity; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE cactivity FROM PUBLIC;
REVOKE ALL ON TABLE cactivity FROM scc2;
GRANT ALL ON TABLE cactivity TO scc2;
GRANT ALL ON TABLE cactivity TO PUBLIC;


--
-- TOC entry 2366 (class 0 OID 0)
-- Dependencies: 175
-- Name: cextractor; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE cextractor FROM PUBLIC;
REVOKE ALL ON TABLE cextractor FROM scc2;
GRANT ALL ON TABLE cextractor TO scc2;
GRANT ALL ON TABLE cextractor TO PUBLIC;


REVOKE ALL ON TABLE cjoin FROM PUBLIC;
REVOKE ALL ON TABLE cjoin FROM scc2;
GRANT ALL ON TABLE cjoin TO scc2;
GRANT ALL ON TABLE cjoin TO PUBLIC;


--
-- TOC entry 2367 (class 0 OID 0)
-- Dependencies: 176
-- Name: cfield; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE cfield FROM PUBLIC;
REVOKE ALL ON TABLE cfield FROM scc2;
GRANT ALL ON TABLE cfield TO scc2;
GRANT ALL ON TABLE cfield TO PUBLIC;


--
-- TOC entry 2368 (class 0 OID 0)
-- Dependencies: 177
-- Name: coperand; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE coperand FROM PUBLIC;
REVOKE ALL ON TABLE coperand FROM scc2;
GRANT ALL ON TABLE coperand TO scc2;
GRANT ALL ON TABLE coperand TO PUBLIC;


--
-- TOC entry 2369 (class 0 OID 0)
-- Dependencies: 179
-- Name: crelation; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE crelation FROM PUBLIC;
REVOKE ALL ON TABLE crelation FROM scc2;
GRANT ALL ON TABLE crelation TO scc2;
GRANT ALL ON TABLE crelation TO PUBLIC;


--
-- TOC entry 2370 (class 0 OID 0)
-- Dependencies: 181
-- Name: cworkflow; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE cworkflow FROM PUBLIC;
REVOKE ALL ON TABLE cworkflow FROM scc2;
GRANT ALL ON TABLE cworkflow TO scc2;
GRANT ALL ON TABLE cworkflow TO PUBLIC;


--
-- TOC entry 2371 (class 0 OID 0)
-- Dependencies: 182
-- Name: eactivation; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE eactivation FROM PUBLIC;
REVOKE ALL ON TABLE eactivation FROM scc2;
GRANT ALL ON TABLE eactivation TO scc2;
GRANT ALL ON TABLE eactivation TO PUBLIC;


--
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 183
-- Name: eactivity; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE eactivity FROM PUBLIC;
REVOKE ALL ON TABLE eactivity FROM scc2;
GRANT ALL ON TABLE eactivity TO scc2;
GRANT ALL ON TABLE eactivity TO PUBLIC;


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 184
-- Name: efile; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE efile FROM PUBLIC;
REVOKE ALL ON TABLE efile FROM scc2;
GRANT ALL ON TABLE efile TO scc2;
GRANT ALL ON TABLE efile TO PUBLIC;


--
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 185
-- Name: emachine; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE emachine FROM PUBLIC;
REVOKE ALL ON TABLE emachine FROM scc2;
GRANT ALL ON TABLE emachine TO scc2;
GRANT ALL ON TABLE emachine TO PUBLIC;


--
-- TOC entry 2375 (class 0 OID 0)
-- Dependencies: 187
-- Name: eworkflow; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE eworkflow FROM PUBLIC;
REVOKE ALL ON TABLE eworkflow FROM scc2;
GRANT ALL ON TABLE eworkflow TO scc2;
GRANT ALL ON TABLE eworkflow TO PUBLIC;


-- Completed on 2015-01-05 13:13:17 BRST

--
-- scc2QL database dump complete
--

