use Mix.Config

IO.puts "Configure Logger for #{Mix.env}"

config :logger, level: :debug,
                backends: [:console],
                compile_time_purge_level: :debug

config :apm_issues, 
         log_level: :debug
