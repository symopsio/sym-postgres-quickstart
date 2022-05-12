from sym.sdk.annotations import hook, reducer
from sym.sdk.integrations import slack
from sym.sdk.templates import ApprovalTemplate


# Reducers fill in the blanks that your workflow needs in order to run.
@reducer
def get_approvers(evt):
    """
    Post to shared channel to ask for access approval, allowing
    self-approval
    """
    fvars = evt.flow.vars

    # Request approval in channel
    return slack.channel(fvars["request_channel"], allow_self=True)


# Hooks let you change the control flow of your workflow.
# @hook Uncomment me to enable authz based on an approvers group!
def on_approve(evt):
    """
    Only let members of the approver safelist approve requests
    """
    if not has_approve_access(evt):
        return ApprovalTemplate.ignore(
            message="You are not authorized to approve this request."
        )


def has_approve_access(evt):
    """
    Check if the requesting user is in the safelist from fvars
    """
    fvars = evt.flow.vars
    user = evt.user
    approvers = fvars["approvers"].split(",")
    return user.email in approvers
