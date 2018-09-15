# coding:utf-8

import json
import os

import pytest
from botocore.vendored import requests

from slack_notifier import SlackNotifier


class TestPublish(object):
    @pytest.mark.parametrize(
        'event', [
            ({
                 'Records': [
                     {
                         'Sns': {
                             'Message': json.dumps({
                                 'notifier_channel': 'message',
                                 'slack_username': 'v1',
                                 'slack_text': 'v2',
                                 'slack_icon_emoji': 'v3'
                             })
                         }
                     }
                 ]
             }),
            ({
                 'Records': [
                     {
                         'Sns': {
                             'Message': json.dumps({
                                 'notifier_channel': 'message',
                                 'slack_username': 'v1',
                                 'slack_text': 'v2',
                                 'slack_icon_emoji': 'v3'
                             })
                         }
                     }
                 ]
             }),
            ({
                 'Records': [
                     {
                         'Sns': {
                             'Message': json.dumps({
                                 'notifier_channel': 'message',
                                 'slack_username': 'v1',
                                 'slack_text': 'v2',
                                 'slack_icon_emoji': 'v3'
                             })
                         }
                     }
                 ]
             }),
            ({
                 'Records': [
                     {
                         'Sns': {
                             'Message': json.dumps({
                                 'notifier_channel': 'message',
                                 'slack_username': 'v1',
                                 'slack_text': 'v2',
                                 'slack_icon_emoji': 'v3'
                             })
                         }
                     }
                 ]
             })
        ])
    def test_expected_args(self, event, monkeypatch):
        monkeypatch.setattr(requests, 'post', lambda *_: None)

        os.environ['MESSAGE_HOOKS_SLACK_URL'] = 'http://example.com'

        notifier = SlackNotifier()
        notifier.publish(event)

    @pytest.mark.parametrize(
        'event', [
            ({})
        ])
    def test_unexpected_args(self, event):
        SlackNotifier().publish(event)


class TestPayload(object):
    @pytest.mark.parametrize(
        'message, expected', [
            ({
                 'slack_username': 'v1',
                 'slack_text': 'v2',
                 'slack_icon_emoji': 'v3'
             },
             {
                 'username': 'v1',
                 'text': 'v2',
                 'icon_emoji': 'v3'
             })
        ])
    def test_expected_args(self, message, expected):
        notifier = SlackNotifier()
        actual = notifier.payload(message)

        assert actual == expected


class TestParseMessage(object):
    @pytest.mark.parametrize(
        'event, expected', [
            ({
                 'Records': [
                     {
                         'Sns': {
                             'Message': json.dumps({
                                 'k1': 'v1',
                                 'k2': 'v2',
                                 'k3': 'v3'
                             })
                         }
                     }
                 ]
             },
             {
                 'k1': 'v1',
                 'k2': 'v2',
                 'k3': 'v3'
             })
        ])
    def test_expected_args(self, event, expected):
        actual = SlackNotifier().parse_message(event)

        assert actual == expected


class TestApiEndpoint(object):
    @pytest.mark.parametrize(
        'message, hooks_url, expected', [
            ({
                 'notifier_channel': 'message'
             },
             'http://example.com',
             'http://example.com'),
            ({
                 'notifier_channel': 'other'
             },
             'http://example.com',
             '')
        ])
    def test_expected_args(self, message, hooks_url, expected):
        os.environ['MESSAGE_HOOKS_SLACK_URL'] = hooks_url

        actual = SlackNotifier().api_endpoint(message)

        assert actual == expected
