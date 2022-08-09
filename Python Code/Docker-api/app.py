
# from unicodedata import category
import pyodbc
from face import *
from admin import *
from professor import *
from student import *
from flask import Flask, request, jsonify
# from werkzeug.utils import secure_filename

server = 'tcp:udatasetup.database.windows.net'
database = 'udatabase'
username = 'udatasetup'
password = 'Udata$2011$'
driver= '{ODBC Driver 17 for SQL Server}'

app = Flask(__name__)

@app.route('/welcome')
def index():
    return 'New, API !'

################## STUDENT APIS ### START ##################

# from student.py
@app.route('/api/profile', methods=["POST"])
def login_details():    
    received_data = request.get_json()
    return login_data(received_data['data'])

# @app.route('/api/profile1', methods=["POST"])
# def login_details1():    
#     received_data = request.get_json()
#     id = received_data['id']
#     password = received_data['password']
#     return login_data1(id, password)

# from student.py
# @app.route('/api/profile-pic', methods=["POST"])
# def upload_picture():
#     # file = request.files['image']
#     request_data = request.get_json()
#     profile_pic = request_data['profile_url']
#     # id = file.filename.split('.')[0]
#     # id = request_data.get('id')
#     return profile_img(profile_pic)

# from face.py
# @app.route('/api/newface', methods=['POST'])
# def new_face():
#     request_name = request.get_json()
#     return face_training(request_name['name'])

# from face.py
@app.route('/api/face/train', methods=['POST'])
def face():
    request_data = request.get_json()
    container_name = request_data['student_id']
    return face_training(container_name)
# from face.py
@app.route('/api/face/recognize', methods=["POST"])
def recognize():
    # student_image = request.files['student_image']
    request_data = request.get_json()
    student_id = request_data['student_id']
    registered_course = request_data['registered_course']
    current_date = request_data['current_date']
    return face_recognition(student_id, registered_course, current_date)

# from student.py
@app.route('/api/student-course/registration', methods=['POST'])
def course_registration():
    request_data = request.get_json()
    student_id = request_data['student_id']
    registered_course = request_data['registered_course']
    term = request_data['term']
    student_name = request_data['student_name']
    return register_to_course(student_id, student_name,registered_course, term)

# from student.py
@app.route('/api/student-course/select', methods=['POST'])
def course_selection():
    request_data = request.get_json()
    student_id = request_data['student_id']
    term = request_data['term']
    return select_student_from_course(student_id, term)


# from student.py
@app.route('/api/library/prediction', methods=['POST'])
def book_prediction():
    request_data = request.get_json()
    prof_description = request_data['description']
    title = request_data['course_name']
    any_suggestion = request_data['any_suggestion']
    return predict_to_books(title, any_suggestion,prof_description)


# from student.py
@app.route('/api/student-course/prediction', methods=['POST'])
def course_prediction():
    request_data = request.get_json()
    student_intent = request_data['intent']
    program_id = request_data['program_id']
    return predict_to_course(student_intent, program_id)

################## STUDENT APIS ### END ##################


################## PROFESSOR APIS ### START ##################

@app.route('/api/professor/start-attendence', methods=['POST'])
def start_attendence():
    request_data = request.get_json()
    course_id = request_data['course_id']
    course_name = request_data['course_name']
    professor_name = request_data['professor_name']
    longi = request_data['longi']
    lati = request_data['lati']
    return add_data_to_attendence(course_id, course_name, professor_name, longi, lati)


@app.route('/api/prof-course/select', methods=['POST'])
def prof_course_selection():
    request_data = request.get_json()
    professor_id = request_data['professor_id']
    term = request_data['term']
    return select_professor_from_course(professor_id, term)

