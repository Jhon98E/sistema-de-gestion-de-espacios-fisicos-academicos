FROM python:3.13

WORKDIR /ms-asignaturas

COPY ./requirements.txt /ms-asignaturas/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /ms-asignaturas/requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
