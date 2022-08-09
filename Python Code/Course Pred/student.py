from flask import Flask, request, jsonify
import pyodbc
import json
import spacy
import ast
import numpy as np
from professor import *
# from sentence_transformers import SentenceTransformer, util

server = 'tcp:udatasetup.database.windows.net'
database = 'udatabase'
username = 'udatasetup'
password = 'Udata$2011$'
driver= '{ODBC Driver 17 for SQL Server}'

# def predict_to_course(student_intent, program_id):
#     spacy.cli.download("en_core_web_md")
#     # print('start')
#     nlp = spacy.load('en_core_web_md')
#     # print('finish')
#     conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
#     cursor = conn.cursor()
#     cursor.execute('SELECT * FROM [dbo].[subject] WHERE program_id=?', program_id)
#     row_data = cursor.fetchall()

#     column_names = [i.column_name for i in cursor.columns(table='subject')]

#     row_data = [i for i in row_data]
#     # print(row_data)
#     course_data = []

#     for row in row_data:
#         print(row)
#         similarity = nlp(student_intent).similarity(nlp(row[-3]))
#         # print(similarity)
#         if similarity >= 0.80:
#             course_data.append([[dict(zip(column_names,row))], [similarity]])

#     course_data = sorted(course_data, key = lambda x: x[1], reverse=True)[:2]
#     course_data = [i[0] for i in course_data]
#     return {'data': course_data}


def submit_exam_answers(exam_id, student_id,student_answer, professor_id):
    status = 0

    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    # Select que_ans column from exam table
    cursor.execute('SELECT que_ans FROM [dbo].[exam] WHERE exam_id=?', exam_id)
    que_ans_rows = cursor.fetchall()
    que_ans_data = ast.literal_eval(que_ans_rows[0][0])
    # print(que_ans_data)
    # print(student_answer)
    que_ans_data[student_id] = ast.literal_eval(student_answer)

    total_questions = len(que_ans_data[professor_id])

    student_total_marks = 0
    for i in range(total_questions):
        initial_answer = que_ans_data[professor_id][i]['answer']   
        student_answer = que_ans_data[student_id][i]['answer']
        marks = int(que_ans_data[professor_id][i]['mark'])
        mistakes_arr, predictions = predict_score(marks, initial_answer, student_answer)
        que_ans_data[student_id][i]['mistakes'] = [mistakes_arr]
        que_ans_data[student_id][i]['mark'] = str(predictions)
        student_total_marks += predictions
    
    # update student marks for eaach questions in que_ans column
    cursor.execute('UPDATE [dbo].[exam] SET que_ans=? WHERE exam_id=?',str(json.dumps(que_ans_data)), exam_id)
    cursor.commit()

    # select total_marks from exam table to update the student marks
    # cursor.execute('SELECT total_marks FROM [dbo].[exam] WHERE exam_id=?', exam_id)
    # total_marks_row = cursor.fetchall()
    # total_marks_data = ast.literal_eval(total_marks_row[0][0])
    # total_marks_data[student_id] = str(student_total_marks)

    # # update que_ans column in exam table
    # cursor.execute('UPDATE [dbo].[exam] SET total_marks=? WHERE exam_id=?', str(json.dumps(total_marks_data)), exam_id)
    # cursor.commit()

    predict_to_marks(exam_id, professor_id, student_id)

    status = 1
    return {'status':status}