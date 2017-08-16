ExUnit.start()

Application.ensure_all_started(:apm_repository)
Application.ensure_all_started(:apm_issues)


ApmRepository.Dictionary.start_link()
ApmIssues.Repo.start_link("issues")


