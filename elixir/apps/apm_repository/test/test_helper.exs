Application.ensure_all_started(:apm_repository)

ApmRepository.Dictionary.start_link()

ExUnit.start()
