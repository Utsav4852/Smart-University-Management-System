from flask import Flask, request, jsonify
import pyodbc
import json
import spacy
import ast
import numpy as np
from professor import *

server = 'Add server'
database = 'database name'
username = 'Add username'
password = '*******'
driver= '{ODBC Driver 17 for SQL Server}'




def submit_exam_answers(exam_id, student_id,student_answer, professor_id):
    status = 0

    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    # Select que_ans column from exam table
    cursor.execute('SELECT que_ans FROM [dbo].[exam] WHERE exam_id=?', exam_id)
    que_ans_rows = cursor.fetchall()
    que_ans_data = ast.literal_eval(que_ans_rows[0][0])
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


    predict_to_marks(exam_id, professor_id, student_id)

    status = 1
    return {'status':status}
