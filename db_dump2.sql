--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

-- Started on 2019-12-16 16:07:15

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
-- TOC entry 1 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 231 (class 1255 OID 16599)
-- Name: add_new_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_new_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    IF NEW.event_start::date = NEW.event_end::date 
        and date_trunc('minute', NEW.event_start::time) = date_trunc('minute', NEW.event_end::time) 
    THEN
        RAISE EXCEPTION 'The start date cannot be equals to end date';
    END IF;

    RETURN NEW;
end;
$$;


ALTER FUNCTION public.add_new_event() OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 16595)
-- Name: check_chronic_desease(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_chronic_desease(patient integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
   IF exists (select p.patient_id, d.desease_category from "Deseases" as d
   inner join "Patient_Desease" as pd using(desease_id)
   inner join "Patients" as p using(patient_id) 
   where p.patient_id = patient and d.desease_category like '%Chronic%')
    THEN return TRUE;
    ELSE
    return FALSE;
    END IF;
end;
$$;


ALTER FUNCTION public.check_chronic_desease(patient integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 16598)
-- Name: is_doctor_busy(integer, date, time without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_doctor_busy(doctor integer, event_date date, event_time time without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
    IF (select count(*)
        from "History" as h
        inner join "Doctor_History" as dh on h.event_id = dh.history_id
        inner join "Doctors" as d using(doctor_id)
        where h.event_start::date = event_date
        and date_trunc('minute', h.event_start::time) = event_time
        and d.doctor_id = doctor 
        ) != 0
        then return TRUE;
    ELSE
        return FALSE;
    END IF; 
end;
$$;


ALTER FUNCTION public.is_doctor_busy(doctor integer, event_date date, event_time time without time zone) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16489)
-- Name: Clinics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Clinics" (
    clinic_id integer NOT NULL,
    clinic_name text NOT NULL,
    clinic_description text NOT NULL,
    clinic_place text NOT NULL,
    clinic_address text NOT NULL
);


ALTER TABLE public."Clinics" OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16401)
-- Name: Deseases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Deseases" (
    desease_id integer NOT NULL,
    desease_name text NOT NULL,
    desease_category text NOT NULL,
    desease_description text NOT NULL
);


ALTER TABLE public."Deseases" OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16497)
-- Name: Doctor_Clinic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Doctor_Clinic" (
    doctor_id integer NOT NULL,
    clinic_id integer NOT NULL,
    dc_id integer NOT NULL
);


ALTER TABLE public."Doctor_Clinic" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16560)
-- Name: Doctor_History; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Doctor_History" (
    dhist_id integer NOT NULL,
    doctor_id integer NOT NULL,
    history_id integer NOT NULL
);


ALTER TABLE public."Doctor_History" OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 16445)
-- Name: Doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Doctors" (
    doctor_id integer NOT NULL,
    surname text NOT NULL,
    name text NOT NULL,
    patronymic text NOT NULL,
    doctor_spec text NOT NULL
);


ALTER TABLE public."Doctors" OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16414)
-- Name: Documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Documents" (
    doc_id integer NOT NULL,
    doc_description text NOT NULL
);


ALTER TABLE public."Documents" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 16427)
-- Name: History; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."History" (
    event_id integer NOT NULL,
    event_start timestamp with time zone NOT NULL,
    event_end timestamp with time zone NOT NULL,
    event_description text NOT NULL,
    patient_id integer NOT NULL,
    presc_id integer
);


ALTER TABLE public."History" OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16476)
-- Name: Medications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Medications" (
    med_id integer NOT NULL,
    med_type text NOT NULL,
    med_name text NOT NULL
);


ALTER TABLE public."Medications" OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 16530)
-- Name: Patient_Desease; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Patient_Desease" (
    pd_id integer NOT NULL,
    patient_id integer NOT NULL,
    desease_id integer NOT NULL
);


