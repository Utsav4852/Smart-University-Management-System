# # For more information, please refer to https://aka.ms/vscode-docker-python
# # FROM python:3.8-bullseye
FROM python:3.9

# # Install some basic utilities

# # Install some basic utilities



EXPOSE 9001


# # Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# # Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1
ENV LISTEN_PORT=9001
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
# pyodbc driver install ==> start
RUN apt-get install gcc
ADD odbcinst.ini /etc/odbcinst.ini
RUN apt-get update
RUN apt-get install -y tdsodbc unixodbc-dev
RUN apt install unixodbc -y
RUN apt-get clean -y

RUN apt-get install apt-transport-https 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update

# # INSTALL ODBC DRIVER
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes

# # INSTALL SPACY MODEL
# RUN pip install spacy==2.0.18 https://github.com/explosion/spacy-models/releases/download/en_core_web_md-2.0.0/en_core_web_md-2.0.0.tar.gz

# # pyodbc driver install ==> end

COPY requirements.txt .

# # Install JAVA
RUN set -eux; \
    curl -Lso /tmp/openjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Linux_jdk-10.0.2%2B13.tar.gz; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz; \
    jdir=$(dirname $(dirname $(find /opt/java/openjdk -name javac))); \
    mv ${jdir}/* /opt/java/openjdk; \
    rm -rf ${jdir} /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
    


# # Install pip requirements
COPY requirements.txt .


# # Sample cv2 ===> start
RUN apt-get update -y && apt-get install -y build-essential cmake \
libsm6 libxext6 libxrender-dev \
python3 python3-pip python3-dev


# # sample cv2 ===> end

# # for cv2
RUN apt update; apt install -y libgl1

# # RUN python -c 'from sentence_transformers import SentenceTransformer; SentenceTransformer("all-MiniLM-L6-v2")'
# # RUN python -m pip install --upgrade pip


# RUN python -m spacy download en_core_web_md

RUN pip3 install -r requirements.txt

WORKDIR /app
COPY . .

# # Creates a non-root user with an explicit UID and adds permission to access the /app folder
# # For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# # RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# # USER appuser

# # During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
# # CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:9001", "--preload", "--access-logfile", "-", "--error-logfile", "-", "--timeout", "120"]
CMD ["app:app"]

# # ENTRYPOINT ["python3"]
# # CMD ["app.py"]
# # 

# For more information, please refer to https://aka.ms/vscode-docker-python
# FROM python:3.8
# FROM python:3.9


# EXPOSE 9001



# # Keeps Python from generating .pyc files in the container
# ENV PYTHONDONTWRITEBYTECODE=1


# # ENV FLASK_APP=app.py
# # RUN apk add --no-cache gcc musl-dev linux-headers


# # Turns off buffering for easier container logging
# ENV PYTHONUNBUFFERED=1
# ENV LISTEN_PORT=9001
# ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

# # pyodbc driver install ==> start
# RUN apt-get install gcc
# ADD odbcinst.ini /etc/odbcinst.ini
# RUN apt-get update
# RUN apt-get install -y tdsodbc unixodbc-dev
# RUN apt install unixodbc -y
# RUN apt-get clean -y

# RUN apt-get install apt-transport-https 
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update

# # INSTALL ODBC DRIVER
# RUN ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes

# # INSTALL SPACY MODEL
# # RUN pip install spacy==2.0.18 https://github.com/explosion/spacy-models/releases/download/en_core_web_md-2.0.0/en_core_web_md-2.0.0.tar.gz

# # pyodbc driver install ==> end

# # Install pip requirements
# COPY requirements.txt .


# # Sample cv2 ===> start
# # RUN apt-get update -y && apt-get install -y build-essential cmake \
# # libsm6 libxext6 libxrender-dev \
# # python3 python3-pip python3-dev


# # sample cv2 ===> end

# # for cv2
# # RUN apt update; apt install -y libgl1

# # RUN python -c 'from sentence_transformers import SentenceTransformer; SentenceTransformer("all-MiniLM-L6-v2")'
# # RUN python -m pip install pip==20.2.2
# COPY . .

# # RUN pip3 install scikit_learn-1.1.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
# # RUN pip3 install torch-1.12.0-cp38-cp38-manylinux1_x86_64.whl
# # RUN pip3 install scipy-1.8.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
# # RUN pip3 install sentence_transformers
# # RUN pip3 install scikit-learn
# RUN pip3 install -r requirements.txt

# # RUN python -m spacy download en_core_web_md

# WORKDIR /app

# # Creates a non-root user with an explicit UID and adds permission to access the /app folder
# # For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# # RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# # USER appuser

# # During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
# # CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
# ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:9001", "--preload", "--access-logfile", "-", "--error-logfile", "-", "--timeout", "120"]
# CMD ["app:app"]
# # CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

# # CMD ["gevent", "--bind", "0.0.0.0:8000", "app:app"]

