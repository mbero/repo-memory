# Profile — Jira

**Read this when the agent writes a ticket description, a comment, or a merge
request text for a team that uses Jira.**

## Ticket description

Write three sections, in this order. Keep it business-oriented.

| Section | Content |
|---|---|
| **Description** | The current situation and why the work is needed. |
| **Scope of implementation** | The stages and the areas to touch, in order. |
| **Expected result** | The outcome and the criteria that close the ticket. |

Rules:

- Avoid implementation detail. Name *what* and *why*, not *how*.
- Write in {{DOC_LANGUAGE}} unless the user asks otherwise.
- One ticket, one outcome. Split a description that needs the word "and" twice.

## Ticket reference in a branch and a commit

| Item | Rule |
|---|---|
| Branch name | `{{TICKET_PREFIX}}` appears in the branch name |
| Commit subject | At least one commit in the branch carries the ticket key |
| Merge request title | Carries the same ticket key |

**Never guess a ticket key.** Derive it from the branch name, from an earlier
commit in the branch, or ask. A wrong key links the work to someone else's ticket.

## Test result comment

Base every statement on evidence from a log or a response. Use this structure:

| Section | Content |
|---|---|
| **Verified** | What you confirmed, with the evidence |
| **Requests** | The exact calls you made |
| **Confirmed** | The behaviour that matched the expectation |
| **Still to verify** | What you could not check, and why |
| **Before production** | What must happen before release |

Do not report a result you did not observe. "Should work" is not a test result.
