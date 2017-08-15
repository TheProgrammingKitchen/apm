defmodule ApmIssues do

  @doc"""
  Seed from JSON-Fixtures.

  This function may go away once we have a 'real' gateway
  """
  def seed do
    filename = Path.expand("../../../data/fixtures/issues.json",__DIR__)
    ApmIssues.Adapter.File.read!(filename)
  end

  def drop! do
    ApmIssues.Repo.drop!
  end



end
