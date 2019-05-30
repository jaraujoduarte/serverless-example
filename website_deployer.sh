#!/bin/bash
set -ev

aws s3 sync ./webapp/ s3://serverless-example.pythonbaq.org/
