import psycopg2

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
        return self.cursor.fetchall()        

    def disconnect(self):
        self.cursor.close()
        self.conn.close()

