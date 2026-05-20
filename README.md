# Book Shop - Docker + CI/CD Deployment

## Group Info
- Group size: 1
- Name: Omar Dyab

---

## Phase 1 - Docker Setup

### Whats needed
- Docker Desktop
- Git installed on your machine

### How to run it

First clone the repo:
git clone https://github.com/omardiab2004/book_shop
cd book_shop/book-shop

Then make your .env file by copying the example:
cp .env.example .env

Fill in the values in .env then build and run:
docker compose up --build

After that run the migrataions:
docker compose exec backend python manage.py migrate

Thats it, open your browser and go to http://localhost to see the app
For the admin pannel go to http://localhost/admin

To stop everything:
docker compose down

---

## Phase 2 - CI/CD Piplines

### Group size choice
Since this is a group of 1 (treated as group of 2), i used Docker Hub as the registery and run docker compose commands directly on EC2. No automation of the compose file was needed.

### Branch Stratgy

There are 3 branches each with a diffrent deployment approch:

| Branch | Philosophy | What it does |
|--------|-----------|--------------|
| dev | Artifact-first | builds image from a saved artfact |
| test | Image-first | rebuilds fresh and pushes to Docker Hub |
| prod | Promotion only | just pulls existing image, no building |

### How each pipline works

#### Dev branch
Every push to dev triggers this pipline. It installs dependancies and collects static files, then packages everything into a tar.gz artifact named with the commit sha so every build has its own unique file. The artifact gets commited to the artifacts/ folder as an audit trail. Then it builds the docker image FROM that artifact (not from source code directly) and pushes it to Docker Hub. Finally it deploys to EC2 on port 8001.

#### Test branch
Every push to test triggers this pipline. It does NOT reuse the artifact from dev, instead it rebuilds everything fresh from source. This proves the build proccess is reliabel and reproducable. It pushes the image to Docker Hub and deploys to EC2 on port 8002.

#### Prod branch
Every push to prod triggers this pipline. It does absolutly no building at all. It reads the IMAGE_VERSION variable from github repo settings and pulls that exact image from Docker Hub. Then deploys to EC2 on port 80. This garantees that only tested images reach production.

### How 3 deployments coexist on one EC2

Each environment runs completly isolated:

| Environment | Port | Network |
|-------------|------|---------|
| dev | 8001 | dev_network |
| test | 8002 | test_network |
| prod | 80 | prod_network |

Each one has its own docker-compose file in ~/deployments/<env>/, its own database volume and its own network so they dont interfere with eachother at all.

### Secrets and Variables used

Secrets (sensitive stuff):
- EC2_SSH_KEY - the private key to ssh into ec2
- DOCKERHUB_USERNAME - docker hub username
- DOCKERHUB_TOKEN - docker hub access token
- SECRET_KEY - django secret key
- POSTGRES_PASSWORD - database password

Variables (non sensitive config):
- IMAGE_VERSION - the version to deploy to prod
- EC2_HOST - the ec2 ip adress
- REGISTRY_NAME - the docker hub repo name