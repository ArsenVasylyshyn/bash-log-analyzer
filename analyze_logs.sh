#!/bin/bash

# Создание файла с логами
cat <<EOL > access.log
192.168.1.1 - - [28/Jul/2024:12:34:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [28/Jul/2024:12:35:56 +0000] "POST /login HTTP/1.1" 200 567
192.168.1.3 - - [28/Jul/2024:12:36:56 +0000] "GET /home HTTP/1.1" 404 890
192.168.1.1 - - [28/Jul/2024:12:37:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.4 - - [28/Jul/2024:12:38:56 +0000] "GET /about HTTP/1.1" 200 432
192.168.1.2 - - [28/Jul/2024:12:39:56 +0000] "GET /index.html HTTP/1.1" 200 1234
EOL

# Подсчет общего количества запросов
total_requests=$(wc -l < access.log)

# Подсчет количества уникальных IP-адресов (строго с awk)
unique_ips=$(awk '{ips[$1]++} END {print length(ips)}' access.log)

# Подсчет количества запросов по методам (строго с awk)
methods_stats=$(awk '{if ($6 == "\"GET") get_count++; if ($6 == "\"POST") post_count++} END {print "GET:", get_count; print "POST:", post_count}' access.log)

# Нахождение самого популярного URL (строго с awk)
popular_url=$(awk '{
    split($7, url, " ");  # Разделяем URL, чтобы получить путь
    if (url[1] != "") urls[url[1]]++  # Подсчитываем количество каждого URL
}
END {
    max = 0;
    for (u in urls)  # Ищем самый популярный URL
        if (urls[u] > max) {
            max = urls[u];
            popular = u
        }
    print popular, max  # Выводим самую популярную ссылку и количество запросов
}' access.log)

# Отчет о логе веб-сервера
{
    echo "=================================="
    echo "   📁 Отчет об логах веб-сервера   "
    echo "=================================="
    echo ""
    echo "Общее количество запросов: $total_requests"
    echo "Количество уникальных IP-адресов: $unique_ips"
    echo ""
    echo "Количество запросов по методам:"
    echo "$methods_stats"
    echo ""
    # Змінено виведення для самого популярного URL
    echo "Самый популярный URL: $(echo $popular_url | awk '{print $2, $1}')"
    echo
    echo "=================================="
} > report.txt
