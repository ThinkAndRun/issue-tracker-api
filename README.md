# issue-tracker-api

Very simple issue tracker. API only.

## Features

As a regular user you will:
- be able to log into the system.
- be able to create issues.
- be able update and delete **only your** issues.
- see the list of **only your** issues (most recent at the top).
- **not** be able to update the status of your issues.
- **not** be able to update the assignend manager of your issues.

As a manager you will:
- be able to log into the system.
- be able to see the list of **all** issues.
- be able to assign an issue to only **yourself** and only if it is **not already assigned** to somebody else.
- be able to unassign an issue from **yourself**.
- be able to change the status of the issue **only** if the issue is assigned to you.
- **not** be able to assign an issue to somebody else.
- **not** be able to change the status of an issue **unless** it is assigned to you.

Notes:
- issue statuses: “pending”, “in progress”, “resolved”. Default: “pending”.
- if the issue has “in progress”, or “resolved” status the assignee is required. It can’t be unassigned in these two statuses.
- users and managers can filter issues by “status”.
- pagination is implemented, 25 issues in the response.

## Installation

Please use [`./bin/setup`](https://robots.thoughtbot.com/bin-setup) script to setup the environment.
