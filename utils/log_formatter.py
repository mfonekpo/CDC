import json
import logging


class CustomJsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record, "%Y-%m-%dT%H:%M:%S"),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "event_id": getattr(record, "event_id", None),
            "operation": getattr(record, "operation", None),
            "function": record.funcName,
            "line": record.lineno,
            "module": record.module,
            "file": record.filename,
            "path": record.pathname
        }

        if record.levelno >= logging.WARNING:
            log_record["exception"] = record.exc_info[0].__name__ if record.exc_info else None
            log_record["exception_message"] = str(record.exc_info[1]) if record.exc_info else None
            log_record["traceback"] = self.formatException(record.exc_info) if record.exc_info else None

        return json.dumps(log_record)