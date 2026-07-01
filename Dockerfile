FROM mirror.gcr.io/library/python:3.12-slim

# Install build dependencies for C extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc git libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

WORKDIR /app

# Copy the full source first because uv_build (the build backend) 
# requires the actual source code (src/zenml) to be present during the 
# sync/install process to build the package in editable mode.
COPY . .

# Install dependencies and the package itself.
# Since uv.lock is missing, we let uv resolve and install.
# We use --no-dev to keep the image slim.
RUN uv sync --no-dev

# Ensure the virtual environment bin is in PATH
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH=/app/src
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

# Use the venv's uvicorn to run the ZenML server
CMD ["uvicorn", "zenml.server.main:app", "--host", "0.0.0.0", "--port", "8000"]
