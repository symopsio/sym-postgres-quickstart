# example_db

## Reading the db config

To get the connection info for the example db, use the `terraform output` command. Note that in a production setting you should not store the database password in Terraform state.

```bash
$ terraform output db_config
tomap({
  "host" = "sym-example.cluster-abcdefg12345.us-east-1.rds.amazonaws.com"
  "pass" = "mydbpassword"
  "port" = "5432"
  "user" = "sym_master"
})
```
