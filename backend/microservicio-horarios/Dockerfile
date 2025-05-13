FROM python:3.13-alpine

WORKDIR /ms-horarios

COPY ./requirements.txt /ms-horarios/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /ms-horarios/requirements.txt

COPY . .

EXPOSE 8005

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8005", "--reload"]
