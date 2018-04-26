FROM python:2

COPY . /src
WORKDIR /src

RUN pip install pipenv
RUN pipenv install --system