ALTER TABLE public."Patient_Desease" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16545)
-- Name: Patient_Doc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Patient_Doc" (
    pdoc_id integer NOT NULL,
    patient_id integer NOT NULL,
    document_id integer NOT NULL,
    doc_date timestamp with time zone NOT NULL
);


ALTER TABLE public."Patient_Doc" OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16393)
-- Name: Patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Patients" (
    name text NOT NULL,
    patient_id integer NOT NULL,
    patronymic text NOT NULL,
    surname text NOT NULL,
    gender text,
    birth_date date,
    mobile_number text NOT NULL,
    place text NOT NULL,
    address text NOT NULL
);


ALTER TABLE public."Patients" OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16511)
-- Name: Presc_Med; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Presc_Med" (
    pm_id integer NOT NULL,
    presc_id integer NOT NULL,
    med_id integer NOT NULL
);


ALTER TABLE public."Presc_Med" OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16463)
-- Name: Prescriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Prescriptions" (
    presc_id integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE public."Prescriptions" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16580)
-- Name: patients_master; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patients_master AS
 SELECT p.surname,
    d.desease_name,
    doc.doc_description
   FROM ((((public."Patients" p
     JOIN public."Patient_Desease" pd USING (patient_id))
     JOIN public."Deseases" d USING (desease_id))
     JOIN public."Patient_Doc" pdoc USING (patient_id))
     JOIN public."Documents" doc ON ((pdoc.document_id = doc.doc_id)));


ALTER TABLE public.patients_master OWNER TO postgres;

--
-- TOC entry 2764 (class 2606 OID 16496)
-- Name: Clinics PK_CLINIC; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Clinics"
    ADD CONSTRAINT "PK_CLINIC" PRIMARY KEY (clinic_id);


--
-- TOC entry 2766 (class 2606 OID 16527)
-- Name: Doctor_Clinic PK_DC; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_Clinic"
    ADD CONSTRAINT "PK_DC" PRIMARY KEY (dc_id);


--
-- TOC entry 2752 (class 2606 OID 16408)
-- Name: Deseases PK_DESEASES; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Deseases"
    ADD CONSTRAINT "PK_DESEASES" PRIMARY KEY (desease_id);


--
-- TOC entry 2774 (class 2606 OID 16564)
-- Name: Doctor_History PK_DHIST; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_History"
    ADD CONSTRAINT "PK_DHIST" PRIMARY KEY (dhist_id);


--
-- TOC entry 2758 (class 2606 OID 16452)
-- Name: Doctors PK_DOCTORS; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctors"
    ADD CONSTRAINT "PK_DOCTORS" PRIMARY KEY (doctor_id);


--
-- TOC entry 2754 (class 2606 OID 16421)
-- Name: Documents PK_DOCUMENTS; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Documents"
    ADD CONSTRAINT "PK_DOCUMENTS" PRIMARY KEY (doc_id);


--
-- TOC entry 2756 (class 2606 OID 16434)
-- Name: History PK_EVENT; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."History"
    ADD CONSTRAINT "PK_EVENT" PRIMARY KEY (event_id);


--
-- TOC entry 2762 (class 2606 OID 16483)
-- Name: Medications PK_MED; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Medications"
    ADD CONSTRAINT "PK_MED" PRIMARY KEY (med_id);


--
-- TOC entry 2770 (class 2606 OID 16534)
-- Name: Patient_Desease PK_PD; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Desease"
    ADD CONSTRAINT "PK_PD" PRIMARY KEY (pd_id);


--
-- TOC entry 2772 (class 2606 OID 16549)
-- Name: Patient_Doc PK_PDOC; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Doc"
    ADD CONSTRAINT "PK_PDOC" PRIMARY KEY (pdoc_id);


--
-- TOC entry 2768 (class 2606 OID 16529)
-- Name: Presc_Med PK_PM; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Presc_Med"
    ADD CONSTRAINT "PK_PM" PRIMARY KEY (pm_id);


--
-- TOC entry 2760 (class 2606 OID 16470)
-- Name: Prescriptions PK_PRESC; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescriptions"
    ADD CONSTRAINT "PK_PRESC" PRIMARY KEY (presc_id);


