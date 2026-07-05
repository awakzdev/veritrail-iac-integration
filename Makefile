.PHONY: scan fmt plan-dev plan-staging plan-prod

scan:
	python3 scripts/verify_no_paid_resources.py

fmt:
	terraform fmt -recursive

plan-dev:
	cd live/dev && terragrunt run-all plan

plan-staging:
	cd live/staging && terragrunt run-all plan

plan-prod:
	cd live/prod && terragrunt run-all plan
