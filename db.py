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
            for i in range(len(records)):
                name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address = records[i]
                records[i] = Patient(name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address)
        elif table == 'Doctors':
            for i in range(len(records)):
                doctor_id, surname, name, patronymic, doctor_spec = records[i] 
                records[i] = Doctor(doctor_id, surname, name, patronymic, doctor_spec)

        return records

    def get_patient_by_id(self, id):
        self.cursor.execute(f'SELECT * FROM "Patients" where patient_id={id}')
        patient = self.cursor.fetchone()
        if patient is None:
            raise NotFound()

        name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address = patient
        return Patient(name, patient_id, patronymic, surname, gender, birth_date, mobile_number, place, address)

    def get_doctor_by_id(self, id):
        self.cursor.execute(f'SELECT * FROM "Doctors" where doctor_id={id}')
        doctor = self.cursor.fetchone()
        
        if doctor is None:
            raise NotFound()
        doctor_id, surname, name, patronymic, doctor_spec = doctor
        
        return Doctor(doctor_id, surname, name, patronymic, doctor_spec)

    def disconnect(self):
        self.cursor.close()
        self.conn.close()
