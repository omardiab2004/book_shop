# Book Shop - Docker Deployment

## Requirements
- Docker Desktop
- Git

## Setup & Run Instructions

### 1. Clone the repository
git clone https://github.com/ayat93a/book_shop
cd book_shop/book-shop

### 2. Create your .env file
Copy the example file and fill in your values:
cp .env.example .env

### 3. Build and run
docker compose up --build

### 4. Run database migrations
Open a new terminal and run:
docker compose exec backend python manage.py migrate

### 5. Create a superuser (optional, for admin access)
docker compose exec backend python manage.py createsuperuser

### 6. Access the app
- Book list: http://localhost
- Admin panel: http://localhost/admin

### 7. Stop the app
docker compose down