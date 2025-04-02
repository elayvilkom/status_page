# Use a lightweight Python image
FROM python:3.11-slim-bullseye

# Set environment variables to optimize Python behavior
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt and install Python dependencies
COPY status-page/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project into the container
COPY status-page/ /app/status-page/

# Create directories for static and media files
RUN mkdir -p /app/status-page/statuspage/static /app/status-page/statuspage/media

# Optional: Generate secret key if script exists
RUN if [ -f status-page/statuspage/generate_secret_key.py ]; then \
        python status-page/statuspage/generate_secret_key.py > status-page/statuspage/secretkey.py; \
    fi

# Collect static files
RUN python status-page/statuspage/manage.py collectstatic --noinput || echo "Static collection skipped"

# Expose the port that Gunicorn will use
EXPOSE 8000

# Start the Django application with Gunicorn
CMD ["gunicorn", "--chdir", "status-page", "--bind", "0.0.0.0:8000", "statuspage.wsgi:application"]
