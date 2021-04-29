FROM python:3.8

RUN apt-get update && apt-get install cron -y
RUN pip install --upgrade pip

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY cron.conf /etc/cron.d/cron.conf
RUN chmod 0644 /etc/cron.d/cron.conf
RUN crontab /etc/cron.d/cron.conf

COPY . /app

CMD ["daphne", "-b", "0.0.0.0", "-p", "80", "server.asgi:application"]
