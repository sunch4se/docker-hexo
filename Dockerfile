FROM arm64v8/node:slim

MAINTAINER Benjamin Huss <b.huss@gmx.de>

COPY --from=resin/aarch64-alpine:latest ["/usr/bin/qemu*", "/usr/bin/resin-xbuild*", "/usr/bin/cross-build*",  "/usr/bin/"]
RUN [ "cross-build-start" ]

# Set the server port as an environmental
ENV HEXO_SERVER_PORT=4000

# Install requirements
RUN \
 apt-get update && \
 apt-get install git -y && \
 npm install -g hexo-cli

# Set workdir
WORKDIR /app

# Expose Server Port
EXPOSE ${HEXO_SERVER_PORT}

# Build a base server and configuration if it doesnt exist, then start
CMD \
  if [ "$(ls -A /app)" ]; then \
    echo "***** App directory exists and has content, continuing *****"; \
  else \
    echo "***** App directory is empty, initialising with hexo and hexo-admin *****" && \
    hexo init && \
    npm install && \
    npm install --save hexo-admin; \
  fi; \
  if [ ! -f /app/requirements.txt ]; then \
    echo "***** App directory contains no requirements.txt file, continuing *****"; \
  else \
    echo "***** App directory contains a requirements.txt file, installing npm requirements *****"; \
    cat /app/requirements.txt | xargs npm --prefer-offline install --save; \
  fi; \
  echo "***** Starting server on port ${HEXO_SERVER_PORT} *****" && \
  hexo server -d -p ${HEXO_SERVER_PORT}

  RUN [ "cross-build-end" ]