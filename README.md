# Book Shop - Docker + CI/CD Deployment

## Group Size: 2 students

## Phase 1 - Docker Setup

### Requirements
- Docker Desktop
- Git

### Setup & Run Instructions

#### 1. Clone the repository
git clone https://github.com/omardiab2004/book_shop
cd book_shop/book-shop

#### 2. Create your .env file
cp .env.example .env

#### 3. Build and run
docker compose up --build

#### 4. Run database migrations
docker compose exec backend python manage.py migrate

#### 5. Access the app
- Book list: http://localhost
- Admin panel: http://localhost/admin

#### 6. Stop the app
docker compose down

---

## Phase 2 - CI/CD Pipelines

### Branch Strategy

This project uses three branches, each with a different deployment philosophy:

| Branch | Philosophy | What Ships |
|--------|-----------|------------|
| dev | Artifact-first | Image built from a saved artifact |
| test | Image-first | Fresh image pushed to Docker Hub |
| prod | Promotion only | Pulls existing image from Docker Hub |

### How Each Pipeline Works

#### Dev Pipeline (dev branch)
- Triggered on every push to dev
- Installs dependencies and collects static files
- Packages the source code into a tar.gz artifact named app-<commit-sha>.tar.gz
- Commits the artifact to the artifacts/ folder on the dev branch
- Builds a Docker image FROM the artifact (not from source)
- Pushes image to Docker Hub tagged as dev-<sha> and dev-latest
- Deploys to EC2 on port 8001

#### Test Pipeline (test branch)
- Triggered on every push to test
- Rebuilds fresh from source (does NOT reuse dev artifact)
- Builds a Docker image from the freshly built artifact
- Pushes image to Docker Hub tagged as test-<sha> and test-latest
- Deploys to EC2 on port 8002

#### Prod Pipeline (prod branch)
- Triggered on every push to prod
- Does NOT build or package anything
- Reads IMAGE_VERSION from GitHub Actions repository variable
- Pulls that exact image from Docker Hub
- Deploys to EC2 on port 80

### How Three Deployments Coexist on One EC2

Each environment runs in its own isolated setup:

| Environment | Port | Compose Project | Network |
|-------------|------|----------------|---------|
| dev | 8001 | dev | dev_network |
| test | 8002 | test | test_network |
| prod | 80 | prod | prod_network |

Each environment has its own:
- docker-compose.yml in ~/deployments/<env>/
- PostgreSQL volume
- Static files volume
- Bridge network

This prevents any conflicts between the three deployments.

### GitHub Actions Secrets & Variables

#### Secrets
- EC2_SSH_KEY - Private key for SSH to EC2
- DOCKERHUB_USERNAME - Docker Hub username
- DOCKERHUB_TOKEN - Docker Hub access token
- SECRET_KEY - Django secret key
- POSTGRES_PASSWORD - PostgreSQL password

#### Variables
- IMAGE_VERSION - Version tag to deploy to prod
- EC2_HOST - EC2 instance public IP
- REGISTRY_NAME - Docker Hub repository name

### Registry
Group of 2: Docker Hub (omardiab04/book-shop)

### EC2 Deployment
Group of 2: docker-compose commands run directly on EC2.
The compose files live on the server at ~/deployments/<env>/.