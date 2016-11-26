
# Version: 0.0.3

# Используем за основу контейнера phusion/baseimage
FROM phusion/baseimage:0.9.19

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
RUN cd /tmp
RUN apt-get update
RUN add-apt-repository ppa:videolan/stable-daily
RUN apt-get update
RUN apt-get install -y wget mc nano
RUN wget http://cloud.sybdata.com/AceStream/libgnutls-deb0-28_3.3.15-5ubuntu2_amd64.deb 
RUN wget http://cloud.sybdata.com/AceStream/acestream-engine_3.0.5.1-0.2_amd64.deb
RUN apt-get install gdebi
RUN gdebi libgnutls-deb0-28_3.3.15-5ubuntu2_amd64.deb
RUN gdebi acestream-engine_3.0.5.1-0.2_amd64.deb 
RUN apt-get install -y vlc-nox python-gevent unzip ca-certificates supervisor python-setuptools python-pip python-dev build-essential
RUN pip install greenlet gevent psutil 
RUN systemctl enable supervisor 
RUN systemctl start supervisor 

# Добавляем пользователя "tv" 
RUN adduser --disabled-password --gecos "" tv 

RUN git clone https://github.com/AndreyPavlenko/aceproxy.git 
RUN mv ./aceproxy /home/tv/aceproxy-master 

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
ADD start.sh /start.sh 
RUN chmod +x /start.sh

# Подчищаем
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian /usr/share/linda /var/cache/man
RUN find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
RUN find /usr/share/doc -empty|xargs rmdir || true

ENTRYPOINT ["/start.sh"]
