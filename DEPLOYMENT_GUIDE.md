# Vikunja Deployment Guide

This guide explains how to export and run your customized Vikunja project on any machine.

## Method 1: Docker Compose (Recommended)

### Prerequisites
- Docker installed on the target machine
- Docker Compose (either standalone `docker-compose` or plugin `docker compose`)
- Git (optional, for cloning)

**Note:** Newer Docker installations include Docker Compose as a plugin (`docker compose`), while older installations use the standalone version (`docker-compose`). The deployment script automatically detects which version you have.

### Steps to Deploy:

1. **Copy the entire project folder** to the target machine, or clone from your repository:
   ```bash
   # If using git
   git clone <your-repository-url>
   cd vikunja
   
   # Or copy the entire project folder
   scp -r /path/to/vikunja user@target-machine:/path/to/destination
   ```

2. **Run the application**:
   ```bash
   docker-compose up --build -d
   ```

3. **Access the application**:
   - Frontend: http://localhost:8081
   - API: http://localhost:3456

4. **Stop the application**:
   ```bash
   docker-compose down
   ```

### What gets deployed:
- PostgreSQL database (data persisted in `./db` folder)
- Backend API server
- Frontend with your custom army.svg branding
- All services automatically configured and networked

## Method 2: Docker Images (For Production)

### Build and Push Images:

1. **Build the images**:
   ```bash
   # Build frontend image
   docker build -f Dockerfile.frontend -t your-registry/vikunja-frontend:latest .
   
   # Build backend image  
   docker build -f Dockerfile.backend -t your-registry/vikunja-backend:latest .
   ```

2. **Push to registry** (Docker Hub, AWS ECR, etc.):
   ```bash
   docker push your-registry/vikunja-frontend:latest
   docker push your-registry/vikunja-backend:latest
   ```

3. **Create production docker-compose.yml** on target machine:
   ```yaml
   services:
     db:
       image: postgres:15
       restart: unless-stopped
       environment:
         POSTGRES_USER: vikunja
         POSTGRES_PASSWORD: vikunja
         POSTGRES_DB: vikunja
       volumes:
         - vikunja_db:/var/lib/postgresql/data

     api:
       image: your-registry/vikunja-backend:latest
       restart: unless-stopped
       depends_on:
         - db
       environment:
         VIKUNJA_DATABASE_TYPE: postgres
         VIKUNJA_DATABASE_HOST: db
         VIKUNJA_DATABASE_USER: vikunja
         VIKUNJA_DATABASE_PASSWORD: vikunja
         VIKUNJA_DATABASE_DATABASE: vikunja
         VIKUNJA_SERVICE_PUBLICURL: http://your-domain.com:3456
       ports:
         - "3456:3456"

     frontend:
       image: your-registry/vikunja-frontend:latest
       restart: unless-stopped
       ports:
         - "8081:80"
       depends_on:
         - api

   volumes:
     vikunja_db:
   ```

## Method 3: Manual Build (Without Docker)

### Prerequisites on target machine:
- Node.js 20+ and pnpm
- Go 1.23+
- PostgreSQL

### Steps:

1. **Copy project files** to target machine

2. **Build frontend**:
   ```bash
   cd frontend
   pnpm install
   pnpm run build
   ```

3. **Build backend**:
   ```bash
   go mod download
   go build -o vikunja .
   ```

4. **Setup database** and configure environment variables

5. **Run the application**:
   ```bash
   ./vikunja
   ```

## Method 4: Export as Archive

### Create deployment package:

1. **Create a deployment archive**:
   ```bash
   # Exclude unnecessary files
   tar -czf vikunja-deployment.tar.gz \
     --exclude=node_modules \
     --exclude=.git \
     --exclude=db \
     --exclude=frontend/dist \
     .
   ```

2. **Transfer to target machine**:
   ```bash
   scp vikunja-deployment.tar.gz user@target-machine:/path/to/destination
   ```

3. **Extract and run**:
   ```bash
   tar -xzf vikunja-deployment.tar.gz
   cd vikunja
   docker-compose up --build -d
   ```

## Environment Configuration

### Important files to customize for different environments:

1. **docker-compose.yml** - Update ports, database credentials, public URLs
2. **frontend/index.html** - Update API_URL if needed
3. **Environment variables** - Set production values for:
   - `VIKUNJA_SERVICE_PUBLICURL`
   - Database credentials
   - SSL/TLS settings

### Production Considerations:

1. **Security**:
   - Change default database passwords
   - Use environment files for secrets
   - Enable HTTPS/SSL
   - Configure firewall rules

2. **Performance**:
   - Use production database settings
   - Configure reverse proxy (nginx/traefik)
   - Set up monitoring and logging

3. **Backup**:
   - Regular database backups
   - Backup uploaded files
   - Version control your configurations

## Quick Start Commands

### For new machine setup:
```bash
# 1. Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Copy your project
scp -r vikunja/ user@new-machine:/home/user/

# 3. Run on new machine
cd vikunja
docker-compose up --build -d
```

### Health Check:
```bash
# Check if services are running
docker-compose ps

# View logs
docker-compose logs -f

# Check frontend
curl http://localhost:8081

# Check API
curl http://localhost:3456/api/v1/info
```

Your customized Vikunja with army.svg branding will be fully functional on any machine following these methods!
