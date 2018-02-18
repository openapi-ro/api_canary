defmodule ApiCanary.Request do
  defstruct [
    url: nil,
    headers: [],
    body: "",
    method: :get,
    options: []
  ]
  def new(%{}=map_init) do
    struct(__MODULE__, map_init)
  end
end