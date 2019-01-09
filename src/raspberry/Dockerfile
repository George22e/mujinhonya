FROM resin/rpi-raspbian:jessie

ENV LD_LIBRARY_PATH /opt/vc/lib

RUN apt-get update && \
  apt-get install python python-pip python-dev gcc make

RUN pip install rpi.gpio pathlib picamera pyyaml

ADD slack_config.yml slack_config.yml
RUN chmod 755 slack_config.yml
ADD motion_trigger_action.py motion_trigger_action.py
RUN chmod 755 motion_trigger_action.py

CMD ["python", "motion_trigger_action.py"]
