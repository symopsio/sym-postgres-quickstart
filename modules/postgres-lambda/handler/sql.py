from psycopg2 import sql

from config import Config


def format_sql(username: str, event: dict, config: Config) -> sql.Composable:
    """
    Get the right sql statement for the supplied event and user
    """
    target_role = config.target_role
    event_type = event["event"]["type"]
    if event_type == "escalate":
        return format_grant(target_role, username)
    elif event_type == "deescalate":
        return format_revoke(target_role, username)
    else:
        raise RuntimeError(f"Unsupported event type: {event_type}")


def format_grant(rolename: str, username: str) -> sql.Composable:
    """
    Use SQL Composition to safely generate a grant statement
    https://www.psycopg.org/docs/sql.html#module-psycopg2.sql
    """
    return sql.SQL(
        """
        GRANT
            {rolename}
        TO
            {username}
    """
    ).format(
        rolename=sql.Identifier(rolename),
        username=sql.Identifier(username),
    )


def format_revoke(rolename: str, username: str) -> sql.Composable:
    """
    Use SQL Composition to safely generate a revoke statement
    https://www.psycopg.org/docs/sql.html#module-psycopg2.sql
    """
    return sql.SQL(
        """
        REVOKE
            {rolename}
        FROM
            {username}
    """
    ).format(
        rolename=sql.Identifier(rolename),
        username=sql.Identifier(username),
    )
