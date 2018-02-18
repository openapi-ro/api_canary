defmodule ApiCanary.JsonCompareJob do
  alias ApiCanary.Request
  defstruct request: nil,
            expected_response: nil,
            result: nil,
            execution_start: nil,
            duration: nil
  def new(%Request{}=req, %{}=expected_result) do
    %__MODULE__{
      request: req,
      expected_response: expected_result
    }
  end
  def new(%{}=map_init) do
    ret=struct(__MODULE__, map_init )
    ret = %__MODULE__{ ret|
      request:
        case ret.request do
          %Request{} -> ret
          other -> Request.new(other)
        end
      }
  end
  def run(%__MODULE__{}=job), do: run(job, log: true)
  def run(%__MODULE__{}=job, options ) do
    #ApiCanary.Scheduler.deactivate_job(:first_job)
    job= %{job| execution_start: :calendar.universal_time()}
    {diff,resp}  = ApiCanary.ResponseDiff.make_diff( job.request, job.expected_response)
    {time,resp}=
    if Map.has_key?(resp,:__time) do
      {resp[:__time], Map.delete(resp,:__time)}
    else
      {nil,resp}
    end
    job = %__MODULE__{job| duration: time}
    job=
      case diff do
        _map when _map == %{} -> %__MODULE__{job | result: :ok}
        diff-> %__MODULE__{job | result: {:error, [diff: diff, response: resp]}}
      end
    if options[:log]  do
      ApiCanary.EventLog.log(job)
    end
    job
  end

  def run(%{}=job, options), do: run __MODULE__.new(job), options
  def run(%{}=job), do: run __MODULE__.new( job)
end