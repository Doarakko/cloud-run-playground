FROM python:3.9

COPY ./poetry.lock /app/poetry.lock
COPY ./pyproject.toml /app/pyproject.toml
COPY ./main.py /app/main.py

WORKDIR /app
RUN pip install -U pip
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install
RUN rm -rf ~/.cache

CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "${PORT}" ]
