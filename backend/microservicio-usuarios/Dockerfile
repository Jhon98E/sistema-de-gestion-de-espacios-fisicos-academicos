FROM python:3.13-alpine

WORKDIR /ms-usuarios

COPY ./requirements.txt /ms-usuarios/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /ms-usuarios/requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
