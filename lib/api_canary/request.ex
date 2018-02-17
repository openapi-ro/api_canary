defmodule ApiCanary.Request do
  defstruct [
    url: nil,
    headers: [],
    body: "",
    method: :get,
    options: []
  ]
end