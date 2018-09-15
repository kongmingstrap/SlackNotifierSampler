import json
import os
import traceback

from botocore.vendored import requests

from logger.logger import Logger

logger = Logger().getLogger(__name__)


class SlackNotifier(object):
    def publish(self, event):
        logger.info('Start')

        try:
            message = self.parse_message(event)
            api_endpoint = self.api_endpoint(message)
            headers = {
                'Content-Type': 'application/json; charset=utf-8'
            }
            payload = self.payload(message)
            requests.post(api_endpoint, data=json.dumps(payload), headers=headers)
        except Exception as e:
            logger.error(f'{e}')
            logger.error(traceback.format_exc())
        else:
            logger.info('Finished')

    def payload(self, message):
        username = message['slack_username']
        text = message['slack_text']
        icon_emoji = message['slack_icon_emoji']

        return {
            'username': username,
            'text': text,
            'icon_emoji': icon_emoji
        }

    def parse_message(self, event):
        event_source = event['Records'][0]
        message = json.loads(event_source['Sns']['Message'])

        return message

    def api_endpoint(self, message):
        channel = message['notifier_channel']
        if channel == 'message':
            return os.environ['MESSAGE_HOOKS_SLACK_URL']
        else:
            return ''
