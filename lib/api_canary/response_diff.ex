defmodule ApiCanary.ResponseDiff do
  alias HTTPoison.Response
  alias ApiCanary.Request
  @moduledoc """
    Module reading `priv/`
  """
  def read_file(path \\ nil) do
    path =
      case path do
        nil->Application.app_dir(:api_canary, "priv/req_res_tester.json")
        path-> path
      end
    path
    |> File.read!()
    |> Poison.decode!()
  end
  @doc """
    this  method tests if the `request` matches the expected response

    The `request` is either an url (bitstring), or a `ApiCanary.Request` object.

    The expected_response follows the `HTTPoison.Response` object, including all
    struct fields: `:body, :headers, :request_url, :status_code`

    if the response.body is a map, then a parsing attempt is made on response.body.
    If it succeeds the resulting json will be compared, otherwhise the strings will
    be compared

    Accepted `option` values are:

    - `[keys: :root_only_expected]` any additional fields in the response, which are not
    in the expected keys set are dropped
    - `[keys: :only_expected] ` **TODO:** Implement (recursive)
  """
  def make_diff(url,expected_response),
    do: make_diff(url,expected_response, [keys: :root_only_expected])
  def make_diff(url, expected_response, options) when is_bitstring(url),
    do: make_diff(%Request{url: url}, expected_response, options )
  def make_diff(request, expected_response, options) when is_bitstring(expected_response),
    do: make_diff(request,
      %{
        body: expected_response,
        #headers: :any,
        #request_url: :any,
        #status_code: :any
      }, options )
  #we want a map, really,  not a struct
  def make_diff(request, %_{}=expected_response, options), do: make_diff request, %{body:
      Map.from_struct(expected_response)
    }, options
  def make_diff(request, %{}=expected_response, options) do
    resp = request(request)
    cmp=
      case options[:keys] do
        :root_only_expected -> Map.take(resp, Map.keys(expected_response))
        _->
          # just remove keys starting with "__" (e.g. __timing)
          resp
          |> Enum.filter(fn {key, val} ->
              case to_string(key) do
                "__"<>_-> false
                _any-> true
              end
            end)
          |> Map.new()
      end
    cmp=
      case expected_response[:body] do
        nil-> cmp

        %{}->
          if is_bitstring(cmp.body) do
            case Poison.decode(cmp.body) do
              {:ok, parsed} -> %{cmp| body: parsed}
              _-> cmp
            end
          else
            cmp
          end
        not_str when not is_bitstring(not_str) -> %{cmp| body: "#{not_str}"}
        _str -> cmp
      end
    JsonDiffEx.diff expected_response, cmp
  end
  def request(%Request{}=request) do
    time fn ->
        {_,resp} = HTTPoison.request(
            request.method,
            request.url,
            request.body,
            request.headers,
            request.options)
        Map.from_struct(resp)
      end
  end
  @doc """
    times the given function
  """
  def time(function) do
    {time, val} = :timer.tc function
    Map.put(val, :__time, time/1_000_000 )
  end
end