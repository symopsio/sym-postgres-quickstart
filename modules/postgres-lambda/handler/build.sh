#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -u

display_usage() {
  cat <<EOM
    ##### build #####
    Package the Lambda function code and optionally deploy to your function
    without running the full Terraform pipeline.

    Note that this assumes you've packaged the function dependencies into
    a layer using layer/build.sh.

    Required arguments:

    Optional arguments:
        -e | --environment        The environment to deploy the function to.
                                  Deploy is skipped if unspecified.
        -h | --help               Show this message

    Requirements:
        aws:        AWS Command Line Interface
        pip:        To install dependencies
EOM
  exit 2
}

FUNCTION_NAME=sym-postgres
environment=''

while [[ $# -gt 0 ]]; do
  key="$1"

  case ${key} in
    -e|--environment)
      environment=$2
      shift
      ;;
    -h|--help)
      display_usage
      exit 0
      ;;
    *)
      display_usage
      exit 1
      ;;
  esac
  shift
done

if [[ -d dist ]]; then
  echo "Cleaning existing dist directory..."
  rm -rf dist
fi

echo "Creating package: dist/handler.zip..."
mkdir -p dist
zip -q -r dist/handler.zip ./*.py

if [[ -z ${environment} ]]; then
  echo "No environment specified, skipping deploy."
  exit 0
fi

echo "Deploying to environment: ${environment}"

aws lambda update-function-code \
  --function-name "${FUNCTION_NAME}-${environment}" \
  --zip-file fileb://dist/handler.zip

echo "Deploy complete!"
