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

    - `[keys: only_expected]` any additional fields in the response, which are not
    in the expected keys set are dropped
  """
  def make_diff(url,expected_response),
    do: make_diff(url,expected_response, [keys: :only_expected])
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
        :only_expected->keep_only_keys(expected_response, resp)
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
    require IEx
    IEx.pry
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
  @doc """
    only keeps the expected elements.

    In case the expected is a `list`, and that list is

    - longer: the res list is appended with nil values to have the same length
    - shorter ot equal:  res is returned unmodified
  """
  def keep_only_keys(exp,res) do
    keep_only_keys(exp,res, try_string_to_json: true)
  end
  def keep_only_keys(exp,res, options) when is_list(exp) and is_list(res) do
    len = length(exp)
    case  length(res) do
      res_len when res_len <= len ->
        res
      res_len when res_len > len ->
        Enum.take(res, len)
    end
    Enum.zip(exp,res)
    |> Enum.map(fn {exp, res} ->
      keep_only_keys(exp,res,options)
    end)
  end
  def keep_only_keys(exp,res,options) when is_map(exp) and is_map(res) do
    res
      |> Enum.filter(fn {key, val} ->
          case to_string(key) do
            "__"<>_-> false
            _any-> true
          end
        end)
      |> Enum.flat_map(fn {key, val} ->
        if Map.has_key?(exp, key) do
          [{key,
            keep_only_keys(exp[key], res[key])
          }]
        else
          []
        end
      end)
      |> Map.new()
  end
  #ok, expecting something other than string, but comparing to string.
  # if `try_string_to_json` option is true, try and decode the potential json inside the string
  def keep_only_keys(exp,res, options) when (not is_bitstring(exp)) and is_bitstring(res) do
    if options[:try_string_to_json] do
      case Poison.decode(res) do
        {:ok, parsed} -> keep_only_keys(exp,parsed,options)
        _-> res
      end
    else
      res
    end

  end
  #this is the case for any type which is not a `map`  oe a `list`
  def keep_only_keys(exp,res,options) do
    res
  end
end