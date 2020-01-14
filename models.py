from dataclasses import dataclass
from datetime import date

@dataclass
class Patient:
    name: str = None
    patient_id: int = None
    patronymic: str = None
    surname: str = None
    gender: str = None
    birth_date: date = None
    mobile_number: str = None
    place: str = None
    address: str = None

@dataclass
class Doctor:
    doctor_id: int = None
    surname: str = None
    name: str = None
    patronymic: str = None
    doctor_spec: str = None