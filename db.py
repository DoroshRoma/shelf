import psycopg2
from models import Patient, Doctor
from mess import NotFound

class MedicDB(object): 
    _instance = None
    def __new__(cls, password):
        if not cls._instance:
            cls._instance = super().__new__(cls)
        
        return cls._instance
    
    def __init__(self, password, dbname='postgres', user='postgres', host='localhost'):
        self.conn = psycopg2.connect(dbname=dbname, user=user,
                                     password=password, host=host)
        self.cursor = self.conn.cursor()

    def get_all_from_table(self, table):
        self.cursor.execute(f'SELECT * FROM "{table}"')
        records = self.cursor.fetchall()
        
        if records is None:
            raise NotFound()

        if table == 'Patients':
            # For better performance
            records = self._parse_patients(records)

        elif table == 'Doctors':
            records = self._parse_doctors(records)

        return records

    def get_patient_by_id(self, id):
        self.cursor.execute(f'SELECT * FROM "Patients" where patient_id={id}')
        patient = self.cursor.fetchone()
        
        if patient is None:
            raise NotFound()

        return self._parse_patients(patient)

    def get_doctor_by_id(self, id):
        self.cursor.execute(f'SELECT * FROM "Doctors" where doctor_id={id}')
        doctor = self.cursor.fetchone()
        
        if doctor is None:
            raise NotFound()

        return self._parse_doctors(doctor)

    def get_doctors_for_patient(self, patient_id):
        self.cursor.execute(f'''
                            select distinct d.* from "Doctors" as d join "Doctor_History" as dh
                            on d.doctor_id = dh.doctor_id join "History" as h on dh.history_id = h.event_id
                            where h.patient_id = {patient_id};
                            ''')
        records = self.cursor.fetchall()
        if records is None:
            raise NotFound()

        return self._parse_doctors(records)
    
    def _parse_patients(self, records):
        if not isinstance(records, list):
            name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address = records
            return Patient(name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address)
        
        for i in range(len(records)):
                name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address = records[i]
                records[i] = Patient(name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address)
        return records

    def _parse_doctors(self, records):
        if not isinstance(records, list):
            doctor_id, surname, name, patronymic, doctor_spec = records
            return Doctor(doctor_id, surname, name, patronymic, doctor_spec)
        
        for i in range(len(records)):
                doctor_id, surname, name, patronymic, doctor_spec = records[i] 
                records[i] = Doctor(doctor_id, surname, name, patronymic, doctor_spec)
        return records

    def disconnect(self):
        self.cursor.close()
        self.conn.close()
