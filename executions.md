> might need to create data and text directories before running the docker-compose command

# DARC Execution Guide

## 1. Clone Repository

```bash
git clone https://github.com/JarryShaw/darc.git
cd darc
```

## 2. Create Configuration Files

Create the following three YAML files:

**`docker-compose.no-auth.yml`**
```yaml
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
      TOR_CTRL: 0
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
      TOR_CTRL: 0
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
```

**`docker-compose.save.yml`**
```yaml
version: '3'

services:
  crawler:
    environment:
      DARC_SAVE: 1
      SAVE_DB: 1
      DAVE_SAVE_REQUESTS: 1
      DAVE_SAVE_SELENIUM: 1

  loader:
    environment:
      DARC_SAVE: 1
      SAVE_DB: 1
      DAVE_SAVE_REQUESTS: 1
      DAVE_SAVE_SELENIUM: 1
```

**`docker-compose.db-fix.yml`**
```yaml
version: '3'

services:
  crawler:
    environment:
      SAVE_DB: 0
      DARC_SAVE: 1

  loader:
    environment:
      SAVE_DB: 0
      DARC_SAVE: 1
```

## 3. Add Seed URL

Place the URL you want to crawl in the following file.

```bash
echo "http://your-target-site.onion" > text/tor2web.txt
```

## 4. Run Containers

Use the following command to start the DARC services.

```bash
docker-compose -f docker-compose.no-auth.yml -f docker-compose.save.yml -f docker-compose.db-fix.yml up -d
```
