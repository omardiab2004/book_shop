FROM python:3.11-slim

WORKDIR /app

COPY artifacts/app-*.tar.gz /tmp/app.tar.gz

RUN tar -xzf /tmp/app.tar.gz -C /app && \
    rm /tmp/app.tar.gz

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["gunicorn", "book_shop.wsgi:application", "--bind", "0.0.0.0:8000"]