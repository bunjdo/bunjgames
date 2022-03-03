FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev build-essential libffi-dev && \
    apt-get install -y ffmpeg libavcodec-extra

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get purge -y build-essential libffi-dev
RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean

COPY . /app

CMD ["daphne", "-b", "0.0.0.0", "-p", "80", "server.asgi:application"]
