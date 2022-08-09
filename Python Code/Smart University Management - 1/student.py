from flask import Flask, request, jsonify
import pyodbc
import spacy
import numpy as np
import json
import requests
import language_tool_python
from sentence_transformers import SentenceTransformer, util

server = 'Add server'
database = 'database name'
username = 'Add username'
password = '*******'
driver= '{ODBC Driver 17 for SQL Server}'


def login_data(received_data):
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM [dbo].[profile]")
    rows = cursor.fetchall()

    row_data = []

    column_names = [i.column_name for i in cursor.columns(table='profile')]

    for row in rows:
        temp = []
        for i in row:
            temp.append(str(i).strip())
        row_data.append(temp)

    dict_data = []
    for i in row_data:
        dict_data.append(dict(zip(column_names,i)))

    if received_data.isdigit() == False:
        sort_data = [stu for stu in dict_data if stu['email'] == received_data]

    else:
        sort_data = [stu for stu in dict_data if stu['id'] == received_data]


    return jsonify(sort_data)

def register_to_course(student_id, student_name,registered_course, term):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute('INSERT INTO [dbo].[transcript] (student_id, student_name, registered_course, term) VALUES (?,?,?,?)',student_id,student_name,registered_course, term)
    cursor.commit()
    cursor.close()
    status = 1
    return {'status': status}

def select_student_from_course(student_id,term):
    conn = conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    if student_id and not term:
        cursor.execute('SELECT * FROM [dbo].[transcript] WHERE student_id=?',student_id)
        row_data = cursor.fetchall()
        row_data = [row for row in row_data]
        column_names = [column.column_name for column in cursor.columns(table='transcript')]
        data = [dict(zip(column_names,data)) for data in row_data]

        course_name = [i.get('registered_course') for i in data]
        course_column_name = [column.column_name for column in cursor.columns(table='subject')]
        
        final_course_data = []
        # subject table
        for name in course_name:
            cursor.execute('SELECT * FROM [dbo].[subject] WHERE course_name=?',name)
            course_data = cursor.fetchall()
            course_row_data = [row for row in course_data]
            final_course_data.append([dict(zip(course_column_name,data)) for data in course_row_data])

        
        dict_data = []

        for i in range(len(data)):
            dict_data.append(dict(data[i], **final_course_data[i][0]))
            
    elif term and not student_id:
        cursor.execute('SELECT * FROM [dbo].[transcript] WHERE term=?',term)
        rows = cursor.fetchall()
        row_data = []
        for row in rows:
            temp = []
            for i in row:
                temp.append(str(i).strip())
            row_data.append(temp)
        column_names = [i.column_name for i in cursor.columns(table='transcript')]

        data = [dict(zip(column_names,data)) for data in row_data]

        course_name = [i.get('registered_course') for i in data]
        
        final_course_data = []
        course_column_name = [column.column_name for column in cursor.columns(table='subject')]
        # subject table
        for name in course_name:
            cursor.execute('SELECT * FROM [dbo].[subject] WHERE course_name=?',name)
            course_data = cursor.fetchall()
            course_row_data = [row for row in course_data]
            
            final_course_data.append([dict(zip(course_column_name,data)) for data in course_row_data])

        dict_data = []

        for i in range(len(data)):
            dict_data.append(dict(data[i], **final_course_data[i][0]))

    elif student_id and term:
        cursor.execute('SELECT * FROM [dbo].[transcript] WHERE  student_id=? AND term=?', student_id, term)
        row_data = cursor.fetchall()
        row_data = [row for row in row_data]
        column_names = [column.column_name for column in cursor.columns(table='transcript')]
        data = [dict(zip(column_names,data)) for data in row_data]

        course_name = [i.get('registered_course') for i in data]
        
        final_course_data = []
        course_column_name = [column.column_name for column in cursor.columns(table='subject')]
        # subject table
        for name in course_name:
            cursor.execute('SELECT * FROM [dbo].[subject] WHERE course_name=?',name)
            course_data = cursor.fetchall()
            course_row_data = [row for row in course_data]
            
            final_course_data.append([dict(zip(course_column_name,data)) for data in course_row_data])

        dict_data = []

        for i in range(len(data)):
            dict_data.append(dict(data[i], **final_course_data[i][0]))
        
    return {'data': dict_data}


def predict_to_books(title,any_suggestion, prof_description):
    topic_name = title.lower().replace(' ', '+')
    query = 'intitle:' + topic_name
    params = {"q": query}
    url = r'https://www.googleapis.com/books/v1/volumes'
    response = requests.get(url, params=params)
    book_dict = response.json()

    nlp = spacy.load('en_core_web_md')

    suggested_books = []

    if any_suggestion == "True":
        for i in book_dict['items'][:10]:
            suggested_books.append(dict({'title': i['volumeInfo']['title'], 'authors': i['volumeInfo']['authors'], 'thumbnail' : i['volumeInfo']['imageLinks']['thumbnail'],
                                        'description' : i['volumeInfo']['description']}))
    else:
        for i in book_dict['items']:
            if 'description' in i['volumeInfo']:
                book_description = i['volumeInfo']['description']
                model = SentenceTransformer('all-MiniLM-L6-v2')

                cosine_scores = nlp(prof_description).similarity(nlp(book_description))

                if cosine_scores >= 0.90:
                    if 'imageLinks' in i['volumeInfo'].keys():
                        suggested_books.append(dict({'title': i['volumeInfo']['title'], 'authors': i['volumeInfo']['authors'],'thumbnail' : i['volumeInfo']['imageLinks']['thumbnail'],
                                        'description' : i['volumeInfo']['description']}))
                    else:
                        suggested_books.append(dict({'title': i['volumeInfo']['title'], 
                        'authors': i['volumeInfo']['authors'],
                        'thumbnail' : '',
                                        'description' : i['volumeInfo']['description']}))
    return {'data': suggested_books}

def predict_to_course(student_intent, program_id):

    nlp = spacy.load('en_core_web_md')

    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM [dbo].[subject] WHERE program_id=?', program_id)
    row_data = cursor.fetchall()

    column_names = [i.column_name for i in cursor.columns(table='subject')]

    row_data = [i for i in row_data]
    course_data = []

    for row in row_data:
        similarity = nlp(student_intent).similarity(nlp(row[-3]))
        if similarity >= 0.8:
            course_data.append(dict(zip(column_names,row)))

    return {'data': course_data}
