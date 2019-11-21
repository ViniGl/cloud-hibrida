import pymysql
from functools import partial
from flask import Flask, request
from flask_restful import Api, Resource
from datetime import datetime as time
import sys


app = Flask(__name__)
api = Api(app)


DATABASE = 'projetoCloud'
DATABASE_NAME = 'projetoCloud'
DATABASE_USER = 'vini'
DATABASE_PWD = '12345678'
DATABASE_HOST = sys.argv[1]


class Tarefas(Resource):
    def __init__(self, connection):
        self.conn = connection

    def getTime(self):
        return time.now.strftime("%d/%m/%Y - %H:%M:%S")

    def get(self):
        cursor = connection.cursor()
        q = 'SELECT * FROM tarefas;'
        cursor.execute(q)
        cursor.close()
        return cursor.fetchall(), 200

    def post(self):
        taskName = request.json["taskName"]
        cursor = connection.cursor()
        q = 'INSERT INTO tarefas (nome) VALUES (%s);'
        cursor.execute(q, taskName)
        cursor.close()
        return "Tarefa adicionada!", 200


class tarefaAPI(Resource):
    def __init__(self, connection):
        self.conn = connection

    def getTime(self):
        return time.now.strftime("%d/%m/%Y - %H:%M:%S")

    def get(self, id):
        cursor = connection.cursor()
        q = 'SELECT * FROM tarefas WHERE id_tarefa = %s;'
        cursor.execute(q, id)
        cursor.close()
        return cursor.fetchall(), 200

    def put(self, id):
        cursor = connection.cursor()
        q = 'UPDATE tarefas SET nome = %s WHERE id_tarefa = %s;'
        cursor.execute(q, (request.json["updatedTask"], id))
        cursor.close()
        return "Tarefa atualizada com sucesso", 200

    def delete(self, id):
        cursor = connection.cursor()
        q = 'DELETE FROM tarefas WHERE id_tarefa = %s;'
        cursor.execute(q, id)
        cursor.close()
        return "Tarefa deletada com sucesso", 200


class healthCheck(Resource):
    def get(self):
        return 200


if __name__ == '__main__':

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
	database=DATABASE,
        autocommit=True)

    db = partial(run_db_query, connection)

    api.add_resource(Tarefas(connection), '/Tarefa', endpoint='tarefas',
                     resource_class_kwargs={'connection': connection})
    api.add_resource(tarefaAPI, '/Tarefa/<int:id>', endpoint='tarefa',
                     resource_class_kwargs={'connection': connection})
    api.add_resource(healthCheck, '/healthcheck', endpoint='healthcheck')

    app.run(host='0.0.0.0', debug=True)
