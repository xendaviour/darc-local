#!/bin/bash

COMPOSE_FILES="-f docker-compose.yml -f docker-compose.override.yml -f docker-compose.save.yml"

case "$1" in
    start)
        echo "Starting DARC..."
        docker-compose $COMPOSE_FILES up -d
        ;;
    stop)
        echo "Stopping DARC..."
        docker-compose $COMPOSE_FILES down
        ;;
    restart)
        echo "Restarting DARC..."
        docker-compose $COMPOSE_FILES down
        docker-compose $COMPOSE_FILES up -d
        ;;
    status)
        ./darc-monitor.sh
        ;;
    logs)
        echo "Recent logs:"
        docker-compose $COMPOSE_FILES logs --tail=20
        ;;
    data)
        echo "=== Data Directory Contents ==="
        find data/ -type f -name "*" 2>/dev/null | head -20
        if [ $(find data/ -type f -name "*" 2>/dev/null | wc -l) -gt 0 ]; then
            echo ""
            echo "=== Sample Data Files ==="
            find data/ -name "*.html" -o -name "*.json" 2>/dev/null | head -3 | while read file; do
                echo "--- $file ---"
                head -5 "$file" 2>/dev/null
                echo ""
            done
        fi
        ;;
    redis)
        echo "=== Redis Data ==="
        docker exec darc-redis redis-cli -a UCf7y123aHgaYeGnvLRasALjFfDVHGCz6KiR5Z0WC0DL4ExvSGw5SkcOxBywc0qtZBHVrSVx2QMGewXNP6qVow keys "*" 2>/dev/null
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|data|redis}"
        echo ""
        echo "Commands:"
        echo "  start   - Start DARC services"
        echo "  stop    - Stop DARC services"
        echo "  restart - Restart DARC services"
        echo "  status  - Show current status"
        echo "  logs    - Show recent logs"  
        echo "  data    - Show crawled data files"
        echo "  redis   - Show Redis keys"
        ;;
esac
