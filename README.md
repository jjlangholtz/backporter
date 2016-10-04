# Backporter
The Backporter is a service that responds to [GitHub Webhooks](https://developer.github.com/webhooks/) to trigger automatic commit backports.

## How does it work?
When a pull request is merged **and** is labeled with a pre-configured targeted label, a webhook is sent from GitHub to the service. The service will then apply a `git cherry-pick` from the designated sha to the target branch.

If the backport is successful, the service will use the GitHub API to:

1. Push the backported commit to the target branch
2. Remove the target label from the merged pull request
3. Add a new backported label to the merged pull reqeust
4. Make a pull request comment including `git log` output from the backport

If the backport is unsuccessful, the service will:

1. Remove the target label from the merged pull request
2. Add a new conflict label to the merged pull request
3. Make a pull request comment including `git diff` output from the backport

## Getting started

### Prerequisites
* Ruby 2.3 with bundler
* Postgresql

### Setup
1. `git clone git@github.com:jjlangholtz/backporter.git`
2. `cd backporter`
3. `bin/setup`
4. `bin/rails server`
