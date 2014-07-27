--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plperl; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plperl WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plperl; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plperl IS 'PL/Perl procedural language';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: serialinc(); Type: FUNCTION; Schema: public; Owner: powerdns
--

CREATE FUNCTION serialinc() RETURNS trigger
    LANGUAGE plperl
    AS $_X$
if (($_TD->{new}) and ($_TD->{new}{type} eq 'SOA')) {
  return "SKIP";
}
else {
  my $domain_id = $_TD->{new}{domain_id} // $_TD->{old}{domain_id};
  return undef unless($domain_id);
  my $rv = spi_exec_query("SELECT id,content FROM records WHERE type = 'SOA' and domain_id = $domain_id");
  return undef unless($rv);
 my $row = $rv->{rows}[0];return unless $row;
 my @content = split(/ /,$row->{content});
 my @now = localtime(time());
 my $now_serial = sprintf "%4d%02d%02d%02d", $now[5] + 1900, $now[4]+1, $now[3], '01';
 my $old_serial = $content[2];
 my $new_serial = ($now_serial > $old_serial) ? $now_serial : ++$old_serial;
 $content[2] = $new_serial;
 my $content = join(' ', @content);
 my $query = "UPDATE records SET content = '$content' WHERE id = $row->{id}";
spi_exec_query($query);
return undef;
}
$_X$;


ALTER FUNCTION public.serialinc() OWNER TO powerdns;

--
-- Name: serialupdate(); Type: FUNCTION; Schema: public; Owner: powerdns
--

CREATE FUNCTION serialupdate() RETURNS trigger
    LANGUAGE plperl
    AS $_X$
if ($_TD->{new}{type} eq 'SOA') {
  return "SKIP";
} else {
  my $domain_id = $_TD->{new}{domain_id} // $_TD->{old}{domain_id};
  return unless $domain_id;
  my $rv = spi_exec_query("SELECT id,content FROM records WHERE type = 'SOA' and domain_id = $domain_id");

 my $row = $rv->{rows}[0];
 return unless $row;
 my @content = split(/ /,$row->{content});
 my @now = localtime(time());
 my $now_serial = sprintf "%4d%02d%02d%02d", $now[5] + 1900, $now[4]+1, $now[3], '01';
 my $old_serial = $content[2];
 my $new_serial = ($now_serial > $old_serial) ? $now_serial : ++$old_serial;
 $content[2] = $new_serial;
 my $content = join(' ', @content);
 my $query = "UPDATE records SET content = '$content' WHERE id = $row->{id}";
spi_exec_query($query);
return undef;
}
$_X$;


ALTER FUNCTION public.serialupdate() OWNER TO powerdns;

--
-- Name: set_change_date(); Type: FUNCTION; Schema: public; Owner: powerdns
--

CREATE FUNCTION set_change_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        NEW.change_date = now();
        return NEW;
    END;
$$;


ALTER FUNCTION public.set_change_date() OWNER TO powerdns;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    domain_id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(10) NOT NULL,
    modified_at integer NOT NULL,
    account character varying(40) DEFAULT NULL::character varying,
    comment character varying(65535) NOT NULL,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.comments OWNER TO powerdns;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: powerdns
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO powerdns;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: powerdns
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: cryptokeys; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cryptokeys (
    id integer NOT NULL,
    domain_id integer,
    flags integer NOT NULL,
    active boolean,
    content text
);


ALTER TABLE public.cryptokeys OWNER TO postgres;

--
-- Name: cryptokeys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cryptokeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cryptokeys_id_seq OWNER TO postgres;

--
-- Name: cryptokeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cryptokeys_id_seq OWNED BY cryptokeys.id;


--
-- Name: ddns_clients; Type: TABLE; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE TABLE ddns_clients (
    ddns_client_id integer NOT NULL,
    record_id integer NOT NULL,
    id_string character varying(128) NOT NULL
);


ALTER TABLE public.ddns_clients OWNER TO powerdns;

--
-- Name: ddns_clients_ddns_client_id_seq; Type: SEQUENCE; Schema: public; Owner: powerdns
--

CREATE SEQUENCE ddns_clients_ddns_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ddns_clients_ddns_client_id_seq OWNER TO powerdns;

--
-- Name: ddns_clients_ddns_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: powerdns
--

ALTER SEQUENCE ddns_clients_ddns_client_id_seq OWNED BY ddns_clients.ddns_client_id;


--
-- Name: domainmetadata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE domainmetadata (
    id integer NOT NULL,
    domain_id integer,
    kind character varying(16),
    content text
);


