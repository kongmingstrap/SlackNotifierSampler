from slack_notifier import SlackNotifier


def handler(event, context):
    SlackNotifier().publish(event)
