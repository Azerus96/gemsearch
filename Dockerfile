FROM python:3.9-slim-buster

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    chromium-chromedriver \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    ca-certificates \
    fonts-noto-color-emoji \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Настройка рабочей директории
WORKDIR /app

# Копирование файлов проекта
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Настройка headless режима для Chrome
ENV CHROME_OPTIONS="--headless --disable-gpu --disable-extensions --disable-images --disable-popup-blocking --blink-settings=imagesEnabled=false"

# Запуск приложения
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--workers", "3"]
