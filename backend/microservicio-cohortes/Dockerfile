FROM python:3.13-alpine

WORKDIR /ms-cohortes

COPY ./requirements.txt /ms-cohortes//requirements.txt
RUN pip install --no-cache-dir --upgrade -r /ms-cohortes/requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
