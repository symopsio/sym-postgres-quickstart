#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -u

display_usage() {
  cat <<EOM
    ##### build-layer #####
    Build the function dependencies into a layer.

    The psycopg2 module has native dependencies, so we need to
    ensure we build and pacakge a version that is compatible with
    the lambda runtime.

    Optional arguments:
        -h | --help             Show this message

    Requirements:
        docker:        To install layer dependencies
EOM
  exit 2
}

while [[ $# -gt 0 ]]; do
  key="$1"

  case ${key} in
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

mkdir -p build
sed 's/psycopg2/psycopg2-binary/g' ../handler/requirements.txt > build/requirements.txt

echo "Installing dependencies..."
rm -rf dist
docker build -t postgres-lambda-layer .
CONTAINER=$(docker run -d postgres-lambda-layer false)
docker cp "$CONTAINER":/opt dist
docker rm "$CONTAINER"

pushd dist || exit 1

  zip -q -r ./layer.zip .

popd || exit 1

echo "Build complete!"
