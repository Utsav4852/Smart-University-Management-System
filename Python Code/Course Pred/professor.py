import ast, json
from re import L
import numpy as np
import pyodbc
from datetime import datetime
from flask import jsonify
import language_tool_python

import os
# from azure.storage.blob import BlobServiceClient
# import cv2
# import PIL.Image as Image
# import io
from datetime import datetime
# import mediapipe as mp

from sentence_transformers import SentenceTransformer, util
# from datetime import datetime

server = 'tcp:udatasetup.database.windows.net'
database = 'udatabase'
username = 'udatasetup'
password = 'Udata$2011$'
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
            
            # print('column_name=>', course_column_name)
            final_course_data.append([dict(zip(course_column_name,data)) for data in course_row_data])

        dict_data = []

        for i in range(len(data)):
            # new_dic = data[i].copy()
            dict_data.append(dict(data[i], **final_course_data[i][0]))
        # cursor.execute('SELECT ')

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
            # new_dic = data[i].copy()
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
            
            # print('column_name=>', course_column_name)
            final_course_data.append([dict(zip(course_column_name,data)) for data in course_row_data])

        dict_data = []

        for i in range(len(data)):
            # new_dic = data[i].copy()
            dict_data.append(dict(data[i], **final_course_data[i][0]))
            # print(final_course_data[i][0])
            # print(data[i])
        
    return {'data': dict_data}

def show_attendence_list(registered_course):
    conn = conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM [dbo].[transcript] WHERE  registered_course=? ', registered_course)
    row_data = cursor.fetchall()
    row_data = [row for row in row_data]
    column_names = [column.column_name for column in cursor.columns(table='transcript')]
    
    data = [dict(zip(column_names,data)) for data in row_data]

    # # all student list from profile table
    # cursor.execute('SELECT (id, firstname, lastname) FROM [dbo].[profile] WHERE program_id=?', program_id)

    # dict_data = {'student_name':{},'student_id': {}, 'Attendance': {}, 'Date': {}}

    # for i in data:
    #     date = datetime.now()
    #     date = date.strftime("%d/%m/%Y")
    #     # print(date)
    #     if i['attendance']:
    #         if str(i['attendance'].split(',')[-1]) == date:
    #             dict_data.append(i['student_name'],i['student_id'], True)
    #         else:
    #             dict_data.append([i['student_name'],i['student_id'], False])

        # break

    # data = []

    return {'data': data}

def create_exam(exam_id, exam_name, professor_id, professor_name, que_ans, start_date, end_date, course_name,total_marks, duration):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()

    # select total_marks from exam table to update the student marks
    # cursor.execute('SELECT total_marks FROM [dbo].[exam] WHERE exam_id=?', exam_id)
    # total_marks_row = cursor.fetchall()
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

    # print(new_dict)
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
        # print("{} \t\t {} \t\t Score: {:.4f}".format(sentences[i], sentences[j], pair['score']))
    
#     if cosine_scores > 0.95:
#         return cosine_scores == 1
#     else:
#         return cosine_scores
    
    final_score = cosine_scores * int(total_marks) - (len(my_mistakes)*0.025)
    final_score = float(final_score[0][0].numpy())
    final_score = round(final_score)

    if final_score > total_marks:
        final_score = total_marks
    else:
        final_score = final_score
    
#     if final_score > 5:
#         return final_score == 5
#     else:
#         return final_score
        
    return dict(zip(my_mistakes,my_corrections)),final_score

