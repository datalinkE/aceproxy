# Используем за основу контейнера phusion/baseimage
FROM phusion/baseimage:0.9.18

# Переключаем Ubuntu в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive

#Задаём порты
EXPOSE 22 8000 8621 62062 9944 9903

#Прбрасываем папку с конфигами aceproxy
VOLUME /etc/aceproxy

# Устанавливаем локаль
RUN locale-gen ru_RU.UTF-8

RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN echo 'deb http://repo.acestream.org/ubuntu/ trusty main' > /etc/apt/sources.list.d/acestream.list
RUN cd /tmp
RUN curl -O http://repo.acestream.org/keys/acestream.public.key
RUN apt-key add acestream.public.key
RUN apt-get update -y
RUN apt-get install -y wget mc nano
RUN apt-get install -y acestream-engine git python-gevent unzip ca-certificates supervisor python-setuptools python-pip python-dev build-essential
RUN pip install --upgrade pip
RUN pip install greenlet gevent psutil 
RUN wget http://dl.acestream.org/ubuntu/14/acestream_3.0.5.1_ubuntu_14.04_x86_64.tar.gz
RUN tar -xf acestream_3.0.5.1_ubuntu_14.04_x86_64.tar.gz
RUN rm -rf /usr/share/acestream/*
RUN rm -rf /usr/bin/acestreamengine
RUN cp -r acestream_3.0.5.1_ubuntu_14.04_x86_64/data /usr/share/acestream
RUN cp  -r acestream_3.0.5.1_ubuntu_14.04_x86_64/lib /usr/share/acestream
RUN cp -r acestream_3.0.5.1_ubuntu_14.04_x86_64/acestream.conf /usr/share/acestream
RUN cp -r acestream_3.0.5.1_ubuntu_14.04_x86_64/acestreamengine /usr/bin/acestreamengine
 
# Добавляем пользователя "tv" 
RUN adduser --disabled-password --gecos "" tv 

RUN git clone https://github.com/AndreyPavlenko/aceproxy.git 
RUN mv ./aceproxy /home/tv/aceproxy-master 

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD start.sh /start.sh 
RUN chmod +x /start.sh

# Подчищаем
RUN apt-get clean
RUN rm -rf acestream_3.0.5.1_ubuntu_14.04_x86_64.tar.gz
RUN rm -rf acestream_3.0.5.1_ubuntu_14.04_x86_64
RUN rm -rf acestream.public.key
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/man
RUN find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
RUN find /usr/share/doc -empty|xargs rmdir || true

ENTRYPOINT ["/start.sh"]
