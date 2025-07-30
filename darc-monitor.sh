#!/bin/bash

echo "=== DARC Monitoring Dashboard ==="
echo "Date: $(date)"
echo ""

echo "1. Container Status:"
docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.save.yml ps
echo ""

echo "2. Recent Logs (last 10 lines per service):"
echo "--- Crawler ---"
docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.save.yml logs --tail=5 crawler | tail -5
echo ""
echo "--- Loader ---" 
docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.save.yml logs --tail=5 loader | tail -5
echo ""

echo "3. Redis Queue Status:"
docker exec darc-redis redis-cli -a UCf7y123aHgaYeGnvLRasALjFfDVHGCz6KiR5Z0WC0DL4ExvSGw5SkcOxBywc0qtZBHVrSVx2QMGewXNP6qVow zcard queue_requests 2>/dev/null | sed 's/^/URLs in queue: /'
echo ""

echo "4. Data Files:"
find data/ -type f -name "*" 2>/dev/null | wc -l | sed 's/^/Files created: /'
if [ $(find data/ -type f -name "*" 2>/dev/null | wc -l) -gt 0 ]; then
    echo "Recent files:"
    find data/ -type f -name "*" 2>/dev/null | head -5
fi
echo ""

echo "5. Log Files:"
find logs/ -type f -name "*" 2>/dev/null | wc -l | sed 's/^/Log files: /'
echo ""
