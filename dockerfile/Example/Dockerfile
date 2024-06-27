# Docker builds images using a layered filesystem. 
# Each instruction creates a new layer.
# Layers are cached and reused so images build faster and saves space.

# FROM sets the base image for subsequent instructions. 
FROM python:3.11-slim

# WORKDIR sets the working directory in the container
WORKDIR /app

# COPY from local folder to docker filesystem.
COPY requirements.txt .

# RUN executes commands in a new layer 
RUN pip install --no-cache-dir -r requirements.txt

# Another COPY instruction, adding more files to the image.
COPY src/*.py .

# ENTRYPOINT sets the base command 
ENTRYPOINT ["python"]

#CMD provides default arguments 
CMD ["main.py"]

