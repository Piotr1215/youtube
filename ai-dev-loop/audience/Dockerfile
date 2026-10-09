# The audience page and its bounded API, with classif pinned to a commit. In the
# cluster CLASSIF_HOSTS points it at the model Service instead of ../ask.
FROM python:3.13-alpine
RUN apk add --no-cache git \
	&& git clone -q https://github.com/Piotr1215/classif.git /opt/classif \
	&& git -C /opt/classif checkout -q 2a48dde \
	&& ln -s /opt/classif/classif /usr/local/bin/classif \
	&& apk del git
WORKDIR /app
COPY server.py index.html ./
ENV AUDIENCE_BIND=0.0.0.0 HOME=/tmp CLASSIF_LOG=/tmp/classif.jsonl
USER 65534
EXPOSE 8089
CMD ["python3", "-I", "server.py", "8089"]
