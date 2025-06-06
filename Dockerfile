# Dockerfile
# syntax=docker/dockerfile:1.4

# Use the official Python image with the desired version
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install yes command first
RUN apt-get update && apt-get install -y --no-install-recommends yes && \
    rm -rf /var/lib/apt/lists/*

# Configure guardrails using the secret
RUN --mount=type=secret,id=GUARDRAILS_TOKEN \
    export GUARDRAILS_TOKEN=$(cat /run/secrets/GUARDRAILS_TOKEN) && \
    yes n | guardrails configure --token $GUARDRAILS_TOKEN && \
    guardrails hub install hub://guardrails/toxic_language --quiet

# Copy the rest of the application code to the working directory
COPY app.py /app
COPY chunking/ /app/chunking/
COPY pyproject.toml /app/

# Expose the port that Gradio will run on (default is 7860)
EXPOSE 7860

ENV GRADIO_SERVER_NAME="0.0.0.0"

# Command to run your application
CMD ["python", "app.py"]
