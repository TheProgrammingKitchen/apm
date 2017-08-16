# ApmRepository

The `ApmRepository` is an OTP application maintaining the state of 
a list of _Buckets_. Each _Bucket_ is represented by a supervised
`Agent`. A _Bucket_ (`ApmRepository.Bucket`) starts a `GenServer` which holds
the list of _Entries_ for a named _Bucket_.

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
    {:apm_repository, in_umbrella: true},
    ...
  ]
end
```
    

Or, (once this project is on hex-pagages)

```elixir
def deps do
  [
    {:apm_repository, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/apm_repository](https://hexdocs.pm/apm_repository).

