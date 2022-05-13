# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_vars = {
  request_channel = "#sym-requests" # Slack Channel where requests should go

  approvers = "foo@myco.com,bar@myco.com" # Optional safelist of users that can approve requests
}

# Enable this to create an example db and wire it to the lambda
db_enabled = false

# Connection info for the Postgres database if db_enabled is false
# The password is configured in an AWS SSM parameter
# (/symops.com/sym-postgres/PG_PASSWORD)
/*
pg_connection_config = {
  host = "changeme"
  port = 5432
  user = "changeme"
}
*/

# The subnet ids to associate with the lambda function, required if db_enabled
# is false.
# lambda_subnet_ids = "subnet-0df09460bfa7e0eff"

# The target roles that users can request access to
pg_targets = [
  {
    role_name = "readonly"
    label     = "Readonly"
  }
]

slack_workspace_id = "CHANGEME" # Slack Workspace where Sym is installed

# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "CHANGEME"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
