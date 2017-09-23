# APM – The Agile Project Manager

## Links

  * [Github][]
  * [Project Page][]
  * [Scrum Board][]

This is the ./elixir subfolder of APM.
If you're new to the project, please start with README.md in the root-path
of the project.

`apm/elixir` is an umbrella project with the following parts

  * apm_issues – the core of the business logic and data handling
  * apm_user – defines user-structure, roles, and authentication
  * apm_px – The Phoenixframework Application

Watch out `README-*.md` in each of the apps directories.

### Get And Update Dependencies

    mix deps.clean --all
    mix deps.get

    mix deps.update --all

## Umbrella Apps

### apm_user

OTP-Application responsible for all user-related functions.
Roles, Authentication, ...

See `ApmUser`

### apm_issues

Backend application to deal with 'Issues'. 
Structs, Supervisors, Data-nodes, ...

See: `ApmIssues`

### apm_px

The _Phoenix-Frontend_ application

See `ApmPx`

## Online Documentation

To generate and read the online documentation run

    mix docs
    open doc/index.html

# Testing

## Run unit and controller tests

    mix test --exclude hound

## Run full test suite including end to end tests with 'Hound'

  1. `cd apm/elixir/apps/apm_px`
  2. `mix phx.server`     – in an extra terminal
  3. `phantomjs --wd`     – in an extra terminal
  4. `mix test --trace`   – in apps/apm_px or in the project root path


## A Note About Integration Tests

Because the Phoenix application has to be started before running the integration tests,
the tests works only if you just have started a newly compiled phx.server. After you
fiddled around with the application data, the tests might fail and you have to restart
the application phx.server.

### Reset test data for E2E tests

    cd apps/apm_px
    touch mix.exs  # ensure the binary gets rebuild
    mix phx.server # will generate simple test data from `data/fixtures/issues.json`


 See [Pivotal Tracker][] and [Github][]

[Github]: https://github.com/TheProgrammingKitchen/apm
[Pivotal Tracker]: https://www.pivotaltracker.com/n/projects/2079917
[Project Page]: https://theprogrammingkitchen.github.io/apm/
[Scrum Board]: https://app.zenhub.com/workspace/o/theprogrammingkitchen/apm/boards?repos=98336128
