# Smart-University-Management-System

The conventional university teaching and education management system has the issues of low stastics recall, negative statistics precision and long query time. In order to accomplish this goal here we are proposing the Smart University Management System to make it happen smartly. It is very hard for the tutor to schedule examinations, lectures and provide results in a short period of time just after the test. So, here we are proposing a smart solution that can help the educator to evaluate the student with the help of Artificial Intelligence and Machine Learning based algorithms. It will help professors to enhance the focus on other things. Apart from this, our platform will also contain features like live poll options to get real-time experience of knowledge. This is a very broad solution to add the features that can help evaluating the students which consists of the track of student progress.

We have developed main 5 features:
1. Attendance System
2. Course Recommendation System
3. Book Recommendation System
4. Auto Grading for Descriptive Answres
5. Surveillance System

## Attendance System
Face recognition is a demanding field for education, especially in terms of identifying the person. The greatest challenge for us is to perform face recognition with a very basic configuration of the system available on Azure. In order to get into the details of a system that with only 2 cores of CPU, 3.50 Gb RAM and 10 GB storage.
And we managed to operate this function over a minimal system by configuring a separate model for each student. To make it more reliable we added the location feature along with it. Students can successfully get their attendance only if they are within 100 meters of professor radius. Workflow of this system shown below:

![Face Recognition system](https://github.com/iOSDevKamal/Smart-University-Management-System/blob/main/Flow%20Charts/1.%20Face%20Recognition%20System.png)

## Course Recommendation System
Every student is worried about which courses they should take and sometimes they end up choosing the wrong one. We developed a system that can help students by suggesting courses based on their interests. All students have to submit their intent during the application process. To perform course recommendations our system will match two pieces of information; the first is student intent and the second is the course description. Workflow of this system shown below:

![Course Recommendation System](https://github.com/iOSDevKamal/Smart-University-Management-System/blob/main/Flow%20Charts/2.%20Course%20Recommendation%20System.png)

## Book Recommendation System
There are varieties of books available that can easily confuse students to choose a book related to their course. Our system can help students by suggesting the book according to their course description. Our system will take the latest books from the google books API and after performing operations it will suggest the best books.
Workflow of this system shown below:

![Book Recommendation System](https://github.com/iOSDevKamal/Smart-University-Management-System/blob/main/Flow%20Charts/3.%20Book%20Recommendation%20System.png)

## Auto Grading for Descriptive Answers
Sometimes it is hard for the professors to manege the multiple courses at the same time especially scoring the descirptive answers required exception efforts and time. It is the best solution for professor as it will score student automatically. Our system will perform 2 major operations; the first is grammaer check as it is very important and the second is comparing the answers with professors' answers. As the answers available onlien are not trustable every time as they can be outdated or faulty. after the frammer check, it will count the total grammatical mistakes and evaluate student according to a comparision rate. Workflow of this system shown below:

![Auto Grading for Descriptive Answers](https://github.com/iOSDevKamal/Smart-University-Management-System/blob/main/Flow%20Charts/4.%20Auto%20Grading%20for%20Descriptive%20Answers.png)

## Surveillance System
During this pandemic time, the majority of exams are done online. It is hard to detect whther a student is cheating or not. Our system will randomly take images at a random time and it will detect whether he/she is getting any help or not.  It will upload images to Azure storage. Later on, it will reflect on professor side with suspicious and match tags. Workflow of this system shown below:

![Surveillance System](https://github.com/iOSDevKamal/Smart-University-Management-System/blob/main/Flow%20Charts/5.%20Surveillance%20System.png)

## Code

We worked using python based object-orented programming language for API support and Swift for an iOS app. Python code available <a href='https://github.com/iOSDevKamal/Smart-University-Management-System/tree/main/Python%20Code'>here</a>. This folder contains 2 saperate folders to store the docker image because these containers also include environment files.
