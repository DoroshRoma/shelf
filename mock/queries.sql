/*create or replace function check_chronic_desease(patient integer)
 returns boolean as $$
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
$$ LANGUAGE plpgsql;
*/
/*
create or replace function is_doctor_busy(doctor integer, event_date date, event_time time)
    returns boolean as
$BODY$
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
$BODY$
LANGUAGE plpgsql;
*/
create or replace function add_new_event()
    returns trigger as 
$BODY$
begin
    IF NEW.event_start::date = NEW.event_end::date 
        and date_trunc('minute', NEW.event_start::time) = date_trunc('minute', NEW.event_end::time) 
    THEN
        RAISE EXCEPTION 'The start date cannot be equals to end date';
    END IF;

    RETURN NEW;
end;
$BODY$ LANGUAGE plpgsql;

CREATE trigger on_add_history_event
  BEFORE INSERT
  ON "History"
  FOR EACH ROW
  EXECUTE PROCEDURE add_new_event();