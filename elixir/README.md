# APM – The Agile Project Manager

## Links

  * [Github][]
  * [Project Page][]
  * [Scrum Board][]
  * [Pivotal Tracker][] _obsolete_

This is the ./elixir subfolder of APM.
If you're new to the project, please start with README.md in the root-path
of the project.

is an umbrella project with the following parts

  * apm_issues
  * apm_user
  * apm_px

Watch out `README.md` in each of the apps directories.

### Update dependencies

    mix deps.clean
    mix deps.get
    mix deps.update

### Generate documentation

    mix docs
    open doc/index.html

## apm_user

OTP-Application responsible for all user-related functions.
Roles, Authentication, ...

## apm_issues

Backend application to deal with /Jira/Issues. The structs, the repository, ...

## apm_px

The _Phoenix-Frontend_ application

## Online Documentation

    open doc/index.html

## Run the tests

    mix test --exclude hound

## Run integration/E2E tests

    1. cd apps/apm_px
    2. mix phoenix.server # in an extra terminal
    3. phantomjs --wd     # in an extra terminal
    4. mix test --trace   # in apps/apm_px or in the project root path


# TODO

 See [Pivotal Tracker][] and [Github][]





[Github]: https://github.com/iboard/apm
[Pivotal Tracker]: https://www.pivotaltracker.com/n/projects/2079917
[Project Page]: https://theprogrammingkitchen.github.io/apm/
[Scrum Board]: https://app.zenhub.com/workspace/o/theprogrammingkitchen/apm/boards?repos=98336128
