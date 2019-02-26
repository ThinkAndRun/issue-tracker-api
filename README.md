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

## Usage

After execution `./bin/setup` or `rake db:seed`, you will have two users:
- regular@example.com (Regular user)
- manager@example.com (User with manager rights)

If you wish, you can create a new one.

**Create a new user:**
```
curl "localhost:3000/api/signup" -d '{"name":"New User","email":"newuser@example.com","password":"password","password_confirmation":"password","manager":false}' -X POST \
	-H "Accept: application/vnd.issue_tracker_api.v1+json" \
	-H "Content-Type: application/json"
```

The issue tracker allows Token-based Authentication (also known as [JSON Web Token authentication](https://jwt.io/)).

**Retrieve an auth_token:**
```
curl "localhost:3000/api/auth" -d '{"email":"newuser@example.com","password":"password"}' -X POST \
	-H "Accept: application/vnd.issue_tracker_api.v1+json" \
	-H "Content-Type: application/json"
```

**Authorize API call with auth_token:**
```
-H "Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NTExMTQ0NzZ9.MdV5jDJtpo4JvSzF3SBw8GlXmYIqD9bDecmAol9sVbk"
```

> **Please start the server `rails s` and follow [API Documentation](http://localhost:3000/api/docs) to get more information.**

## Not implemented

* Anything security related (except authorization)
* Anything related to user management (delete api call / admin role / etc)
* Anything related to complicated testing and deployment (travis-ci / docker containers, capistrano configs, etc)
* Models weren't tested, only integration tests were implemented (for api calls)
* The client is out of scope