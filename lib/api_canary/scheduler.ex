defmodule ApiCanary.Scheduler do
  alias ApiCanary.Request
  use Quantum.Scheduler,
    otp_app: :api_canary
  @doc """
    Function to schedule an api check with equality comparition on equality check

    The recurrence is a cron-like string as defined in 
  """
  def schedule_api_compare(cron_recurrence, %Request{}=req, expexted_result, on_mismatch)  do
    job = __MODULE__.new_job(

    )
    require IEx
    IEx.pry
  end


end