ALTER TABLE public.domainmetadata OWNER TO postgres;

--
-- Name: domainmetadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE domainmetadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domainmetadata_id_seq OWNER TO postgres;

--
-- Name: domainmetadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE domainmetadata_id_seq OWNED BY domainmetadata.id;


--
-- Name: domains; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE domains (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    master character varying(128) DEFAULT NULL::character varying,
    last_check integer,
    type character varying(6) NOT NULL,
    notified_serial integer,
    account character varying(40) DEFAULT NULL::character varying,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text))),
    CONSTRAINT c_uppercase_type CHECK (((type)::text = upper((type)::text)))
);


ALTER TABLE public.domains OWNER TO postgres;

--
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domains_id_seq OWNER TO postgres;

--
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE domains_id_seq OWNED BY domains.id;


--
-- Name: domains_users; Type: TABLE; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE TABLE domains_users (
    domain_id integer,
    user_id integer
);


ALTER TABLE public.domains_users OWNER TO powerdns;

--
-- Name: records; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE records (
    id integer NOT NULL,
    domain_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    type character varying(10) DEFAULT NULL::character varying,
    content character varying(65535) DEFAULT NULL::character varying,
    ttl integer,
    prio integer,
    ordername character varying(255),
    auth boolean DEFAULT true,
    change_date timestamp with time zone,
    disabled boolean DEFAULT false,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text))),
    CONSTRAINT c_uppercase_type CHECK (((type)::text = upper((type)::text)))
);


ALTER TABLE public.records OWNER TO postgres;

--
-- Name: records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.records_id_seq OWNER TO postgres;

--
-- Name: records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE records_id_seq OWNED BY records.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO powerdns;

--
-- Name: supermasters; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supermasters (
    ip inet NOT NULL,
    nameserver character varying(255) NOT NULL,
    account character varying(40) DEFAULT NULL::character varying
);


ALTER TABLE public.supermasters OWNER TO postgres;

--
-- Name: tsigkeys; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tsigkeys (
    id integer NOT NULL,
    name character varying(255),
    algorithm character varying(50),
    secret character varying(255),
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.tsigkeys OWNER TO postgres;

--
-- Name: tsigkeys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tsigkeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tsigkeys_id_seq OWNER TO postgres;

--
-- Name: tsigkeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tsigkeys_id_seq OWNED BY tsigkeys.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255),
    password_digest character varying(255),
    admin boolean DEFAULT false,
    default_primary character varying(255),
    default_postmaster character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO powerdns;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: powerdns
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO powerdns;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: powerdns
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cryptokeys ALTER COLUMN id SET DEFAULT nextval('cryptokeys_id_seq'::regclass);


