# DARC Dark Web Crawler Setup Guide

## Overview
This guide will help you set up DARC (Darkweb Archive & Request Crawler) to crawl .onion sites on the dark web.

## Prerequisites
- Linux system (Ubuntu/Debian/Kali)
- Root/sudo access
- Internet connection

## Step 1: Install Dependencies
Install Docker and Tor on your system:

```bash
# Update system packages
sudo apt update

# Install Docker and Tor
sudo apt install -y docker.io tor

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

## Step 2: Clone DARC Repository
Get the DARC source code:

```bash
# Clone the repository
git clone https://github.com/JarryShaw/darc.git
cd darc

# Create necessary directories
mkdir -p logs logs/cron data
chmod 777 data
```

## Step 3: Configure Tor (Host-based)
Set up a minimal Tor configuration:

```bash
# Create minimal Tor config
sudo tee /tmp/bare-torrc << 'EOF'
SocksPort 9050
ExitRelay 0
EOF

# Start Tor service
sudo tor -f /tmp/bare-torrc --quiet &
```

## Step 4: Configure Seed URLs
Add the .onion sites you want to crawl:

```bash
# Add your target .onion URLs to seed files
echo "http://your-target-site.onion" > text/tor.txt
echo "http://your-target-site.onion" > text/tor2web.txt

# Create empty files for other proxy types
touch text/i2p.txt text/zeronet.txt text/freenet.txt text/clinic.txt
```

**Important:** Replace `your-target-site.onion` with actual .onion URLs you want to crawl.

## Step 5: Create Docker Compose Configuration
Create the main configuration file:

```bash
cat > docker-compose.yml << 'EOF'
version: '3'

services:
  crawler:
    image: jsnbzh/darc:latest
    container_name: crawler
    network_mode: host
    command: [ "--type", "crawler", "--file", "/app/text/tor.txt", "--file", "/app/text/tor2web.txt", "--file", "/app/text/i2p.txt", "--file", "/app/text/zeronet.txt", "--file", "/app/text/freenet.txt", "--file", "/app/text/clinic.txt" ]
    environment:
      PYTHONUNBUFFERED: 1
      DARC_SAVE: 1
      SAVE_DB: 0
      TOR_PORT: 9050
      TOR_RETRY: 0
      TOR_STEM: 0
      TOR_WAIT: 0
      TOR_PASS: ""
      PROXY_WHITE_LIST: '[ "tor" ]'
      PROXY_BLACK_LIST: '[ "null", "data" ]'
      REDIS_URL: 'redis://:UCf7y123aHgaYeGnvLRasALjFfDVHGCz6KiR5Z0WC0DL4ExvSGw5SkcOxBywc0qtZBHVrSVx2QMGewXNP6qVow@127.0.0.1'
    volumes:
      - ./text:/app/text
      - ./data:/app/data
    restart: always

  loader:
    image: jsnbzh/darc:latest
    container_name: loader
    network_mode: host
    command: [ "--type", "loader" ]
    environment:
      PYTHONUNBUFFERED: 1
      DARC_SAVE: 1
      SAVE_DB: 0
      TOR_PORT: 9050
      TOR_RETRY: 0
      TOR_STEM: 0
      TOR_WAIT: 0
      TOR_PASS: ""
      PROXY_WHITE_LIST: '[ "tor" ]'
      PROXY_BLACK_LIST: '[ "null", "data" ]'
      REDIS_URL: 'redis://:UCf7y123aHgaYeGnvLRasALjFfDVHGCz6KiR5Z0WC0DL4ExvSGw5SkcOxBywc0qtZBHVrSVx2QMGewXNP6qVow@127.0.0.1'
    volumes:
      - ./text:/app/text
      - ./data:/app/data
    restart: always

  redis:
    image: redis:alpine
    container_name: darc-redis
    network_mode: host
    command: redis-server --requirepass UCf7y123aHgaYeGnvLRasALjFfDVHGCz6KiR5Z0WC0DL4ExvSGw5SkcOxBywc0qtZBHVrSVx2QMGewXNP6qVow
    restart: always
EOF
```

## Step 6: Start DARC Services
Launch the crawler:

```bash
# Pull the Docker images
docker pull jsnbzh/darc:latest
docker pull redis:alpine

# Start all services
docker-compose up -d
```

## Step 7: Monitor and Verify
Check that everything is working:

```bash
# Check service status
docker-compose ps

# Monitor logs (Ctrl+C to exit)
docker-compose logs -f

# Check if data is being generated
ls -la data/
tail -f data/link.csv
```

## Step 8: Access Results
View crawled data and discovered links:

```bash
# List crawled files
find data/ -name "*.json" -o -name "*.html" | head -10

# View discovered links
cat data/link.csv

# Check specific crawled content
ls data/tor/http/
```

## Configuration Options

### Modifying Target Sites
- **Primary targets:** Edit `text/tor.txt`
- **Backup targets:** Edit `text/tor2web.txt`
- **Other networks:** Edit `text/i2p.txt`, `text/zeronet.txt`, etc.

### Changing Crawl Behavior
Modify environment variables in `docker-compose.yml`:
- `DARC_SAVE: 1` - Enable saving crawled content
- `SAVE_DB: 0` - Disable database storage (use files only)
- `PROXY_WHITE_LIST` - Which proxy types to use

## Troubleshooting

### Tor Connection Issues
```bash
# Test Tor connectivity
curl --socks5-hostname 127.0.0.1:9050 -s http://your-site.onion | head -5

# Restart Tor if needed
sudo pkill tor
sudo tor -f /tmp/bare-torrc --quiet &
```

### Container Issues
```bash
# Restart services
docker-compose restart

# Check container logs
docker-compose logs crawler
docker-compose logs loader
```

### Permission Issues
```bash
# Fix data directory permissions
chmod 777 data/
sudo chown -R $(whoami):$(whoami) data/
```

## Security Notes
- This tool is for research and educational purposes
- Ensure you comply with local laws and website terms of service
- Use appropriate security measures when handling dark web content
- Consider using a VPN for additional privacy

## Stopping DARC
```bash
# Stop all services
docker-compose down

# Stop Tor
sudo pkill tor
```

---
*This setup guide provides a working configuration for DARC dark web crawling. Adjust the configuration based on your specific needs and requirements.*
