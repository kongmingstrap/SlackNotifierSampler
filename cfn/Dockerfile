FROM python:3.6.3-alpine3.6

WORKDIR /workdir
RUN pip install pipenv \
      && apk add --no-cache yarn
COPY Pipfile* package.json yarn.lock ./
RUN pipenv install \
      && yarn install

ENTRYPOINT ["./deploy.sh"]
CMD ["-h"]
