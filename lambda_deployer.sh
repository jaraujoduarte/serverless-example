#!/bin/bash
set -ev

cd backend

virtualenv --python=${PYTHON_VERSION} .venv
source .venv/bin/activate
pip install -r requirements.txt

cd .venv/lib/${PYTHON_VERSION}/site-packages/
zip -r9 ../../../../${LAMBDA_MAIN}.zip .
cd ../../../../
zip -g ${LAMBDA_MAIN}.zip ${LAMBDA_MAIN}.py

cd deploy
terraform apply -auto-approve -target=aws_lambda_function.${LAMBDA_MAIN}_lambda
