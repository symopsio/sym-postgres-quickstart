# postgres-lambda

## Building

You'll need to build the lambda layer and handler zips so that Terraform can complete provisioning.

### Build the layer

Our handler uses the [`psycopg2`](https://pypi.org/project/psycopg2/) module to connect to Postgres, which requires packaging some native dependencies. To package the layer, run:

```bash
$ cd layer
$ ./build.sh
```

### Build the handler

The layer builds and packages all the handler dependencies. The handler build just includes your local python code.

```bash
$ cd handler
$ ./build.sh
```

## Deploying

### Password Configuration

Once you run a `terraform apply`, you need to configure the database password that the handler should use to connect to the database. The handler looks up your database password in an [AWS Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) Parameter. The Parameter is named based on your Lambda function name, like `/symops.com/FUNCTION_NAME/PG_PASSWORD`. You can set the value from the console or from the command line:

```bash
$ aws ssm put-parameter \
  --name /symops.com/FUNCTION_NAME/PG_PASSWORD \
  --value "${PG_PASSWORD}" \
  --type SecureString \
  --overwrite
```

If you're using the `example-db` module to test, you can get the database connection info using the `terraform output` command, see the [`README`](../example-db/README.md) for more details.

### Updating the Implementation

Once you've run your Terraform pipeline, you can update the function code using the [`build.sh`](handler/build.sh) by specifying an `environment` argument:

```bash
$ cd handler
$ ./build.sh -e prod
```

## Local testing

You can iterate on your handler function locally by setting up a docker-compose based Postgres database and then invoking your handler function directly.

1. Start the local database with [`docker-compose`](handler/test/docker-compose.yaml).
2. Create a test user, database and role with [`init-users.sh`](handler/test/init-users.sh).
3. Copy [`env.example`](handler/test/env.example) to `.env` and then `source` it into your shell
4. Run `pip install -r requirements.txt`
5. Run `cat test/escalate.json | python handler.py` to grant a user access to the readonly role.
6. Verify the user grants by running `\du` from the `psql` console.
