import json
import logging.config
import os


class Logger(object):
    def getLogger(self, name):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        config_file_path = os.path.join(current_dir, 'logging.json')
        logging.config.dictConfig(json.load(open(config_file_path)))
        return logging.getLogger(name)
