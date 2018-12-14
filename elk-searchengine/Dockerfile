FROM openjdk:8-alpine

WORKDIR /opt/elasticsearch-6.5.1

RUN wget -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.1.tar.gz | tar xzf - -C /opt

ENV ES_HOME=/opt/elasticsearch-6.5.1
ENV ES_JAVA_OPTS=-Xmx=100M -Xms=100M

CMD /opt/elasticsearch-6.5.1/bin/elasticsearch
