FROM python:3.12-slim-bookworm AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update \
    && apt-get upgrade --yes \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && /opt/venv/bin/pip uninstall --yes pip setuptools wheel \
    && find /opt/venv -type d -name "__pycache__" -prune -exec rm -rf {} +

FROM python:3.12-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --no-install-recommends --yes ca-certificates \
    && python -m pip uninstall --yes pip setuptools wheel \
    && rm -rf /root/.cache/pip /var/lib/apt/lists/* \
    && groupadd --system appuser \
    && useradd --system --gid appuser --home-dir /app --shell /usr/sbin/nologin appuser

COPY --from=builder /opt/venv /opt/venv
COPY task_automator.py requirements.txt ./

USER appuser

ENTRYPOINT ["python", "task_automator.py"]