--
-- TOC entry 2750 (class 2606 OID 16400)
-- Name: Patients Patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patients"
    ADD CONSTRAINT "Patients_pkey" PRIMARY KEY (patient_id);


--
-- TOC entry 2787 (class 2620 OID 16611)
-- Name: History on_add_history_event; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_add_history_event BEFORE INSERT ON public."History" FOR EACH ROW EXECUTE FUNCTION public.add_new_event();

ALTER TABLE public."History" DISABLE TRIGGER on_add_history_event;


--
-- TOC entry 2778 (class 2606 OID 16505)
-- Name: Doctor_Clinic FK_CLINIC; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_Clinic"
    ADD CONSTRAINT "FK_CLINIC" FOREIGN KEY (clinic_id) REFERENCES public."Clinics"(clinic_id);


--
-- TOC entry 2782 (class 2606 OID 16540)
-- Name: Patient_Desease FK_DESEASE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Desease"
    ADD CONSTRAINT "FK_DESEASE" FOREIGN KEY (desease_id) REFERENCES public."Deseases"(desease_id);


--
-- TOC entry 2777 (class 2606 OID 16500)
-- Name: Doctor_Clinic FK_DOCTOR; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_Clinic"
    ADD CONSTRAINT "FK_DOCTOR" FOREIGN KEY (doctor_id) REFERENCES public."Doctors"(doctor_id);


--
-- TOC entry 2785 (class 2606 OID 16565)
-- Name: Doctor_History FK_DOCTOR; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_History"
    ADD CONSTRAINT "FK_DOCTOR" FOREIGN KEY (doctor_id) REFERENCES public."Doctors"(doctor_id);


--
-- TOC entry 2784 (class 2606 OID 16555)
-- Name: Patient_Doc FK_DOCUMENT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Doc"
    ADD CONSTRAINT "FK_DOCUMENT" FOREIGN KEY (document_id) REFERENCES public."Documents"(doc_id);


--
-- TOC entry 2786 (class 2606 OID 16570)
-- Name: Doctor_History FK_HISTORY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Doctor_History"
    ADD CONSTRAINT "FK_HISTORY" FOREIGN KEY (history_id) REFERENCES public."History"(event_id);


--
-- TOC entry 2780 (class 2606 OID 16521)
-- Name: Presc_Med FK_MED; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Presc_Med"
    ADD CONSTRAINT "FK_MED" FOREIGN KEY (med_id) REFERENCES public."Medications"(med_id);


--
-- TOC entry 2775 (class 2606 OID 16453)
-- Name: History FK_PATIENT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."History"
    ADD CONSTRAINT "FK_PATIENT" FOREIGN KEY (patient_id) REFERENCES public."Patients"(patient_id) NOT VALID;


--
-- TOC entry 2781 (class 2606 OID 16535)
-- Name: Patient_Desease FK_PATIENT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Desease"
    ADD CONSTRAINT "FK_PATIENT" FOREIGN KEY (patient_id) REFERENCES public."Patients"(patient_id);


--
-- TOC entry 2783 (class 2606 OID 16550)
-- Name: Patient_Doc FK_PATIENT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Patient_Doc"
    ADD CONSTRAINT "FK_PATIENT" FOREIGN KEY (patient_id) REFERENCES public."Patients"(patient_id);


--
-- TOC entry 2779 (class 2606 OID 16516)
-- Name: Presc_Med FK_PRESC; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Presc_Med"
    ADD CONSTRAINT "FK_PRESC" FOREIGN KEY (presc_id) REFERENCES public."Prescriptions"(presc_id);


--
-- TOC entry 2776 (class 2606 OID 16575)
-- Name: History FK_PRESC; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."History"
    ADD CONSTRAINT "FK_PRESC" FOREIGN KEY (presc_id) REFERENCES public."Prescriptions"(presc_id) NOT VALID;


-- Completed on 2019-12-16 16:07:15

--
-- PostgreSQL database dump complete
--

