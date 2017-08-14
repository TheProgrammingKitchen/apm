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

   AGENT  ID   SUBJECT    PARENT_ID    CHILDREN      Other fields ...
    -----------------------------------------------------------------
   <PID> 1    Issue1     -            []             %{} 
   <PID> 2    Issue2     -            [{3,<PID>},{4,PID},{1000,PID}]
   <PID> 5    Issue2.2.1 4            []
   <PID> ...




