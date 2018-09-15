SHELL = /usr/bin/env bash -xeuo pipefail

localstack-up:
	@docker-compose up -d localstack

localstack-stop:
	@docker-compose stop localstack

lint:
	@python -m flake8 \
		tests \
		src \
		src/common \

unit-test:
	@for test_dir in $$(find tests/unit -maxdepth 1 -type d); do \
		handler=$$(basename $$test_dir); \
		if [[ $$handler =~ unit|__pycache__|fixtures ]]; then continue; fi; \
		AWS_DEFAULT_REGION=ap-northeast-1 \
		AWS_ACCESS_KEY_ID=dummy \
		AWS_SECRET_ACCESS_KEY=dummy \
		PYTHONPATH=src/handlers/$$handler \
			python -m pytest tests/unit/$$handler --cov-config=./setup.cfg --cov=src/handlers/$$handler; \
	done

e2e-test:
	true

validate:
	@aws cloudformation validate-template \
		--template-body file://sam.yml

clean:
	@find src/** -type d \( -name '__pycache__' -o -name '*\.dist-info' -o -name '*\.egg-info' \) -print0 | xargs -0 -n1 rm -rf
	@find src/** -type f \( -name '.coverage' -o -name '*.pyc' \) -print0 | xargs -0 -n1 rm -rf

copy:
	@for common in $$(find src/handlers -type l \( -name 'logger' \)); do \
	 rm -rf $$common; \
	 cp -pvr src/common/$$(basename $$common) $$common; \
	done

build:
	@for handler in $$(find src/handlers -maxdepth 2 -type f -name 'Pipfile'); do \
		handler_dir=$$(dirname $$handler); \
		pwd_dir=$$PWD; \
		docker_name=sns-api-$$(basename $$handler_dir); \
		cd $$handler_dir; \
		docker image build --tag $$docker_name .; \
		docker container run -it --name $$docker_name $$docker_name; \
		docker container cp $$docker_name:/workdir/vendored .; \
		docker container rm $$docker_name; \
		cd $$pwd_dir; \
	done

deploy: copy clean
	@aws cloudformation package \
		--template-file sam.yml \
		--s3-bucket sns-awssam-artifacts-$(AWS_ACCOUNT_ID)-$(AWS_DEFAULT_REGION)-$(AWS_ENV) \
		--output-template-file template.yml
	@aws cloudformation deploy \
		--template-file template.yml \
		--stack-name sns-api-$(AWS_ENV) \
		--parameter-overrides $$(cat params/$(AWS_ENV).ini | grep -vE '^#' | tr '\n' ' ' | awk '{print}') \
		--role-arn arn:aws:iam::$(AWS_ACCOUNT_ID):role/sns-iam-$(AWS_ENV)/sam-deploy-role-$(AWS_ENV) \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset

.PHONY: \
	localstack-up \
	localstack-down \
	lint \
	unit-test \
	e2e-test \
	validate \
	clean \
	copy \
	build \
	deploy
