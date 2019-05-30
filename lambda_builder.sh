#!/bin/bash
set -ev

cd backend

virtualenv --python=${PYTHON_VERSION} .venv
source .venv/bin/activate
pip install -r requirements.txt

cd .venv/lib/${PYTHON_VERSION}/site-packages/
zip -r9 ../../../../function.zip .
cd ../../../../
zip -g function.zip ${LAMBDA_MAIN}
