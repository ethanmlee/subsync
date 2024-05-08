FROM python:latest

# Disable output buffering for immediate logs
ENV PYTHONBUFFERED=1

RUN apt update && apt install -y libpocketsphinx-dev libsphinxbase-dev \
libavdevice-dev libavformat-dev libavfilter-dev libavcodec-dev libswresample-dev \
libswscale-dev libavutil-dev

WORKDIR /app/

COPY . .
COPY ./subsync/config.py.template subsync/config.py

RUN pip install -r requirements.txt
RUN pip install --use-pep517 .
