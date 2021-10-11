FROM python:3.10-slim

RUN apt-get update
RUN apt-get install -y --no-install-recommends libpq-dev cron build-essential libffi-dev

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get purge -y build-essential libffi-dev
RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean

COPY cron.conf /etc/cron.d/cron.conf
RUN chmod 0644 /etc/cron.d/cron.conf
RUN crontab /etc/cron.d/cron.conf

COPY . /app

CMD ["daphne", "-b", "0.0.0.0", "-p", "80", "server.asgi:application"]