def predict_to_marks(exam_id, professor_id, student_id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("SELECT que_ans FROM [dbo].[exam] WHERE exam_id=?",exam_id)
    rows = cursor.fetchall()
    # print(rows)

    que_ans_data = ast.literal_eval(rows[0][0])
    # que_ans_data = ast.literal_eval(que_ans_data[0][0])
    # print(que_ans_data)

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
    # total_marks_data = ast.literal_eval(total_marks_data[0][0])
    
    # total_marks_data[student_id] = student_total_marks

    # select student name from the profile table
    cursor.execute('SELECT firstname, lastname from [dbo].[profile] WHERE id=?',student_id)
    student_data = cursor.fetchall()
    student_name = ' '.join(student_data[0])

    # new_dict = {}

    # if student_id in total_marks_data

    total_marks_data[student_id][0]['total_marks'] = str(student_total_marks)
    total_marks_data[student_id][0]['name'] = student_name
    total_marks_data[student_id][0]['id'] = student_id

    # print(new_dict)
    # total_marks_data[student_id] = [new_dict]
    
    # total_marks_data[student_id]['total_marks'] = student_total_marks
    # total_marks_data[student_id]['student_name'] = student_name

    # print(total_marks_data)
    # print('_'.join(data[0]))

    # update total_marks in exam_table
    cursor.execute('UPDATE [dbo].[exam] SET total_marks=? WHERE exam_id=?',str(json.dumps(total_marks_data)), exam_id)
    cursor.commit()

    status = 1
    return {'status': status}


def pdf_report_submit(text,pdf):
    status = 0
    pdf.save('report.pdf')
    # print(text)
    tool = language_tool_python.LanguageToolPublicAPI('en-US')
    # text = student_answer
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
    
    # print(my_mistakes)
    os.remove('report.pdf')
    status = 1
    return {'status':status}



# def examine_student_while_exam(img, student_id):
#     status = 0

#     print('started!')
#     conn_str = "DefaultEndpointsProtocol=https;AccountName=studentcheckforexam;AccountKey=CnA0BkatBHXw0xeal3zHvYFvhws04UnR0NeW9/3LqyOXcproZY1iOsfQ9JtXDVcGA5BouAXjfd6l+ASt3J4Erw==;EndpointSuffix=core.windows.net"

#     blob_service_client = BlobServiceClient.from_connection_string(conn_str)
    
#     container_client = blob_service_client.get_container_client(student_id)
#     # files =  container_client.list_blobs()

#     files = blob_service_client.list_containers()

#     file_names = []
#     for file in files:
#         file_names.append(str(file.name))
    

#     if student_id in file_names:
        
#         # name_lists = []
        
            
#         date = datetime.now()
#         new_blob_name = date.strftime('%d%m%Y_%H%M%S') 
        
#         img_container = container_client.upload_blob(name=new_blob_name+".jpg",data=img)

#         # print(img_container.get_blob_properties())
        
#         # pred_blob_client = container_client_student_id.download_blob().readall()

#     else:
        
#         blob_service_client.create_container(str(student_id), public_access='container')
        
#         date = datetime.now()
#         new_blob_name = date.strftime('%d%m%Y_%H%M%S') 

#         img_container = container_client.upload_blob(name=new_blob_name+".jpg",data=img)

#     container_client_student_id = blob_service_client.get_container_client(student_id)
    
#     for blob in container_client_student_id.list_blobs():
#         if blob.name.split('.')[0] == new_blob_name:
            
#             file = container_client_student_id.download_blob(blob.name).readall()
#             pred_img = np.array(Image.open(io.BytesIO(bytearray(file))))

#             # img = cv2.resize(pred_img, (512,512))
#             # img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
#             # gray_img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            
#             # img_width = img.shape[1]
#             # img_height = img.shape[0]

#             mp_face_detection = mp.solutions.face_detection
#             print(mp_face_detection)

#             with mp_face_detection.FaceDetection(min_detection_confidence=0.5) as face_detection:
#                 # pred_img = np.array(Image.open(io.BytesIO(student_image.read())))
#                 # pred_img = cv2.imread(container_name+'.png')
#                 image = cv2.cvtColor(pred_img ,cv2.COLOR_BGR2RGB)
#                 print(image)
#                 image = cv2.resize(image ,(512,512))
#                 gray_img = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
#                 img_width = image.shape[1]
#                 img_height = image.shape[0]
#                 results = face_detection.process(image)

#                 print(results)


#                 if results.detections:
#                     for detection in results.detections:
#                         bounding_box = detection.location_data.relative_bounding_box
#                         landmarks = detection.location_data.relative_keypoints

#                         x = int(bounding_box.xmin * img_width)
#                         w = int(bounding_box.width * img_width)
#                         y = int(bounding_box.ymin * img_height)
#                         h = int(bounding_box.height * img_height)

#                         if x>0 and y>0:
#                             detected_face = image[y:y+h, x:x+w]
#                             test_img = cv2.resize(gray_img[y:y+h, x:x+w], (512,512))
#                             print('Prediction face is ready!')
            
#             conn_str_yml = "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net"

#             blob_service_client_yml = BlobServiceClient.from_connection_string(conn_str_yml)
#             blob_client_yml = blob_service_client_yml.get_blob_client(container=student_id, blob=student_id)

#             container_client_yml = blob_service_client_yml.get_container_client(student_id)
#             files_yml = container_client_yml.list_blobs()

#             for file in files_yml:
#                 # print(file.name)
#                 if file.name == student_id:
#                     with open(student_id+'.yml', 'wb') as download_file:
#                         download_file.write(blob_client_yml.download_blob().readall())
                    
#                     print('Prediction file is ready!')
                    
#                     reco = cv2.face.LBPHFaceRecognizer_create()
#                     reco.read(student_id+'.yml')
#             # predicting new image
#                     Id, coef = reco.predict(test_img)
#                     print('coef=>',coef)
#                     # if coef > 100:
#                         # status = 0
#                     # else:
#                         # status = 1

#                     download_file.close()
#                     # os.remove(student_id+'.yml')
  
        
# # 
#     status = 1
#     return {'status': status}
