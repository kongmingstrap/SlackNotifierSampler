import json
import logging


class JsonLogFormatter(logging.Formatter):
    def format(self, record):
        ret = {}

        for attr, value in record.__dict__.items():
            if attr == 'asctime':
                value = self.formatTime(record)
            if attr == 'exc_info' and value is not None:
                value = self.formatException(value)
            if attr == 'stack_info' and value is not None:
                value = self.formatStack(value)

            ret[attr] = value

        return json.dumps(ret)
