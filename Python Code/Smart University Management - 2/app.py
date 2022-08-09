from flask import Flask, request
from student import *
from professor import *

app = Flask(__name__)

@app.route('/welcome')
def index():
    return 'Welcome !'


# from student.py
@app.route('/api/exam/student_exam_update', methods=['POST'])
def update_question_in_exam():
    request_data = request.get_json()
    student_id = request_data['student_id']
    exam_id = request_data['exam_id']
    student_answer = request_data['student_ans']
    professor_id = request_data['professor_id']
    return submit_exam_answers(exam_id, student_id, student_answer, professor_id)

#  from professor.py
@app.route('/api/prof/select', methods=['POST'])
def prof_course_selection():
    request_data = request.get_json()
    professor_id = request_data['professor_id']
    term = request_data['term']
    return select_professor_from_course(professor_id, term)

# from professor.py
@app.route('/api/prof/get_attendence_list', methods=['POST'])
def attendence_list():
    request_data = request.get_json()
    registered_course = request_data['registered_course']
    # program_id = request_data['program_id']
    return show_attendence_list(registered_course)

# from professor.py
@app.route('/api/predict-score', methods=['POST'])
def descriptive_answer_prediction():
    request_data = request.get_json()
    exam_id = request_data['exam_id']
    professor_id = request_data['professor_id']
    student_id = request_data['student_id']
    return predict_to_marks(exam_id,professor_id, student_id)

# from professor.py
@app.route('/api/exam/insert', methods=['POST'])
def insert_data_from_exam():
    request_data = request.get_json()
    exam_id = request_data['exam_id']
    exam_name = request_data['exam_name']
    professor_id = request_data['professor_id']
    professor_name = request_data['professor_name']
    que_ans = request_data['que_ans']
    start_date = request_data['start_date']
    end_date = request_data['end_date']
    course_name = request_data['course_name']
    total_marks = request_data['total_marks']
    duration = request_data['duration']
    return create_exam(exam_id, exam_name, professor_id, professor_name, que_ans, start_date, end_date, course_name,total_marks, duration)

# from professor.py
@app.route('/api/exam/select', methods=['POST'])
def select_data_from_exam():
    request_data = request.get_json()
    course_name = request_data['course_name']
    return select_exam(course_name)

# from professor.py
@app.route('/api/exam/publish_marks', methods=['POST'])
def publish_exam_marks():
    request_data = request.get_json()
    exam_id = request_data['exam_id']
    is_publihsed = request_data['is_published']
    return publish_marks(exam_id, is_publihsed)

#  from professor.py
@app.route('/api/assignment/report', methods=['POST'])
def submit_report():
    request_data = request.get_json()
    # pdf_text = request_data['text']
    text = request.form['text']
    pdf = request.files['file']
    return pdf_report_submit(text, pdf)

if __name__ == '__main__':
    app.debug = True
    app.run()
