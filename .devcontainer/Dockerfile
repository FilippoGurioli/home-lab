FROM python:3.11-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
  openssh-client \
  git \
  sshpass \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
  ansible \
  ansible-lint

WORKDIR /workspace
