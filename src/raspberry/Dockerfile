FROM resin/rpi-raspbian:jessie

RUN apt-get update \
  apt-get install python python-pip python-dev gcc make

RUN pip install rpi.gpio

ADD motion_trigger_action.py motion_trigger_action.py

CMD ["python3", "motion_trigger_action.py"]
