--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: chase_algoritam(text[], text[], text[], text[], text[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.chase_algoritam(text[], text[], text[], text[], text[], text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE 
	broj_atributa int := array_length($1, 1);
	dekompozicije text[];
	i int;
	polje_za_zavisnosti_spoja text[];
	f_je_logicka_posljedica boolean := true;
begin
	perform napravi_pocetnu_tablicu($1);
	case 
		when $6 = 'FZ' then
			dekompozicije[1] := $5[1]; --X
			dekompozicije[2] := $1;    --R
		when $6 = 'VZ' then
			dekompozicije[1] := concat($5[1], ' ', $5[2]);									 --XY
			dekompozicije[2] := vrati_drugu_dekompoziciju_viseznacne_zavisnosti($1, $5[2]);  --X U (R-XY)
		when $6 = 'ZS' then
			dekompozicije := $5;
	end case;
	perform popuni_pocetnu_tablicu($1, dekompozicije);
	perform provjeri_funkcijske_zavisnosti($2);
	perform provjeri_viseznacne_zavisnosti($1, $3);
	for i in 1..array_length($4, 1) loop
		polje_za_zavisnosti_spoja := string_to_array($4[i],',');
		perform izvrsi_modifikacije_temeljem_zavisnosti_spoja(polje_za_zavisnosti_spoja);
	end loop;
	
	case 
		when $6 = 'FZ' then
			if (SELECT COUNT(*) FROM pocetna_tablica) <> (select broj_cs FROM dohvati_broj_cs($5[2])) then
				f_je_logicka_posljedica := false;
			end if;
		when $6 = 'VZ' or $6 = 'ZS' then
			if (select broj_cr FROM dohvati_broj_cr($1)) = 0 then
				f_je_logicka_posljedica := false;
			end if;
	end case;
	return f_je_logicka_posljedica;
END $_$;


ALTER FUNCTION public.chase_algoritam(text[], text[], text[], text[], text[], text) OWNER TO postgres;

--
-- Name: dohvati_broj_cr(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dohvati_broj_cr(text[]) RETURNS TABLE(broj_cr bigint)
    LANGUAGE plpgsql
    AS $_$
declare
	string_za_dohvacanje_broja_cr text;
	string_za_raspisane_atribute text;
	broj_atributa int:= array_length($1,1);
	i int;
begin
	for i in 1..broj_atributa-1 loop
		string_za_raspisane_atribute := concat($1[i], ' LIKE ''%0%'' and ');
	end loop;
		string_za_raspisane_atribute := concat($1[broj_atributa], ' LIKE ''%0%'';');
	string_za_dohvacanje_broja_cr := concat('SELECT COUNT(*) FROM pocetna_tablica WHERE ', string_za_raspisane_atribute);
	return query execute string_za_dohvacanje_broja_cr;
end $_$;


ALTER FUNCTION public.dohvati_broj_cr(text[]) OWNER TO postgres;

--
-- Name: dohvati_broj_cs(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dohvati_broj_cs(text) RETURNS TABLE(broj_cs bigint)
    LANGUAGE plpgsql
    AS $_$
declare
	string_za_dohvacanje_broja_cs text;
	string_za_raspisane_atribute text;
	desna_strana text[]:= string_to_array($1, ' ');
	duljina_desne_strane int:= array_length(desna_strana,1);
	i int;
begin
	for i in 1..duljina_desne_strane-1 loop
		string_za_raspisane_atribute := concat(desna_strana[i], ' LIKE ''%0%'' and ');
	end loop;
		string_za_raspisane_atribute := concat(desna_strana[duljina_desne_strane], ' LIKE ''%0%'';');
	string_za_dohvacanje_broja_cs := concat('SELECT COUNT(*) FROM pocetna_tablica WHERE ', string_za_raspisane_atribute);
	return query execute string_za_dohvacanje_broja_cs;
end $_$;


ALTER FUNCTION public.dohvati_broj_cs(text) OWNER TO postgres;

--
-- Name: dohvati_broj_podudaranja(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dohvati_broj_podudaranja(text, text) RETURNS TABLE(broj_podudaranja bigint)
    LANGUAGE plpgsql
    AS $_$
declare
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	string_za_select text := 'SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(';
	i int;
	y int;
begin
	--npr. SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(t1.a, t1.b)=concat(t2.a, t2.b) and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	for j in 1..duljina_lijeve_strane-1 loop
		string_za_select := concat(string_za_select, 't1.', lijeva_strana[j], ', ');
	end loop;
	string_za_select := concat(string_za_select, 't1.', lijeva_strana[duljina_lijeve_strane], ')=concat(');
	for j in 1..duljina_lijeve_strane-1 loop
		string_za_select := concat(string_za_select, 't2.', lijeva_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't2.', lijeva_strana[duljina_lijeve_strane], ') and concat(');
	for j in 1..duljina_desne_strane-1 loop
		string_za_select := concat(string_za_select, 't1.', desna_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		string_za_select := concat(string_za_select, 't2.', desna_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't2.', desna_strana[duljina_desne_strane], ');');
   	return query execute string_za_select;
end $_$;


ALTER FUNCTION public.dohvati_broj_podudaranja(text, text) OWNER TO postgres;

--
-- Name: dohvati_lijevu_stranu_char(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dohvati_lijevu_stranu_char(text, text) RETURNS TABLE(lijeva_strana2 character varying)
    LANGUAGE plpgsql
    AS $_$
DECLARE 
	lijeva_strana text := $1;
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	stringZaSelect varchar;
	i int;
	y int;
begin
	--npr. SELECT t1.a FROM pocetna_tablica t1, pocetna_tablica t2 WHERE t1.a=t2.a and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	stringZaSelect := concat('SELECT DISTINCT t1.', lijeva_strana,' FROM pocetna_tablica t1, pocetna_tablica t2 WHERE t1.', lijeva_strana, '=t2.', lijeva_strana, ' and concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[duljina_desne_strane], ');');
   	RETURN QUERY execute stringZaSelect;
END $_$;


ALTER FUNCTION public.dohvati_lijevu_stranu_char(text, text) OWNER TO postgres;

--
-- Name: dohvati_lijevu_stranu_text(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dohvati_lijevu_stranu_text(text, text) RETURNS TABLE(lijeva_strana2 text)
    LANGUAGE plpgsql
    AS $_$
DECLARE 
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	stringZaSelect varchar;
	stupci_lijeve_strane varchar := 'concat(';
	i int;
	y int;
begin
	--npr. SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(t1.a, t1.b)=concat(t2.a, t2.b) and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	for j in 1..duljina_lijeve_strane-1 loop
		stupci_lijeve_strane := concat(stupci_lijeve_strane, 't1.',lijeva_strana[j], ', '' '', ');
	end loop;
	stupci_lijeve_strane := concat(stupci_lijeve_strane, 't1.',lijeva_strana[duljina_lijeve_strane], ') ');
	stringZaSelect := concat('SELECT DISTINCT ', stupci_lijeve_strane,' as stupci FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(');
	for j in 1..duljina_lijeve_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', lijeva_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't1.', lijeva_strana[duljina_lijeve_strane], ')=concat(');
	for j in 1..duljina_lijeve_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', lijeva_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't2.', lijeva_strana[duljina_lijeve_strane], ') and concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[duljina_desne_strane], ');');
   	RETURN QUERY execute stringZaSelect;
END $_$;


ALTER FUNCTION public.dohvati_lijevu_stranu_text(text, text) OWNER TO postgres;

--
-- Name: izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(text, text, text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	string_za_where_uvjet text := 'WHERE ';
	string_za_update_redova text := 'UPDATE pocetna_tablica SET ';
	y int;
	simboli text[];
begin
	--update pocetna_tablica set c=(select c from pocetna_tablica where a='0' and b='0' order by c limit 1), d=(select d from pocetna_tablica where a='0' and b='0' order by d limit 1) where a='0' and b='0';
	if $3 like '% %' then
		simboli := string_to_array($3, ' ');
		for j in 1..duljina_lijeve_strane-1 loop
			string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[j], '=''', simboli[j], ''' and ');
		end loop;
		string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[duljina_lijeve_strane], '=''', simboli[duljina_lijeve_strane], '''');
	else
		for j in 1..duljina_lijeve_strane-1 loop
			string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[j], '=''', $3, ''' and ');
		end loop;
		string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[duljina_lijeve_strane], '=''', $3, '''');
	end if;
	for j in 1..duljina_desne_strane-1 loop
		string_za_update_redova := concat(string_za_update_redova, desna_strana[j], '=(SELECT ', desna_strana[j], ' FROM pocetna_tablica ', string_za_where_uvjet, ' ORDER BY ', desna_strana[j], '::int limit 1), ');
	end loop;
	string_za_update_redova := concat(string_za_update_redova, desna_strana[duljina_desne_strane], ' =(SELECT ', desna_strana[duljina_desne_strane], ' FROM pocetna_tablica ', string_za_where_uvjet, ' ORDER BY ', desna_strana[duljina_desne_strane], '::int limit 1) ', string_za_where_uvjet, ';');
	execute string_za_update_redova;
end $_$;


ALTER FUNCTION public.izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(text, text, text) OWNER TO postgres;

--
-- Name: izvrsi_modifikacije_temeljem_zavisnosti_spoja(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.izvrsi_modifikacije_temeljem_zavisnosti_spoja(text[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	skup_atributa text[];
	i int;
	j int;
	string_za_stvaranje_projekcija text;
	string_za_izvrsavanje_prirodnog_spajanja text := 'CREATE TABLE privremena AS SELECT DISTINCT * FROM ';
	broj_atributa_iz_skupa int;
begin 
	for i in 1..array_length($1,1) loop
		skup_atributa := string_to_array($1[i], ' ');
		broj_atributa_iz_skupa := array_length(skup_atributa, 1);
		string_za_stvaranje_projekcija := concat('CREATE TABLE pom', i,' as select');
		for j in 1..broj_atributa_iz_skupa-1 loop
			string_za_stvaranje_projekcija := concat(string_za_stvaranje_projekcija, ' ', skup_atributa[j], ',');
		end loop;
		string_za_stvaranje_projekcija := concat(string_za_stvaranje_projekcija, ' ', skup_atributa[broj_atributa_iz_skupa], ' FROM pocetna_tablica;');
		execute string_za_stvaranje_projekcija;
	end loop;
	for i in 1..array_length($1,1)-1 loop
		string_za_izvrsavanje_prirodnog_spajanja := concat(string_za_izvrsavanje_prirodnog_spajanja, 'pom', i, ' natural join ');
	end loop;
	string_za_izvrsavanje_prirodnog_spajanja := concat(string_za_izvrsavanje_prirodnog_spajanja, 'pom', array_length($1,1), ';');
	execute string_za_izvrsavanje_prirodnog_spajanja;
	for i in 1..array_length($1,1) loop
		execute concat('DROP TABLE pom', i);
	end loop;
	execute 'DROP TABLE pocetna_tablica';
	execute 'ALTER TABLE privremena RENAME TO pocetna_tablica;';
end $_$;


ALTER FUNCTION public.izvrsi_modifikacije_temeljem_zavisnosti_spoja(text[]) OWNER TO postgres;

--
-- Name: napravi_pocetnu_tablicu(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.napravi_pocetnu_tablicu(text[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	brojAtributa int := array_length($1, 1);
	stringZaDodavanjeStupaca text;
	i int;
begin 
	drop table if exists pocetna_tablica;
	create table pocetna_tablica();
	for i in 1..brojAtributa loop
		stringZaDodavanjeStupaca := concat('ALTER TABLE pocetna_tablica ADD COLUMN ', $1[i], ' varchar(3);');	
		execute stringZaDodavanjeStupaca;
	end loop;
end $_$;


ALTER FUNCTION public.napravi_pocetnu_tablicu(text[]) OWNER TO postgres;

--
-- Name: popuni_pocetnu_tablicu(text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.popuni_pocetnu_tablicu(text[], text[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	broj_atributa int := array_length($1, 1);
	broj_dekompozicija int := array_length($2, 1);
	stupac text;
	dekompozicija text;
	red text[];
	string_za_dodavanje text;
begin
	for i in 1..broj_dekompozicija loop
		for y in 0..broj_atributa-1 loop
			stupac := (SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'pocetna_tablica'
				limit 1 offset y);
			dekompozicija := $2[i];
			if dekompozicija like '%' || stupac || '%' then
				--red[y] := concat('a', y+1);
				red[y] := concat('0');
			else
				--red[y] := concat('b',i, y+1);
				red[y] := concat(i, y+1);
			end if;
		end loop;
		string_za_dodavanje := 'INSERT INTO pocetna_tablica VALUES (';
		for y in 0..broj_atributa-2 loop	
			string_za_dodavanje := concat(string_za_dodavanje, '''', red[y], ''',');
		end loop;
		string_za_dodavanje := concat(string_za_dodavanje, '''', red[broj_atributa-1], ''');');
		execute string_za_dodavanje;
	end loop;
end $_$;


ALTER FUNCTION public.popuni_pocetnu_tablicu(text[], text[]) OWNER TO postgres;

--
-- Name: provjeri_funkcijske_zavisnosti(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_funkcijske_zavisnosti(text[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	broj_funkcijskih_zavisnosti int := array_length($1, 1);
	i int;
	j int;
	lijeva_strana text;
	desna_strana text;
	simbol text;
	simboli text[];
begin 
	for i in 1..broj_funkcijskih_zavisnosti loop
		lijeva_strana := $1[i][1];
		desna_strana := $1[i][2];
		if (select broj_podudaranja from dohvati_broj_podudaranja(lijeva_strana, desna_strana)) <> 0 then
			simboli := '{}';
			if length(lijeva_strana) = 1 then
				FOR simbol in (select lijeva_strana2 from dohvati_lijevu_stranu_char(lijeva_strana, desna_strana)) LOOP
			    	simboli := array_append(simboli, simbol);
			    END LOOP;
			else
				FOR simbol in (select lijeva_strana2 from dohvati_lijevu_stranu_text(lijeva_strana, desna_strana)) LOOP
			    	simboli := array_append(simboli, simbol);
			    END LOOP;
			end if;
			for j in 1..array_length(simboli,1) loop
				PERFORM izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(lijeva_strana, desna_strana, simboli[j]);
			end loop;
		end if;
	end loop;
end $_$;


ALTER FUNCTION public.provjeri_funkcijske_zavisnosti(text[]) OWNER TO postgres;

--
-- Name: provjeri_viseznacne_zavisnosti(text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.provjeri_viseznacne_zavisnosti(text[], text[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	broj_viseznacnih_zavisnosti int := array_length($2, 1);
	broj_atributa int := array_length($1, 1);
	i int;
	j int;
	polje_skupa_atributa text[];
begin 
	for i in 1..broj_viseznacnih_zavisnosti loop
		if (select broj_podudaranja from dohvati_broj_podudaranja($2[i][1], $2[i][2])) <> 0 then
			polje_skupa_atributa[1] := concat($2[i][1],' ', $2[i][2]);
			polje_skupa_atributa[2] := (select vrati_skup_atributa($1,$2[i][2]));
			perform izvrsi_modifikacije_temeljem_zavisnosti_spoja(polje_skupa_atributa);
		end if;
	end loop; 
end $_$;


ALTER FUNCTION public.provjeri_viseznacne_zavisnosti(text[], text[]) OWNER TO postgres;

--
-- Name: vrati_drugu_dekompoziciju_viseznacne_zavisnosti(text[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.vrati_drugu_dekompoziciju_viseznacne_zavisnosti(text[], text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
	brojAtributa int := array_length($1, 1);
	dekompozicija_polje text[];
	dekompozicija text := '';
	duljina_dekompozicija_polje int;
	sadrzi boolean := false;
	i int;
	j int;
begin 
	dekompozicija_polje := string_to_array($2, ' ');
	duljina_dekompozicija_polje := array_length(dekompozicija_polje, 1);
	for i in 1..brojAtributa loop
		sadrzi := false;
		for j in 1..duljina_dekompozicija_polje loop
			if $1[i] = dekompozicija_polje[j] then
				sadrzi := true;
			end if;
		end loop;
		if sadrzi = false and length(dekompozicija) = 0  then
		  	dekompozicija := $1[i];
		elsif sadrzi = false then
		  	dekompozicija := concat(dekompozicija, ' ', $1[i]);
		end if;
	end loop;
	return dekompozicija;
end $_$;


ALTER FUNCTION public.vrati_drugu_dekompoziciju_viseznacne_zavisnosti(text[], text) OWNER TO postgres;

--
-- Name: vrati_skup_atributa(text[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.vrati_skup_atributa(text[], text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare 
	broj_atributa int := array_length($1, 1);
	i int;
	j int;
	skup_atributa text;
	desna_strana text[];
	duljina_desne_strane int;
	sadrzi boolean;
	upisan_prvi_atribut boolean := false;
begin 
	skup_atributa := '';
	desna_strana := string_to_array($2, ' ');
	duljina_desne_strane := array_length(desna_strana, 1);
	for i in 1..broj_atributa loop
		sadrzi := false;
		for j in 1..duljina_desne_strane loop
			if $1[i] = desna_strana[j] then
				sadrzi := true;
			end if;
		end loop;
		if sadrzi = false and upisan_prvi_atribut = false then
			skup_atributa := concat(skup_atributa, $1[i]);
			upisan_prvi_atribut := true;
		elsif sadrzi = false then
			skup_atributa := concat(skup_atributa, ' ', $1[i]);
		end if;
	end loop;
	return skup_atributa;
end $_$;


ALTER FUNCTION public.vrati_skup_atributa(text[], text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: pocetna_tablica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pocetna_tablica (
    b character varying(3),
    a character varying(3),
    c character varying(3),
    d character varying(3)
);


ALTER TABLE public.pocetna_tablica OWNER TO postgres;

--
-- Data for Name: pocetna_tablica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pocetna_tablica (b, a, c, d) FROM stdin;
0	0	0	0
0	0	0	14
12	0	0	0
12	0	0	14
\.


--
-- PostgreSQL database dump complete
--

