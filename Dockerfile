FROM python:3.9-slim-buster

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
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
    wget \
    unzip \
    sha256sum \
    && rm -rf /var/lib/apt/lists/*

# Настройка рабочей директории
WORKDIR /app

# Копирование файлов проекта
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Загрузка и установка ChromeDriver с проверкой контрольной суммы
ARG CHROMEDRIVER_VERSION=115.0.5790.102 # Актуальная версия на 27.09.2023
RUN wget -q https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    echo "102234319b170c5928e5294bb004d9a32a66f5f2e890e72399b361882c90e5eb  chromedriver_linux64.zip" | sha256sum -c - && \ # Контрольная сумма для 115.0.5790.102
    unzip chromedriver_linux64.zip && \
    chmod +x chromedriver && \
    mv chromedriver /usr/local/bin/

# Настройка headless режима для Chrome
ENV CHROME_OPTIONS="--headless --disable-gpu --disable-extensions --disable-images --disable-popup-blocking --blink-settings=imagesEnabled=false"

# Запуск приложения
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--workers", "3"]
