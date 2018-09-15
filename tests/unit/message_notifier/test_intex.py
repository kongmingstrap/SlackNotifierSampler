import index
from slack_notifier import SlackNotifier


class TestHandler(object):
    def test_expected_args(self, monkeypatch):
        monkeypatch.setattr(SlackNotifier, 'publish', lambda *_: None)
        index.handler(None, None)
