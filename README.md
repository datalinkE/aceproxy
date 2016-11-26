# AceProxy: Ace Stream HTTP Proxy

HTTP-прокси для Ace Stream. Позволяет смотреть трансляции Ace Stream и обычные видеофайлы с торрентов на любых устройствах, поддерживающих HTTP-видео (Smart TV, Android, STB). Имеется система плагинов, на данный момент, есть плагины для плейлистов Torrent-TV.ru, Torrent-telik.com, Allfon.tv.

#Задаём порты
EXPOSE 22 8000 8621 62062 9944 9903

#Пробрасываем папку с конфигами aceproxy
VOLUME /etc/aceproxy
