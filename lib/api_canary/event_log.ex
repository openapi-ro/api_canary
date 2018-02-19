defmodule ApiCanary.EventLog do
  alias ApiCanary.JsonCompareJob
  use Agent
  def start_link() do
    Agent.start_link(fn ->{0,[]} end, name: __MODULE__)
  end
  def log(%JsonCompareJob{}=job) do
    Agent.update __MODULE__ , fn {idx_start, state} ->
      {idx_start,[job|state]}
    end
  end
  def get_log() do
    {idx_start, state} = Agent.get( __MODULE__, fn state-> state end)
    state
    |> Enum.reverse()
    |> Enum.with_index(idx_start)
  end
  def take_log() do
    {idx_start, state} = Agent.update( __MODULE__, fn 
      {idx_offset, state}-> {state, {idx_offset+length(state), []}} 
    end)
    state
    |> Enum.reverse()
    |> Enum.with_index(idx_start)
  end
end