@app.route('/api/examine/student', methods=['POST'])
def check_student():
    # img = request.files['img']
    # exam_id = request.form['exam_id']
    # student_id = request.form['student_id']
    request_data = request.get_json()
    img = request_data['img']
    exam_id = request_data['exam_id']
    img_name = request_data['img_name']
    student_id = request_data['student_id']
    time = request_data['time']
    return examine_student_while_exam(img, img_name, exam_id,student_id, time)
################## PROFESSOR APIS ### END ##################



################## ADMIN APIS #### START #####################

# from admin.py
@app.route('/api/identify', methods=["POST"])
def select_student():
    request_identity = request.get_json()
    return identify_student(request_identity['identify'])

# from admin.py
@app.route('/api/insert', methods=['POST'])
def insert_data():
    request_data = request.get_json()
    id = request_data['id']
    fname = request_data['firstname']
    lname = request_data['lastname']
    contactno = request_data['contact_no']
    email = request_data['email']
    pwd = request_data['password']
    address = request_data['address']
    city = request_data['city']
    province = request_data['province']
    country = request_data['country']
    postalcode = request_data['postalcode']
    identity = request_data['identify']
    country_code = request_data['country_code']
    return insert_query_profile(id,fname,lname,contactno,email,pwd,address,city,province,country,postalcode,identity, country_code)

# from admin.py
@app.route('/api/update', methods=['POST'])
def update_data():
    request_data = request.get_json()
    id = request_data['id']
    fname = request_data['firstname']
    lname = request_data['lastname']
    contactno = request_data['contact_no']
    email = request_data['email']
    pwd = request_data['password']
    address = request_data['address']
    city = request_data['city']
    province = request_data['province']
    country = request_data['country']
    postalcode = request_data['postalcode']
    identity = request_data['identify']
    country_code = request_data['country_code']
    profile_pic_url = request_data['profile_pic']
   
    return update_query_profile(id,fname,lname,contactno,email,pwd,address,city,province,country,postalcode,identity,country_code,profile_pic_url)

# from admin.py
@app.route('/api/delete', methods=['POST'])
def delete_data():
    request_data = request.get_json()
    id = request_data['id']

    return delete_query_profile(id)


#from admin.py
@app.route('/api/subject/select', methods=['POST'])
def select_subject():
    request_data = request.get_json()
    program_id = request_data['program_id']

    return select_query_subject(program_id)

#from admin.apy
@app.route('/api/subject/insert', methods=['POST'])
def insert_subject():
    request_data = request.get_json()
    course_id = request_data['course_id']
    course_name = request_data['course_name']
    program_name = request_data['program_name']
    faculty = request_data['faculty']
    is_elective = request_data['is_elective']
    program_id = request_data['program_id']
    term = request_data['term']
    time = request_data['time']
    return insert_query_subject(course_id, course_name, program_name, faculty, is_elective, program_id, term, time)

@app.route('/api/subject/update', methods=['POST'])
def update_subject():
    request_data = request.get_json()
    course_id = request_data['course_id']
    course_name = request_data['course_name']
    program_name = request_data['program_name']
    faculty = request_data['faculty']
    is_elective = request_data['is_elective']
    program_id = request_data['program_id']
    term = request_data['term']
    time = request_data['time']
    return update_query_subject(course_id, course_name, program_name, faculty, is_elective, program_id, term, time)

@app.route('/api/subject/delete', methods=['POST'])
def delete_subject():
    request_data = request.get_json()
    course_id = request_data['course_id']

    return delete_query_subject(course_id)

@app.route('/api/location', methods=['POST'])
def update_location():
    request_data = request.get_json()
    id = request_data['id']
    longi = request_data['longi']
    lati = request_data['lati']
    return update_query_long_lati(longi, lati, id)

@app.route('/api/select/location', methods=['POST'])
def select_location():
    request_data = request.get_json()
    id = request_data['id']
    # longi = request_data['longi']
    # lati = request_data['lati']
    return select_query_longi_lati(id)

################## ADMIN APIS #### END ##################



if __name__ == '__main__':
    app.debug = True
    app.run()

