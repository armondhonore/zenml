FROM mirror.gcr.io/library/python:3.12-slim

# Install build dependencies for C extensions and ZenML requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc git libpq-dev libssl-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

WORKDIR /app

# Copy the full source first. 
# ZenML uses uv_build which requires the src directory to be present to build the package.
COPY . .

# Install dependencies and the package itself.
# Since uv.lock is missing, we let uv resolve. 
# We use --no-dev to keep the image slim. 
# We use --no-install-project if we want to cache deps, but ZenML requires the project to be installed.
RUN uv sync --no-dev

# Ensure the virtual environment bin is in PATH
ENV PATH="/app/.venv/bin:$PATH"
# ZenML expects the source to be discoverable; since we installed via uv sync, 
# the package is in the venv, but PYTHONPATH=/app/src helps with some legacy imports.
ENV PYTHONPATH=/app/src
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

# The server is located at zenml.server.main:app
# We use the venv's uvicorn directly.
CMD ["uvicorn", "zenml.server.main:app", "--host", "0.0.0.0", "--port", "8000", "--timeout-keep-alive", "65"]