--
-- Name: ddns_client_id; Type: DEFAULT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY ddns_clients ALTER COLUMN ddns_client_id SET DEFAULT nextval('ddns_clients_ddns_client_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY domainmetadata ALTER COLUMN id SET DEFAULT nextval('domainmetadata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY domains ALTER COLUMN id SET DEFAULT nextval('domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY records ALTER COLUMN id SET DEFAULT nextval('records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tsigkeys ALTER COLUMN id SET DEFAULT nextval('tsigkeys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: powerdns; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cryptokeys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cryptokeys
    ADD CONSTRAINT cryptokeys_pkey PRIMARY KEY (id);


--
-- Name: ddns_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: powerdns; Tablespace: 
--

ALTER TABLE ONLY ddns_clients
    ADD CONSTRAINT ddns_clients_pkey PRIMARY KEY (ddns_client_id);


--
-- Name: domainmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY domainmetadata
    ADD CONSTRAINT domainmetadata_pkey PRIMARY KEY (id);


--
-- Name: domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


--
-- Name: supermasters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supermasters
    ADD CONSTRAINT supermasters_pkey PRIMARY KEY (ip, nameserver);


--
-- Name: tsigkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tsigkeys
    ADD CONSTRAINT tsigkeys_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: powerdns; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: comments_domain_id_idx; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE INDEX comments_domain_id_idx ON comments USING btree (domain_id);


--
-- Name: comments_name_type_idx; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE INDEX comments_name_type_idx ON comments USING btree (name, type);


--
-- Name: comments_order_idx; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE INDEX comments_order_idx ON comments USING btree (domain_id, modified_at);


--
-- Name: domain_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX domain_id ON records USING btree (domain_id);


--
-- Name: domainidindex; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX domainidindex ON cryptokeys USING btree (domain_id);


--
-- Name: domainidmetaindex; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX domainidmetaindex ON domainmetadata USING btree (domain_id);


--
-- Name: id_string_index; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE UNIQUE INDEX id_string_index ON ddns_clients USING btree (id_string);


--
-- Name: index_domains_users_on_domain_id_and_user_id; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE UNIQUE INDEX index_domains_users_on_domain_id_and_user_id ON domains_users USING btree (domain_id, user_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: name_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX name_index ON domains USING btree (name);


--
-- Name: namealgoindex; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX namealgoindex ON tsigkeys USING btree (name, algorithm);


--
-- Name: nametype_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX nametype_index ON records USING btree (name, type);


--
-- Name: rec_name_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX rec_name_index ON records USING btree (name);


--
-- Name: recordorder; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX recordorder ON records USING btree (domain_id, ordername text_pattern_ops);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: powerdns; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: change_record; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER change_record BEFORE INSERT OR UPDATE ON records FOR EACH ROW EXECUTE PROCEDURE set_change_date();


--
-- Name: update_serial; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_serial AFTER INSERT OR DELETE OR UPDATE ON records FOR EACH ROW EXECUTE PROCEDURE serialinc();


--
-- Name: cryptokeys_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cryptokeys
    ADD CONSTRAINT cryptokeys_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- Name: ddns_clients_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY ddns_clients
    ADD CONSTRAINT ddns_clients_record_id_fkey FOREIGN KEY (record_id) REFERENCES records(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY records
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- Name: domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- Name: domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY domains_users
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- Name: domainmetadata_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY domainmetadata
    ADD CONSTRAINT domainmetadata_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- Name: user_exists; Type: FK CONSTRAINT; Schema: public; Owner: powerdns
--

ALTER TABLE ONLY domains_users
    ADD CONSTRAINT user_exists FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: cryptokeys; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cryptokeys FROM PUBLIC;
REVOKE ALL ON TABLE cryptokeys FROM postgres;
GRANT ALL ON TABLE cryptokeys TO postgres;
GRANT ALL ON TABLE cryptokeys TO powerdns;


--
-- Name: cryptokeys_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE cryptokeys_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cryptokeys_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cryptokeys_id_seq TO postgres;
GRANT ALL ON SEQUENCE cryptokeys_id_seq TO powerdns;


--
-- Name: domainmetadata; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE domainmetadata FROM PUBLIC;
REVOKE ALL ON TABLE domainmetadata FROM postgres;
GRANT ALL ON TABLE domainmetadata TO postgres;
GRANT ALL ON TABLE domainmetadata TO powerdns;


--
-- Name: domainmetadata_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE domainmetadata_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE domainmetadata_id_seq FROM postgres;
GRANT ALL ON SEQUENCE domainmetadata_id_seq TO postgres;
GRANT ALL ON SEQUENCE domainmetadata_id_seq TO powerdns;


--
-- Name: domains; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE domains FROM PUBLIC;
REVOKE ALL ON TABLE domains FROM postgres;
GRANT ALL ON TABLE domains TO postgres;
GRANT ALL ON TABLE domains TO powerdns;


--
-- Name: domains_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE domains_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE domains_id_seq FROM postgres;
GRANT ALL ON SEQUENCE domains_id_seq TO postgres;
GRANT ALL ON SEQUENCE domains_id_seq TO powerdns;


--
-- Name: records; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE records FROM PUBLIC;
REVOKE ALL ON TABLE records FROM postgres;
GRANT ALL ON TABLE records TO postgres;
GRANT ALL ON TABLE records TO powerdns;


--
-- Name: records_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE records_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE records_id_seq FROM postgres;
GRANT ALL ON SEQUENCE records_id_seq TO postgres;
GRANT ALL ON SEQUENCE records_id_seq TO powerdns;


--
-- Name: supermasters; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE supermasters FROM PUBLIC;
REVOKE ALL ON TABLE supermasters FROM postgres;
GRANT ALL ON TABLE supermasters TO postgres;
GRANT SELECT ON TABLE supermasters TO powerdns;


--
-- Name: tsigkeys; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE tsigkeys FROM PUBLIC;
REVOKE ALL ON TABLE tsigkeys FROM postgres;
GRANT ALL ON TABLE tsigkeys TO postgres;
GRANT ALL ON TABLE tsigkeys TO powerdns;


--
-- Name: tsigkeys_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE tsigkeys_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE tsigkeys_id_seq FROM postgres;
GRANT ALL ON SEQUENCE tsigkeys_id_seq TO postgres;
GRANT ALL ON SEQUENCE tsigkeys_id_seq TO powerdns;


--
-- PostgreSQL database dump complete
--

