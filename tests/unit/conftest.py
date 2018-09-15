# coding:utf-8

import boto3
import pytest


@pytest.fixture(scope='session')
def sns(request):
    return boto3.client('sns', endpoint_url='http://localhost:4575')
