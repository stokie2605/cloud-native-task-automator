#!/usr/bin/env python3
"""Automated infrastructure health check utility."""

from __future__ import annotations

import json
import logging
import os
import sys
from datetime import datetime, timezone
from typing import Any

import requests
from requests import Response

DEFAULT_TARGET_URL = "https://www.githubstatus.com/api/v2/status.json"
DEFAULT_TIMEOUT_SECONDS = 5


class JsonLogFormatter(logging.Formatter):
    """Format log records as structured JSON for pipeline-friendly output."""

    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "target_url": getattr(record, "target_url", None),
        }

        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)

        return json.dumps(payload, separators=(",", ":"))


def configure_logger() -> logging.Logger:
    logger = logging.getLogger("infra_health_check")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonLogFormatter())
    logger.addHandler(handler)
    logger.propagate = False

    return logger


def get_target_url() -> str:
    return os.getenv("HEALTHCHECK_TARGET_URL", DEFAULT_TARGET_URL).strip() or DEFAULT_TARGET_URL


def poll_endpoint(target_url: str, timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS) -> Response:
    response = requests.get(target_url, timeout=timeout_seconds)
    response.raise_for_status()
    return response


def run_health_check(target_url: str, logger: logging.Logger) -> int:
    log_context = {"target_url": target_url}

    try:
        response = poll_endpoint(target_url)
    except requests.exceptions.Timeout:
        logger.critical("Connection timed out while polling endpoint", extra=log_context)
        return 1
    except requests.exceptions.HTTPError as error:
        status_code = error.response.status_code if error.response is not None else "unknown"
        logger.critical(f"Endpoint returned an unhealthy HTTP status: {status_code}", extra=log_context)
        return 1
    except requests.exceptions.RequestException as error:
        logger.critical(f"Request failed while polling endpoint: {error}", extra=log_context)
        return 1

    logger.info(f"Endpoint health check succeeded with HTTP status {response.status_code}", extra=log_context)
    return 0


def main() -> int:
    logger = configure_logger()
    target_url = get_target_url()
    return run_health_check(target_url, logger)


if __name__ == "__main__":
    sys.exit(main())
