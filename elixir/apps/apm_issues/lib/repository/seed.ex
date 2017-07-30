defmodule ApmIssues.Repository.Seed do

  @fixture_file Path.expand("../../../../data/fixtures/issues.json", __DIR__)

  @moduledoc"""
  For now it is enough to load a couple of Issues from a fixture file.
  In further development, this module will be responsible to initialize
  Lazy loading when the application is started. And the structure of
  JSON-Files will be changed from a single file into a directory-structure.


      # ------------------------------------
      # Fixtures File for File-Adapter Tests
      # ====================================
      [
        {
          "id" : "Item-1",
          "subject" : "Item-1"
        },
        {
          "id" : "Item-2",
          "subject" : "Item-2",
          "children" : [
            { 
              "id" : "Item-2.1",
              "subject" : "Item-2.1",
              "parent_id" : "Item-2"
            },
            {
              "id" : "Item-2.2",
              "subject" : "Item-2.2",
              "parent_id" : "Item-2"
            }
          ]
        }
      ]
  """


  @doc"""
  Load the file using `ApmIssues.Adapter.File` which consequentially
  pushes all items to the repository.
  """
  def load do
    ApmIssues.Adapter.File.read!(@fixture_file)
  end

end

