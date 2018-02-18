defmodule ApiCanary.EventLog do
  alias ApiCanary.JsonCompareJob
  use Agent
  def start_link() do
    Agent.start_link(fn ->[] end, name: __MODULE__)
  end
  def log(%JsonCompareJob{}=job) do
    Agent.update __MODULE__ , fn state ->
      [job|state]
    end
  end
  def get_log(), do: Enum.reverse(Agent.get( __MODULE__, fn state-> state end))
  def take_log(), do: Enum.reverse( Agent.update(__MODULE__, fn state-> {state,[]} end))
end