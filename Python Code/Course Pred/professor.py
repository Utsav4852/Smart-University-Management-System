import ast, json
from re import L
import numpy as np
import pyodbc
from datetime import datetime
from flask import jsonify
import language_tool_python
import os
from datetime import datetime
from sentence_transformers import SentenceTransformer, util

server = 'Add server'
database = 'database name'
username = 'Add username'
password = '*******'
driver= '{ODBC Driver 17 for SQL Server}'



def select_professor_from_course(professor_id,term):
    conn = conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    if professor_id and not term:
        cursor.execute('SELECT * FROM [dbo].[prof_course] WHERE prof_id=?',professor_id)
        row_data = cursor.fetchall()
        row_data = [row for row in row_data]
        column_names = [column.column_name for column in cursor.columns(table='prof_course')]
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

    elif term and not professor_id:
        cursor.execute('SELECT * FROM [dbo].[prof_course] WHERE term=?',term)
        rows = cursor.fetchall()
        row_data = []
        for row in rows:
            temp = []
            for i in row:
                temp.append(str(i).strip())
            row_data.append(temp)
        column_names = [i.column_name for i in cursor.columns(table='prof_course')]

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

    elif professor_id and term:
        cursor.execute('SELECT * FROM [dbo].[prof_course] WHERE  prof_id=? AND term=?', professor_id, term)
        row_data = cursor.fetchall()
        row_data = [row for row in row_data]
        column_names = [column.column_name for column in cursor.columns(table='prof_course')]
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

def show_attendence_list(registered_course):
    conn = conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM [dbo].[transcript] WHERE  registered_course=? ', registered_course)
    row_data = cursor.fetchall()
    row_data = [row for row in row_data]
    column_names = [column.column_name for column in cursor.columns(table='transcript')]
    
    data = [dict(zip(column_names,data)) for data in row_data]

    return {'data': data}

def create_exam(exam_id, exam_name, professor_id, professor_name, que_ans, start_date, end_date, course_name,total_marks, duration):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    # select total_marks from exam table to update the student marks
    total_marks_data = ast.literal_eval(total_marks)
    print(total_marks_data)

    # select student name from the profile table
    cursor.execute('SELECT firstname, lastname from [dbo].[profile] WHERE id=?',professor_id)
    student_data = cursor.fetchall()
    student_name = ' '.join(student_data[0])

    new_dict = {}
    new_dict['total_marks'] = total_marks_data[professor_id]
    new_dict['name'] = student_name
    new_dict['id'] = professor_id

    total_marks_data[professor_id] = [new_dict]

    cursor.execute("INSERT INTO [dbo].[exam] (exam_id, exam_name, professor_id, professor_name, que_ans, start_date, end_date,course_name,total_marks,duration) VALUES (?,?,?,?,?,?,?,?,?,?)",(exam_id, exam_name, professor_id, professor_name, que_ans, start_date, end_date,course_name,str(json.dumps(total_marks_data)),duration))
    cursor.commit()
    cursor.close()
    status = 1
    return {'status' : status}

def select_exam(course_name):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM [dbo].[exam] WHERE course_name=?",course_name)
    rows = cursor.fetchall()
    row_data = []

    for row in rows:
        temp = []
        for i in row:
            temp.append(str(i).strip())
        row_data.append(temp)

    column_names = [i.column_name for i in cursor.columns(table='exam')]

    dict_data = []
    for i in row_data:
        dict_data.append(dict(zip(column_names,i)))

    status = 1
    return {'data': dict_data,'status' : status}

def publish_marks(exam_id, is_published):
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    cursor.execute("UPDATE [dbo].[exam] SET is_published=? WHERE exam_id=?",is_published, exam_id)
    cursor.commit()
    
    status = 1
    return {'status':status} 

def predict_score(total_marks, initial_answer, student_answer):
    tool = language_tool_python.LanguageToolPublicAPI('en-US')
    text = student_answer
    matches = tool.check(text)
    
    my_mistakes = []
    my_corrections = []
    start_positions = []
    end_positions = []

    for rules in matches:
        if len(rules.replacements)>0:
            start_positions.append(rules.offset)
            end_positions.append(rules.errorLength+rules.offset)
            my_mistakes.append(text[rules.offset:rules.errorLength+rules.offset])
            my_corrections.append(rules.replacements[0])

    my_new_text = list(text)

    for m in range(len(start_positions)):
        for i in range(len(text)):
            my_new_text[start_positions[m]] = my_corrections[m]
            if (i>start_positions[m] and i<end_positions[m]):
                my_new_text[i]=""

    my_new_text = "".join(my_new_text)
    model = SentenceTransformer('all-MiniLM-L6-v2')

    # Single list of sentences
    Initial_answer = initial_answer
    Student_answer = student_answer
    #Compute embeddings
    embeddings_1 = model.encode(Initial_answer, convert_to_tensor=True)
    embeddings_2 = model.encode(Student_answer, convert_to_tensor=True)
    #Compute cosine-similarities for each sentence with each other sentence
    cosine_scores = util.cos_sim(embeddings_1, embeddings_2)

    # #Find the pairs with the highest cosine similarity scores
    pairs = []
    for i in range(len(cosine_scores)):
        for j in range(i+1, len(cosine_scores)):
            pairs.append({'index': [i, j], 'score': cosine_scores[i][j]})

    #Sort scores in decreasing order
    pairs = sorted(pairs, key=lambda x: x['score'], reverse=True)

    for pair in pairs[0:10]:
        i, j = pair['index']
    
    final_score = cosine_scores * int(total_marks) - (len(my_mistakes)*0.025)
    final_score = float(final_score[0][0].numpy())
    final_score = round(final_score)

    if final_score > total_marks:
        final_score = total_marks
    else:
        final_score = final_score
        
    return dict(zip(my_mistakes,my_corrections)),final_score

def predict_to_marks(exam_id, professor_id, student_id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("SELECT que_ans FROM [dbo].[exam] WHERE exam_id=?",exam_id)
    rows = cursor.fetchall()
  
    que_ans_data = ast.literal_eval(rows[0][0])

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
    cursor.execute('SELECT total_marks FROM [dbo].[exam] WHERE exam_id=?', exam_id)
    total_marks_row = cursor.fetchall()
    total_marks_data = ast.literal_eval(total_marks_row[0][0])    

    # select student name from the profile table
    cursor.execute('SELECT firstname, lastname from [dbo].[profile] WHERE id=?',student_id)
    student_data = cursor.fetchall()
    student_name = ' '.join(student_data[0])

    total_marks_data[student_id][0]['total_marks'] = str(student_total_marks)
    total_marks_data[student_id][0]['name'] = student_name
    total_marks_data[student_id][0]['id'] = student_id

    # update total_marks in exam_table
    cursor.execute('UPDATE [dbo].[exam] SET total_marks=? WHERE exam_id=?',str(json.dumps(total_marks_data)), exam_id)
    cursor.commit()

    status = 1
    return {'status': status}


def pdf_report_submit(text,pdf):
    status = 0
    pdf.save('report.pdf')
    tool = language_tool_python.LanguageToolPublicAPI('en-US')
    matches = tool.check(text)
    
    my_mistakes = []
    my_corrections = []
    start_positions = []
    end_positions = []

    for rules in matches:
        if len(rules.replacements)>0:
            start_positions.append(rules.offset)
            end_positions.append(rules.errorLength+rules.offset)
            my_mistakes.append(text[rules.offset:rules.errorLength+rules.offset])
            my_corrections.append(rules.replacements[0])
    
    os.remove('report.pdf')
    status = 1
    return {'status':status}

