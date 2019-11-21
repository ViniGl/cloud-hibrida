import pymysql
from functools import partial

DATABASE_NAME = 'projetoCloud'
DATABASE_USER = 'vini'
DATABASE_PWD = '12345678'
DATABASE_HOST = 'localhost'


def run_db_query(connection, query, args=None):
    with connection.cursor() as cursor:
        print('Executando query:')
        cursor.execute(query, args)
        for result in cursor:
            print(result)


connection = pymysql.connect(
    host=DATABASE_HOST,
    user=DATABASE_USER,
    password=DATABASE_PWD,
    autocommit=True)

db = partial(run_db_query, connection)


def createDB(database_name=DATABASE_NAME):
    db('DROP DATABASE IF EXISTS {};'.format(database_name))
    db('CREATE DATABASE {};'.format(database_name))
    db('USE {};'.format(database_name))


def createTables():
    db('''DROP TABLE IF EXISTS tarefas;''')
    db('''CREATE TABLE tarefas (
            id_tarefa INT NOT NULL AUTO_INCREMENT,
            nome VARCHAR(255) NOT NULL,
            PRIMARY KEY (id_tarefa)); ''')


createDB()
createTables()
