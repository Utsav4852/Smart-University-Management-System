from unicodedata import category
import pyodbc
from face import *
from flask import Flask, request, jsonify

server = 'tcp:udatasetup.database.windows.net'
database = 'udatabase'
username = 'udatasetup'
password = 'Udata$2011$'
driver= '{ODBC Driver 17 for SQL Server}'

### IDENTIFY student, faculty or admin ###
def identify_student(identity):
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM [dbo].[profile] where identify="+identity)
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

    return jsonify(dict_data)

### INSERT into student table ###
def insert_query_profile(id,fname,lname,contactno,email,pwd,address,city,province,country,postalcode,identity, country_code):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO [dbo].[profile] (id, firstname, lastname, contact_no, email, password, address, city, province, country, postalcode, identify, country_code) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",(id,fname,lname,contactno,email,pwd,address,city,province,country,postalcode,identity, country_code))
    cursor.commit()
    cursor.close()

    status = 1

    return {'status_code' : status}

### UPDATE from student table ###
def update_query_profile(id,fname,lname,contactno,email,pwd,address,city,province,country,postalcode,identity,country_code,profile_pic_url):
    # try:

    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("UPDATE [dbo].[profile] SET firstname = ?, lastname = ?, contact_no = ?, email = ?, password = ?, address =?, city = ?, province = ?, country = ?, postalcode = ?, identify = ? , country_code = ?, profile_pic = ? WHERE id = ?", fname, lname, contactno,email,pwd,address,city,province,country,postalcode,identity,country_code,profile_pic_url,id)
    cursor.commit()
    cursor.close()
    status = 1
    
    # return return_update(id, status)
    
    # except Exception:
    #     return jsonify('error')

    return return_update(id, status)

def return_update(id, status):
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    rows = cursor.execute("SELECT * FROM [dbo].[profile] where id=?", id)

    rows = cursor.fetchall()
    row_data = []
    for row in rows:
        temp = []
        for i in row:
            temp.append(str(i).strip())
        row_data.append(temp)

    column_names = [i.column_name for i in cursor.columns(table='profile')]

    dict_data = []
    for i in row_data:
        dict_data.append(dict(zip(column_names,i)))
    return {'data': dict_data, 'status_code': status}

### DELETE from student table ###
def delete_query_profile(id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM [dbo].[profile]  WHERE id = ?",id)
    cursor.commit()
    cursor.close()
    status = 1
    return {'status_code' : status}


### SELECT from subject table ###
def select_query_subject(program_id):
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    if program_id == "":
        cursor.execute("SELECT * FROM [dbo].[subject] ")
        rows = cursor.fetchall()
        
        row_data = []
        for row in rows:
            temp = []
            for i in row:
                temp.append(str(i).strip())
            row_data.append(temp)

        column_names = [i.column_name for i in cursor.columns(table='subject')]

        dict_data = []
        for i in row_data:
            dict_data.append(dict(zip(column_names,i)))
    
    else:
        cursor.execute("SELECT * FROM [dbo].[subject] where program_id=?", program_id)
        rows = cursor.fetchall()
        
        row_data = [data for data in rows]

        column_names = [i.column_name for i in cursor.columns(table='subject')]

        dict_data = []
        for i in row_data:
            dict_data.append(dict(zip(column_names,i)))
        
    return {'data': dict_data}

### INSERT into subject table ###
def insert_query_subject(course_id, course_name, program_name, faculty, is_elective, program_id, term, time):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO [dbo].[subject] (course_id, course_name, program_name, faculty, is_elective, program_id, term, time) VALUES (?,?,?,?,?,?,?,?)", course_id, course_name, program_name, faculty, is_elective, program_id, term, time)
    cursor.commit()
    cursor.close()
    
    status = 1
    return {'status_code': status}

### UPDATE into subject table ###
def update_query_subject(course_id, course_name, program_name, faculty, is_elective, program_id, term, time):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("UPDATE [dbo].[subject] SET  course_name=?, program_name=?,faculty=?,is_elective=?,program_id=?, term=?, time=? WHERE course_id=?", course_name, program_name, faculty, is_elective, program_id, term,time, course_id)
    cursor.commit()
    cursor.close()

    status = 1

    if status == 1:
        conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
        cursor = conn.cursor()
        rows = cursor.execute("SELECT * FROM [dbo].[subject] where program_id=?", program_id)

        rows = cursor.fetchall()
        row_data = []
        for row in rows:
            temp = []
            for i in row:
                temp.append(str(i).strip())
            row_data.append(temp)

        column_names = [i.column_name for i in cursor.columns(table='subject')]

        dict_data = []
        for i in row_data:
            dict_data.append(dict(zip(column_names,i)))

    return{'data': dict_data,'status_code': status}

### DELETE from subject table ###
def delete_query_subject(course_id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM [dbo].[subject]  WHERE course_id = ?", course_id)
    cursor.commit()
    cursor.close()
    status = 1
    return {'status_code' : status}


### Update Long & lati subject table ###
def update_query_long_lati(longi, lati, id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("UPDATE [dbo].[profile] SET  longi=?, lati=? WHERE id=?", longi, lati, id)
    cursor.commit()
    cursor.close()

    status = 1
    return {'status_code' : status}

### select longi & Lati subject table ###
def select_query_longi_lati(id):
    status = 0
    conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = conn.cursor()
    cursor.execute("SELECT longi,lati FROM [dbo].[profile] WHERE id=?", id)
    rows = cursor.fetchall()

    longi = rows[0][0]
    lati = rows[0][1]

    status = 1
    return {'longi' : longi, 'lati':lati}