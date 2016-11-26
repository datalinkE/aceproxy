
# Version: 0.0.2

# Используем за основу контейнера phusion/baseimage
FROM phusion/baseimage:0.9.19

# Переключаем Ubuntu в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive

#Задаём порты
EXPOSE 22 8000 8621 62062 9944 9903

#Прбрасываем папку с конфигами aceproxy
VOLUME /etc/aceproxy

# Устанавливаем локаль
RUN RUN locale-gen ru_RU.UTF-8 && \

usermod -u 99 nobody && \
usermod -g 100 nobody && \

# Добавляем необходимые репозитарии и устанавливаем пакеты
cd /tmp && \
apt-get update && apt-get install -y wget mc nano && \
wget http://cloud.sybdata.com/AceStream/libgnutls-deb0-28_3.3.15-5ubuntu2_amd64.deb && \
wget http://cloud.sybdata.com/AceStream/acestream-engine_3.0.5.1-0.2_amd64.deb && \
apt-get install gdebi && \
gdebi libgnutls-deb0-28_3.3.15-5ubuntu2_amd64.deb && \
gdebi acestream-engine_3.0.5.1-0.2_amd64.deb && \
add-apt-repository ppa:videolan/stable-daily && \
apt-get update && \
apt-get install -y vlc-nox python-gevent unzip ca-certificates supervisor python-setuptools python-pip python-dev build-essential && \
pip install greenlet gevent psutil && \
systemctl enable supervisor && \
systemctl start supervisor && \

# Добавляем пользователя "tv" 
adduser --disabled-password --gecos "" tv && \

git clone https://github.com/AndreyPavlenko/aceproxy.git && \
mv ./aceproxy /home/tv/aceproxy-master && \

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
ADD start.sh /start.sh && \
chmod +x /start.sh

# Подчищаем
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))

ENTRYPOINT ["/start.sh"]
