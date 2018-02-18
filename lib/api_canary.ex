defmodule ApiCanary do
  use Application
  @moduledoc """
  Documentation for ApiCanary.
  """
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # This is the new line
      worker(ApiCanary.Scheduler, []),
      worker(ApiCanary.EventLog, [])
    ]

    opts = [strategy: :one_for_one, name: ApiCanary.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
