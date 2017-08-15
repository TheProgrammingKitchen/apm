# ApmIssues

`ApmIssues` handles everything about `ApmIssues.Issue`

While developing, _The Agile Project Manager_ this OPT-Application
will read from fixture-files, located in the directory `project's-root/data/fixtures`.

In the final version, APM will have multiple ways to import existing
_Issues_. (eg Jira, Pivotal-Tracker, ...)

Once the fixtures are read from the files into the `ApmRepository`, `ApmIssues`
reads and writes from/to the repository only.


## The nature of _Issues_

    +---- Issue1                   1
    +--\- Issue2                   2
    |   -+-- Issue2.1              3
    |    +-- Issue2.2              4
    |    |  \-- Issue2.2.1         5
    |    |    \-- Issue2.2.1.1     6
    |    |     :
    |    +-- Issue2.3           1000
    +---- Issue3                1001
    :
    .                              n


## The internal representation

     ApmRepository.Dictionary (GenServer with a list of Buckets)
              |
              +---- Bucket "issues", (GenServer with a list of ApmIssues.Issue)
                           |
                           |
                    uuid => { %Issue{}, parent_id, children[] }


# ApmIssue

See the test files and read the output of

    mix test --trace

as a kind of "Specification". It will give you the best glue you can
have at the first glance.

## Installation/Usage

The repository application and it's modules can be used by
including the following lines to the `mix.exs` file of the "user".


```elixir
defp deps do
  [
    ...
    {:apm_issues, in_umbrella: true},
    ...
  ]
end
```
    

Or, (once this project is on hex-pagages)

```elixir
def deps do
  [
    {:apm_issues, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/apm_repository](https://hexdocs.pm/apm_repository).

