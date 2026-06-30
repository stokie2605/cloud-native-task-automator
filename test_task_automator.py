import logging
import os
from unittest.mock import MagicMock, patch
import pytest
import requests

from task_automator import (
    JsonLogFormatter,
    get_target_url,
    poll_endpoint,
    run_health_check,
)

def test_get_target_url_default():
    with patch.dict(os.environ, {}, clear=True):
        assert get_target_url() == "https://www.githubstatus.com/api/v2/status.json"

def test_get_target_url_env():
    with patch.dict(os.environ, {"HEALTHCHECK_TARGET_URL": "https://example.com"}):
        assert get_target_url() == "https://example.com"

@patch("task_automator.requests.get")
def test_poll_endpoint_success(mock_get):
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_get.return_value = mock_response

    response = poll_endpoint("https://example.com")
    assert response.status_code == 200
    mock_get.assert_called_once_with("https://example.com", timeout=5)

@patch("task_automator.requests.get")
def test_poll_endpoint_http_error(mock_get):
    mock_response = MagicMock()
    mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError("Unhealthy")
    mock_get.return_value = mock_response

    with pytest.raises(requests.exceptions.HTTPError):
        poll_endpoint("https://example.com")

def test_json_log_formatter():
    formatter = JsonLogFormatter()
    record = logging.LogRecord(
        name="test",
        level=logging.INFO,
        pathname="test.py",
        lineno=10,
        msg="Infrastructure OK",
        args=None,
        exc_info=None
    )
    record.target_url = "https://example.com"
    formatted = formatter.format(record)
    
    import json
    parsed = json.loads(formatted)
    assert parsed["level"] == "INFO"
    assert parsed["message"] == "Infrastructure OK"
    assert parsed["target_url"] == "https://example.com"
    assert "timestamp" in parsed

@patch("task_automator.poll_endpoint")
def test_run_health_check_success(mock_poll):
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_poll.return_value = mock_response

    logger = MagicMock()
    result = run_health_check("https://example.com", logger)
    assert result == 0
    logger.info.assert_called_once()

@patch("task_automator.poll_endpoint")
def test_run_health_check_timeout(mock_poll):
    mock_poll.side_effect = requests.exceptions.Timeout("Connection timeout")

    logger = MagicMock()
    result = run_health_check("https://example.com", logger)
    assert result == 1
    logger.critical.assert_called_once()
