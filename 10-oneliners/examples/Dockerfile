FROM alpine:latest

RUN apk add --no-cache curl jq

WORKDIR /app

RUN echo '#!/bin/sh' > /app/hello.sh && \
    echo 'echo "Hello from ttl.sh! Current time: $(date)"' >> /app/hello.sh && \
    echo 'echo "Container will expire in 1 hour"' >> /app/hello.sh && \
    chmod +x /app/hello.sh

CMD ["/app/hello.sh"]