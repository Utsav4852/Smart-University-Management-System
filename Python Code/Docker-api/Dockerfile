# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.8

EXPOSE 8000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1
ENV LISTEN_PORT=8000
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

# INSTALL ODBC DRIVER
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes


# Install pip requirements
COPY requirements.txt .

# Sample cv2 ===> start
RUN apt-get update -y && apt-get install -y build-essential cmake \
libsm6 libxext6 libxrender-dev \
python3 python3-pip python3-dev

# sample cv2 ===> end

# for cv2
RUN apt update; apt install -y libgl1

RUN pip3 install -r requirements.txt

RUN python -m spacy download en_core_web_md

WORKDIR /app
COPY . .

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "--preload", "--access-logfile", "-", "--error-logfile", "-", "--timeout", "120"]
CMD ["app:app"]
