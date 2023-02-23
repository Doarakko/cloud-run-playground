FROM python:3.11

WORKDIR /app

COPY ./poetry.lock /app/poetry.lock
COPY ./pyproject.toml /app/pyproject.toml
COPY ./main.py /app/main.py

RUN pip install -U pip
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install
RUN rm -rf ~/.cache

CMD [ "python", "main.py"]
