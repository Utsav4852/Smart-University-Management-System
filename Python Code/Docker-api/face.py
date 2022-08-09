import PIL.Image as Image
import cv2
from flask import request, jsonify
import pyodbc
import os
import io
import json
from datetime import date
import numpy as np
import mediapipe as mp
from azure.storage.fileshare import ShareFileClient, ShareDirectoryClient
from azure.storage.common import CloudStorageAccount
from azure.storage.blob import BlobServiceClient, ContainerClient


## azure file storage connection ##
conn_str="*********"

storage_account_name = 'facedatafiles'
storage_account_key = '********************'

account = CloudStorageAccount(storage_account_name, storage_account_key)
file_service = account.create_file_service()

## azure blob storage connection ##

blob_service_client = BlobServiceClient.from_connection_string(conn_str)


def train_image(faces, Id, user_name):
    recognizer = cv2.face.LBPHFaceRecognizer_create()
    recognizer.train(faces, Id)
    recognizer.save(user_name+'.yml')
    file_client = ShareFileClient.from_connection_string(conn_str, share_name="facedatafiles/Faces_data/"+user_name, file_path=user_name+'.yml', dir_path='Faces_data')
    source_file = open(user_name+'.yml', "r")
    data = source_file.read()
    file_client.upload_file(data)
    source_file.close()
    os.remove(user_name+'.yml')
    return "Model Trained"



def face_training(container_name):
   
    mp_face_detection = mp.solutions.face_detection.FaceDetection(min_detection_confidence=0.5)

    container_client = blob_service_client.get_container_client(container_name)
    
    files = container_client.list_blobs()
    train_imgs = []
    train_label = []

    for file in files:
        if file.name != str(container_name):
            # Getting the images from blob
            blob_client = blob_service_client.get_blob_client(container=container_name,blob=file.name)
            blob_read = blob_client.download_blob().readall()
            img = np.array(Image.open(io.BytesIO(bytearray(blob_read))))
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            gray_img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            face_img = mp_face_detection.process(img)

            img_width = img.shape[1]
            img_height = img.shape[0]

            # Face detection among the images
            if face_img.detections:
                for detection in face_img.detections:
                    bounding_box = detection.location_data.relative_bounding_box
                    landmarks = detection.location_data.relative_keypoints

                    x = int(bounding_box.xmin * img_width)
                    w = int(bounding_box.width * img_width)
                    y = int(bounding_box.ymin * img_height)
                    h = int(bounding_box.height * img_height)

                    if x>0 and y>0:
                        detected_face = img[y:y+h, x:x+w]
                        test_img = cv2.resize(gray_img[y:y+h, x:x+w], (512,512))           
            
            train_imgs.append(test_img)
            train_label.append(1)
        else:
            pass
    
    recognizer = cv2.face.LBPHFaceRecognizer_create()
    user_train_img = np.array(train_imgs)
    user_label = np.array(train_label)

    recognizer.train(user_train_img, user_label)
    recognizer.save(container_name+'.yml')
    source_file = open(container_name+'.yml', "r")
    data = source_file.read()
    blob_client = blob_service_client.get_blob_client(container=container_name,blob=container_name)
    blob_client.upload_blob(data, overwrite=True)
    source_file.close()
    os.remove(container_name+'.yml')

    return "File upoaded in container successfully!"

def face_recognition(student_id, registered_course, current_date):
    
    # Container name
    container_name = student_id
    # container_name = student_image.filename.split('.')[0]
    
    # blobs = ContainerClient(account_url=url,container_name=container_name).list_blobs()

    container_client = blob_service_client.get_container_client(student_id)
    files = container_client.list_blobs()

    status = 0
    # Get image blob client
    attandance_img_client = blob_service_client.get_container_client('attendance')        
    attandance_files = attandance_img_client.list_blobs()

    for attandance in attandance_files:
        if attandance.name.split('.')[0] == student_id:
            blob_client = blob_service_client.get_blob_client(container='attendance',blob=attandance.name)
            blob_read = blob_client.download_blob().readall()
            pred_img = np.array(Image.open(io.BytesIO(bytearray(blob_read))))
    
    # files from blob for training
    for file in files:
        if file.name == container_name:
            
            blob_client = blob_service_client.get_blob_client(container=container_name,blob=file.name)

            with open(container_name+'.yml', "wb") as download_file:
                download_file.write(blob_client.download_blob().readall())

            reco = cv2.face.LBPHFaceRecognizer_create()
            reco.read(container_name+'.yml')
            
           
            img = cv2.cvtColor(pred_img, cv2.COLOR_BGR2RGB)
            # img = cv2.resize(img, (512,512))
            gray_img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            # face_img = mp_face_detection.process(img)

            img_width = img.shape[1]
            img_height = img.shape[0]
            
            # Face detection
            mp_face_detection = mp.solutions.face_detection

            with mp_face_detection.FaceDetection(min_detection_confidence=0.5) as face_detection:
                
                image = cv2.cvtColor(pred_img ,cv2.COLOR_BGR2RGB)
                image = cv2.resize(image ,(512,512))
                img_width = image.shape[1]
                img_height = image.shape[0]
                results = face_detection.process(image)
                if results.detections:
                    for detection in results.detections:
                        bounding_box = detection.location_data.relative_bounding_box
                        landmarks = detection.location_data.relative_keypoints

                        x = int(bounding_box.xmin * img_width)
                        w = int(bounding_box.width * img_width)
                        y = int(bounding_box.ymin * img_height)
                        h = int(bounding_box.height * img_height)

                        if x>0 and y>0:
                            detected_face = image[y:y+h, x:x+w]
                            test_img = cv2.resize(gray_img[y:y+h, x:x+w], (512,512))
            
            # predicting new image
            Id, coef = reco.predict(test_img)
            # print(coef)

            if coef > 100:
                status = 0
            else:
                status = 1

            download_file.close()
            os.remove(container_name+'.yml')
        else:
            pass

    if status == 1:       
        server = 'Add server'
        database = 'database name'
        username = 'Add username'
        password = '*******'
        driver= '{ODBC Driver 17 for SQL Server}'
        conn = pyodbc.connect('DRIVER='+driver+';PORT=1433;SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
        cursor = conn.cursor()
        cursor.execute("SELECT attendance FROM [dbo].[transcript] WHERE student_id=? AND registered_course=?", student_id, registered_course)
        rows_data = cursor.fetchone()
        previous_date = rows_data[0]

        if current_date in previous_date:
            status = 2
            
        else:
            new_attendance_date = previous_date + ','+current_date
            cursor.execute("UPDATE [dbo].[transcript] SET attendance=? WHERE student_id=? AND registered_course=?", new_attendance_date, student_id, registered_course)
            cursor.commit()
            cursor.close()
            

    return {"status_code":status}
